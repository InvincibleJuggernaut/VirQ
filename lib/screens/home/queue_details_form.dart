import 'package:VirQ/models/place.dart';
import 'package:VirQ/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


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
  
  updatePlaceData(name) {
    
    DatabaseService().placesCollection.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot docu) {
        if(docu.data['name']==name)
        {
          place = docu.data['name'];
          tokenUser = docu.data['tokenAvailable'];

          Firestore.instance.collection('places').document(docu.documentID).updateData({
                  "tokenAvailable": FieldValue.increment(1),
                  "totalPeople": FieldValue.increment(1),
                }).then((result){
                  print("Place data updated");
                }).catchError((onError){
                  print("Received an error");
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
    String uid = user.uid;

    UserDatabaseService().userCollection.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        if(doc.documentID == uid && doc.data['status']=='false')
        {
          updatePlaceData(value.name);
          UserDatabaseService().userCollection.getDocuments().then((QuerySnapshot snapshot) {
            snapshot.documents.forEach((DocumentSnapshot doc) {
    
          Firestore.instance.collection('users').document(doc.documentID).updateData({
            "status": "true",
            "queueAt": place,
            "token": tokenUser,
            "time": DateTime.now().toString(),
          }).then((result) {
            print("User data updated");
          }).catchError((onError){
            print("Received an error");
          });
            });
          });

        }
        else
        {
          print("Already present in some other queue");
          Alert(context: context,
          type: AlertType.info,
          title: 'Message', 
          desc: "You are already enrolled in a queue",
          buttons : [
            DialogButton(
              color: Colors.orange,
              child: Text(
                "OK",
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ]).show();
        }
        });
    });
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
        
          )
        ],
      ),
      
    );
  }
}
