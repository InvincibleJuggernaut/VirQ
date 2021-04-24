import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class TicketList extends StatefulWidget {

  String value;

  TicketList({this.value});

  @override
  _TicketListState createState() => _TicketListState(value);
}

class _TicketListState extends State<TicketList> {
  
  String value;
  _TicketListState(this.value);
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[500],
      ),
      //floatingActionButton: null,
      backgroundColor: Colors.green[500],
      body: StreamBuilder(
        stream: Firestore.instance.collection('users').document(value).snapshots(),
        builder: (context, snapshot) {
          return Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Card(
              margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
              child: ListTile(
                isThreeLine: true,
                leading: CircleAvatar(
                  radius: 25.0,
                  backgroundColor: Colors.white,
                ),
                title: Text(snapshot.data['queueAt']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Your token : "+snapshot.data['token'].toString()),
                  ],
                ),
                trailing: FlatButton.icon(
                  icon: Icon(Icons.add_box_rounded),
                  label: Text('View'),
                  onPressed: () async {},
                )
              ),
            )
          );
          /*ListView(
            children: <Widget>[
            ListTile(
              title: Text(snapshot.data['queueAt']),
              subtitle: Text(snapshot.data['token'].toString()),
            ),
            ],
            );*/
        },
      )
      
    );
  }
}

