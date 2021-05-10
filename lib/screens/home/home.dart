
import 'package:VirQ/screens/home/ticket_list.dart';
import 'package:VirQ/services/auth.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:VirQ/services/database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:VirQ/models/place.dart';
import 'package:VirQ/screens/home/place_list.dart';

//ignore: must_be_immutable
class Home extends StatelessWidget {


  String place;
  int tokenUser;
  int time;

  updatePlaceData(name) {
    
    DatabaseService().placesCollection.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot docu) {
        if(docu.documentID==name)
        {
          place = docu.data['name'];
          tokenUser = docu.data['tokenAvailable'];
          time = docu.data['time'];

          Firestore.instance.collection('places').document(name).updateData({
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

  updateUserData(qrResult) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    
    final FirebaseUser user  = await auth.currentUser();
    String uid = user.uid;

    UserDatabaseService().userCollection.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        if(doc.documentID == uid && doc.data['status']=='false')
        {
          updatePlaceData(qrResult);
          UserDatabaseService().userCollection.getDocuments().then((QuerySnapshot snapshot) {
            snapshot.documents.forEach((DocumentSnapshot doc) {
    
          Firestore.instance.collection('users').document(uid).updateData({
            "status": "true",
            "queueAt": place,
            "token": tokenUser,
            "time": DateTime.now().toString(),
          }).then((result) {
            print(doc.data['email']+" data updated");
          }).catchError((onError){
            print(doc.data['email']+" : Received an error");
          });
            });
          });
          Fluttertoast.showToast(
                  msg: "Your slot details are available inside Tickets section",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                ); 

        }
        else if(doc.documentID == uid && doc.data['status']=='true')
        {
        Fluttertoast.showToast(
        msg: "You are already enrolled in a queue",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        );
        }
        });
    });
  }

  String qrResult = '';

  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();
      qrResult = qrResult;
      print(qrResult);
      updateUserData(qrResult);
    }
    on PlatformException catch (ex) {
      if(ex.code == BarcodeScanner.CameraAccessDenied) {
          qrResult = "Camera permission was denied";
      } else {
          qrResult = "Unkown error $ex";
      }
    } on FormatException {
        qrResult = "Couldn't scan anything";
    } catch (ex) {
        qrResult = "Unknown Error $ex";
    }
  }

  FlutterLocalNotificationsPlugin localNotification;

  Future _showNotification(placeName, tokenNumber, eta) async {
    var androidInitialize = new AndroidInitializationSettings("ic_launcher"); 
    var iOSInitialize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);

    localNotification = new FlutterLocalNotificationsPlugin();
    localNotification.initialize(initializationSettings);
    var androidDetails = new AndroidNotificationDetails("channelId", "Local Notification", "channelDescription", importance: Importance.high, onlyAlertOnce: true);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails = new NotificationDetails(android: androidDetails, iOS: iosDetails);

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
    return StreamProvider<List<Place>>.value(
        value: DatabaseService().places,
        child: Scaffold(
        drawer: SideDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.green[500],
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
              ),
              onPressed: () {
                _scanQR();
              },
            )
          ]
        ),
        body: PlaceList(),
        backgroundColor: Colors.green[500],
      ),
    );
  }
}

//ignore: must_be_immutable
class SideDrawer extends StatelessWidget {

  final AuthService _auth = AuthService();
  
  String uid;
  String value;

  Future<void> userData(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user  = await auth.currentUser();
    uid = user.uid;
    return ticketScreen(context, uid);
  }

  Future<void> ticketScreen(BuildContext context, String uid) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketList(value: uid),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            child: Center(
            ),
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
            ),
            ListTile(
            leading: Icon(Icons.account_balance_wallet_rounded),
            title: Text('Tickets'),
            onTap: () {
              userData(context);
            },
            ),
            ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Sign Out'),
            onTap: () async {
              await _auth.signOut();
            },
          ),
          
        ],
      ),
    );
  }

}