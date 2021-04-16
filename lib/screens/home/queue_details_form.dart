import 'package:VirQ/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    updateData(name) {
    DatabaseService().placesCollection.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        if(doc.data['name']==name)
        {
          //print(doc.data['name']);
          //print(doc.data['tokenAvailable']);
          //print(doc.data['totalPeople']);
          //print(doc.documentID);
          Firestore.instance.collection('places').document(doc.documentID).updateData({
                  "tokenAvailable": FieldValue.increment(1),
                  "totalPeople": FieldValue.increment(1),
                }).then((result){
                  print("Data updated");
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
            'Queue',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 20.0),
          RaisedButton(
            color: Colors.orange[500],
            child: Text(
              'Joing Queue',
              style: TextStyle(color: Colors.green),
            ),
            onPressed: () async {
              updateData(value);
              }
        
          )
        ],
      ),
      
    );
  }
}