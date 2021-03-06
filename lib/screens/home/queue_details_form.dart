import 'dart:async';

import 'package:VirQ/models/place.dart';
import 'package:VirQ/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';


//ignore: must_be_immutable
class QueueDetails extends StatefulWidget {

  final Place value;
  QueueDetails({this.value});
  
  @override
  _QueueDetailsState createState() => _QueueDetailsState(value);
}

class _QueueDetailsState extends State<QueueDetails> {
  
  Place value;
  _QueueDetailsState(this.value);

  final _formKey = GlobalKey<FormState>();
  
  String uid;
  String userEmail;
  int userETA;
  int userToken;
  String userStatus;
  String userPlace;

  String name;
  int tokenAvailable;
  int totalPeople;

  String place;
  int tokenUser;
  int time;
  
  updatePlaceData(name) {
    
    DatabaseService().placesCollection.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot docu) {
        if(docu.data['name']==name)
        {
          place = docu.data['name'];
          tokenUser = docu.data['tokenAvailable'];
          time = docu.data['time'];

          Firestore.instance.collection('places').document(docu.documentID).updateData({
                  "tokenAvailable": FieldValue.increment(1),
                  "totalPeople": FieldValue.increment(1),
                }).then((result){
                  print("Place data updated");
                }).catchError((onError){
                  print("Received an error");
                });
                  _showNotification(place, tokenUser, (tokenUser-1)*time);    
          Firestore.instance.collection('places'+'/'+docu.documentID+'/queue').document(uid).setData({
            "email": userEmail,
            "token": tokenUser,
            "eta": (tokenUser-1)*time,
          });  
        }
      });
    });
  }

  String placeName;
  int placeToken;

  searchPlaceData(name) {
    DatabaseService().placesCollection.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        if(doc.data['name']==name)
        {
          placeName = doc.data['name'];
          placeToken = doc.data['tokenAvailable'];
        }
      }
      );
    }
    );
  }

  updateUserData() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    
    final FirebaseUser user  = await auth.currentUser();
    uid = user.uid;

    UserDatabaseService().userCollection.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        if(doc.documentID == uid && doc.data['status']=='false')
        {
          updatePlaceData(value.name);
          UserDatabaseService().userCollection.getDocuments().then((QuerySnapshot snapshot) {
            snapshot.documents.forEach((DocumentSnapshot doc) {
          Firestore.instance.collection('users').document(uid).updateData({
            "status": "true",
            "queueAt": place,
            "token": tokenUser,
            "time": DateTime.now().toString(),
            "eta": (tokenUser-1)*time,
          }).then((result) {
            print(doc.data['email']+" data updated");
          }).catchError((onError){
            print(doc.data['email']+" : Received an error");
          });
            });
          });
          userEmail = doc.data['email'];
          userETA = doc.data['eta'];
                          Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: "Your slot details are available inside Tickets section",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                );   

        }
        else if(doc.documentID == uid && doc.data['status']=='true')
        {
          print(doc.data['email']+" already present in some other queue");
          Navigator.pop(context);
          Fluttertoast.showToast(
            msg: "You are already enrolled in a queue",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
        });
    });
  }
  Timer timer;
  
  
  void updateETA() {
    UserDatabaseService().userCollection.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        if(doc.documentID == uid && doc.data['status'] == 'true')
        {
          userETA = doc.data['eta']-1;
          userToken = doc.data['token'];
          userStatus = doc.data['status'];
          userPlace = doc.data['queueAt'];
          if(userETA > 0 && userToken != 1 && userStatus == 'true') {
      Firestore.instance.collection('users').document(uid).updateData({
        "eta": FieldValue.increment(-1),
      });
      print("ETA"+userETA.toString());
      _showNotification(userPlace, userToken, userETA);
      print("RUN1");
    }
    else if(userETA == 0 && userToken != 1 && userStatus == 'true') {
      Firestore.instance.collection('users').document(uid).updateData({
        "eta": 2,
      });
      _showNotification(userPlace, userToken, userETA+2);
      print("RUN2");
    }
    else if(userETA == -1 && userToken == 1 && userStatus == 'true') {
      _showNotification(userPlace, userToken, userETA+1);
      print("RUN3");
    }
        }
      });
    });
    
  }
  FlutterLocalNotificationsPlugin localNotification;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(minutes: 1), (Timer timer) => updateETA());
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

    var androidInitialize = new AndroidInitializationSettings("ic_launcher"); 
    var iOSInitialize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);

    localNotification = new FlutterLocalNotificationsPlugin();
    localNotification.initialize(initializationSettings);

    if(tokenNumber == 2)
    {
      localNotification.cancel(0);
      localNotification.cancel(2);
      await localNotification.show(1, "You are up next at "+placeName+". Get Ready !", "Token : "+tokenNumber.toString() + "  |  ETA : "+eta.toString()+" min", generalNotificationDetails);
    }
    else if(tokenNumber == 1)
    {
      localNotification.cancel(0);
      localNotification.cancel(1);
      await localNotification.show(2, "It's your turn at "+placeName, "Get in there !", generalNotificationDetails);
    }
    else
    {
      localNotification.cancel(1);
      localNotification.cancel(2);
    await localNotification.show(0, "Joined queue at "+placeName, "Token : "+tokenNumber.toString() + "  |  ETA : "+eta.toString()+" min", generalNotificationDetails);
    }

  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Text(
            value.name,
            style: TextStyle(fontSize: 25.0, color: Colors.white, fontWeight: FontWeight.w900),
          ),
          Text(
            '',
          ),
          Text(
            value.address,
            style: TextStyle(fontSize: 15.0, color: Colors.white),
          ),
          Text(
            '',
          ),
          Text(
            "Token available : "+value.tokenAvailable.toString(),
            style: TextStyle(fontSize: 15.0, color: Colors.white),
          ),
          //Image.network(value.galleryPic1, height: MediaQuery.of(context).size.width * 0.5, width: MediaQuery.of(context).size.width * 0.5),
          Container(
            padding: EdgeInsets.fromLTRB(0, 3, 0, 5),
            //height: 140,
            height: 195,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                height: 195,
                width: 200,
                child: Image.network(value.galleryPic1)
              ),
              Container(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                height: 195,
                width: 200,
                child: Image.network(value.galleryPic2)
              ),
              Container(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                height: 195,
                width: 200,
                child: Image.network(value.galleryPic3)
              ),
            ],
          ),
          ),
          //SizedBox(height: 20.0),
          RaisedButton(
            //padding: EdgeInsets.fromLTRB(27, 10, 27, 10),
            color: Color(0xFF470045),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Text(
              'Join Queue',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              //updateData(value);
                updateUserData(); 
                
         
              }
        
          ),
        ],
      ),
      
    );
  }
}