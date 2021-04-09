import 'package:VirQ/services/database.dart';
import 'package:flutter/material.dart';
import 'package:VirQ/shared/constants.dart';
import 'package:VirQ/screens/home/place_tile.dart';


class QueueDetails extends StatefulWidget {
  @override
  _QueueDetailsState createState() => _QueueDetailsState();
}

class _QueueDetailsState extends State<QueueDetails> {
  
  final _formKey = GlobalKey<FormState>();
  final List<String> people = ['Join', 'Leave'];

  String name;
  int tokenAvailable;
  int totalPeople;
 

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Text(
            'Join queue',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 20.0),
          RaisedButton(
            color: Colors.orange[500],
            child: Text(
              'Update',
              style: TextStyle(color: Colors.green),
            ),
            onPressed: () async {
              await DatabaseService().updatePlaceData(name, tokenAvailable, totalPeople);

              }
        
          )
        ],
      ),
      
    );
  }
}