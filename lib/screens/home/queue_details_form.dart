import 'package:VirQ/models/place.dart';
import 'package:VirQ/screens/home/qr_scan.dart';
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
  final List<String> people = ['Join', 'Leave'];

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
    String uid = user.uid;

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
    var androidDetails = new AndroidNotificationDetails("channelId", "Local Notification", "channelDescription", importance: Importance.high);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails = new NotificationDetails(android: androidDetails, iOS: iosDetails);

    await localNotification.show(0, "Joined queue at "+placeName, "Token : "+tokenNumber.toString() + "  |  ETA : "+eta.toString()+" min", generalNotificationDetails);

  }

  Future<void> qrCodeScanner(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScan(),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Text(
            value.name,
            style: TextStyle(fontSize: 25.0),
          ),
          Text(
            '',
          ),
          Text(
            value.address,
            style: TextStyle(fontSize: 15.0),
          ),
          Text(
            '',
          ),
          Text(
            "Token : "+value.tokenAvailable.toString(),
            style: TextStyle(fontSize: 15.0),
          ),
          SizedBox(height: 20.0),
          RaisedButton(
            color: Colors.orange[500],
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