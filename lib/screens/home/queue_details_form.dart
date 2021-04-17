import 'package:VirQ/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


//ignore: must_be_immutable
class QueueDetails extends StatefulWidget {

  String value;
  QueueDetails({this.value});
  
  @override
  _QueueDetailsState createState() => _QueueDetailsState(value);
}

class _QueueDetailsState extends State<QueueDetails> {
  
  String value;
  _QueueDetailsState(this.value);
  final _formKey = GlobalKey<FormState>();
  final List<String> people = ['Join', 'Leave'];

  String name;
  int tokenAvailable;
  int totalPeople;

  String place;
  int tokenUser;

  updateData(name) {
    DatabaseService().placesCollection.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        if(doc.data['name']==name)
        {
          place = doc.data['name'];
          tokenUser = doc.data['tokenAvailable'];

          Firestore.instance.collection('places').document(doc.documentID).updateData({
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

  searchPlaceData() {
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
        if(doc.documentID == uid)
        {
          Firestore.instance.collection('users').document(doc.documentID).updateData({
            "status": "true",
            "queueAt": place,
            "token": tokenUser,
          }).then((result) {
            print("User data updated");
          }).catchError((onError){
            print("Received an error");
          });
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
            value,
            style: TextStyle(fontSize: 18.0),
          ),
          
          SizedBox(height: 20.0),
          RaisedButton(
            color: Colors.orange[500],
            child: Text(
              'Join Queue',
              style: TextStyle(color: Colors.green),
            ),
            onPressed: () async {
              updateData(value);
              updateUserData();
              }
        
          )
        ],
      ),
      
    );
  }
}