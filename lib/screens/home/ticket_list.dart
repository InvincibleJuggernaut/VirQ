import 'package:VirQ/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ticket_pass_package/ticket_pass.dart';

//ignore: must_be_immutable
class TicketList extends StatefulWidget {

  String value;

  TicketList({this.value});


  @override
  _TicketListState createState() => _TicketListState(value);
}

class _TicketListState extends State<TicketList> {
  
  updateUserData() async {

    String place;
    int userDeleted;
    
    final FirebaseAuth auth = FirebaseAuth.instance;
    
    final FirebaseUser user  = await auth.currentUser();
    String uid = user.uid;

    UserDatabaseService().userCollection.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        if(doc.documentID == uid)
        {
          place = doc.data['queueAt'];
          userDeleted = doc.data['token'];
          //print(place);
          Firestore.instance.collection('users').document(doc.documentID).updateData({
            "status": 'false',
            "queueAt": 'none',
            "token": 0,
            "time": 'none',
            "eta": 0,
          }).then((result) {
            print("User data updated");
          }).catchError((onError){
            print("Received an error");
          });
        DatabaseService().placesCollection.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        if(doc.data['name']==place)
        {
          Firestore.instance.collection('places').document(doc.documentID).updateData({
                  "tokenAvailable": FieldValue.increment(-1),
                  "totalPeople": FieldValue.increment(-1),
                }).then((result){
                  print("Place data updated");
                }).catchError((onError){
                  print("Received an error");
                });
          Firestore.instance.collection('places'+'/'+doc.documentID+'/queue').document(uid).delete();
        }
      });
    });
    updateQueue(uid, place, userDeleted);
        }
        });
    });
    
  }

  updateQueue(uid, place, deleted) {
    UserDatabaseService().userCollection.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        if(doc.documentID != uid && doc.data['queueAt']==place && doc.data['token'] > deleted)
        {
          //print(place);
          Firestore.instance.collection('users').document(doc.documentID).updateData({
            "token": FieldValue.increment(-1),
          }).then((result) {
            print(doc.data['email']+" : data updated");
          }).catchError((onError){
            print("Received an error");
        });
        }
      });
    });
       localNotification.cancelAll();

  }


  FlutterLocalNotificationsPlugin localNotification;

  @override
  void initState() {
    super.initState();
    var androidInitialize = new AndroidInitializationSettings("ic_launcher"); 
    var iOSInitialize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);

    localNotification = new FlutterLocalNotificationsPlugin();
    localNotification.initialize(initializationSettings);
  }

  Future _showNotification(placeName, tokenNumber, eta) async {
    var androidDetails = new AndroidNotificationDetails("channelId", "Local Notification", "channelDescription", importance: Importance.high, onlyAlertOnce: true);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails = new NotificationDetails(android: androidDetails, iOS: iosDetails);

    localNotification.cancel(1);
    localNotification.cancel(2);
    await localNotification.show(0, "Joined queue at "+placeName, "Token : "+tokenNumber.toString() + "  |  ETA : "+eta.toString()+" min", generalNotificationDetails);

  }

  Future _showNotificationReady(placeName, tokenNumber, eta) async {
    var androidDetails = new AndroidNotificationDetails("channelId", "Local Notification", "channelDescription", importance: Importance.high, onlyAlertOnce: true);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails = new NotificationDetails(android: androidDetails, iOS: iosDetails);

    localNotification.cancel(0);
    localNotification.cancel(2);
    await localNotification.show(1, "You are up next at "+placeName+". Get Ready !", "Token : "+tokenNumber.toString() + "  |  ETA : "+eta.toString()+" min", generalNotificationDetails);

  }

  Future _showNotificationTurn(placeName, tokenNumber, eta) async {
    var androidDetails = new AndroidNotificationDetails("channelId", "Local Notification", "channelDescription", importance: Importance.high, onlyAlertOnce: true);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails = new NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    localNotification.cancel(0);
    localNotification.cancel(1);
    await localNotification.show(2, "It's your turn at "+placeName, "Get in there !", generalNotificationDetails);

  }    
  
  String value;
  _TicketListState(this.value);
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Tickets'),
        backgroundColor: Color(0xFF008604),
      ),
      //floatingActionButton: null,
      backgroundColor: Color(0xFF008604),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
          child: StreamBuilder(
        stream: Firestore.instance.collection('users').document(value).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.data['status']=='false')
          {
            localNotification.cancel(0);
            return Container(
              margin: EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
              child: Center(
                child: Text(
                  "You haven't joined any queue",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  ),
            ),
            );
          }
          else
          {
          if(snapshot.data['token']==2)
          {
            _showNotificationReady(snapshot.data['queueAt'], snapshot.data['token'], snapshot.data['eta']);
          }
          else if(snapshot.data['token']==1)
          {
            _showNotificationTurn(snapshot.data['queueAt'], snapshot.data['token'], snapshot.data['eta']);
          }
          else
          {
          _showNotification(snapshot.data['queueAt'], snapshot.data['token'], snapshot.data['eta']);  
          }
          return TicketPass(
              alignment: Alignment.center,
              animationDuration: Duration(seconds: 1),
              expandedHeight: 400,
              expandIcon: FlatButton(
                  child: Tooltip(
                    message: "Leave",
                    child: Icon(Icons.delete, color: Colors.red),
                    ),
                  onPressed: () async {
                      updateUserData();
                  }
                  //size: 20,             
                ),
              expansionTitle: Text(
                '',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              purchaserList: [],
              //separatorColor: Colors.black,
              //separatorHeight: 2.0,
              color: Colors.white,
              curve: Curves.easeOut,
              titleColor: Color(0xFF470045),
              shrinkIcon: Align(
                alignment: Alignment.centerRight,
                child: CircleAvatar(
                  maxRadius: 14,
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              ticketTitle: Text(
                '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              titleHeight: 50,
              width: 350,
              height: 220,
              shadowColor: Colors.green,
              elevation: 8,
              shouldExpand: true,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 45.0, vertical: 15),
                child: Container(
                  height: 140,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'ETA',
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.5)),
                                      ),
                                      Text(
                                        snapshot.data['eta'].toString()+" min",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'PLACE',
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ),
                                      Text(
                                        snapshot.data['queueAt'],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'ISSUED',
                                      style: TextStyle(
                                          color: Colors.black.withOpacity(0.5)),
                                    ),
                                    Text(
                                      snapshot.data['time'].substring(0,10),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'TOKEN',
                                      style: TextStyle(
                                          color: Colors.black.withOpacity(0.5)),
                                    ),
                                    Text(
                                      snapshot.data['token'].toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      );
          }
        },
      )
        )
      )
      
    );
  }
}

