import 'package:VirQ/screens/home/queue_details_form.dart';
import 'package:VirQ/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:VirQ/models/place.dart';

//ignore: must_be_immutable
class PlaceTile extends StatelessWidget {
  
  final Place place;
  PlaceTile({ this.place });

  getUserById(String id) {
    
    DatabaseService().placesCollection.document(id).get().then((DocumentSnapshot doc) {
      print(doc.data);
  
    });

  }

  Place value;
  
  @override
  Widget build(BuildContext context) {
    void showQueueDetailsPanel() {
      showModalBottomSheet(context: context, builder: (context) {
        return Container(
          color: Color(0xFF008604),
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
          child: QueueDetails(value: place),
        );
      });
    }
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        color: Color(0xFF008604),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15)),
            side: BorderSide(width:2, color: Color(0xFF00B906))),
          
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          isThreeLine: true,
          leading: CircleAvatar(
            child: Image.network(place.coverPic),
            radius: 25.0,
            backgroundColor: Color(0xFF008604),
          ),
          
            title: Text(place.name, style: TextStyle(color: Colors.white)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(""),
                Text("Token    "+place.tokenAvailable.toString(), style: TextStyle(color: Colors.white)),
                
              ],
            ),
            
            trailing: FlatButton.icon(
              icon: Icon(Icons.add_box_rounded, color: Colors.white),
              label: Text('View',  style: TextStyle(color: Colors.white)),
              onPressed: () async {
                showQueueDetailsPanel();
              },
            )
          ),
        )
    );
    }
}