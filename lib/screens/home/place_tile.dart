import 'package:VirQ/screens/home/queue_details_form.dart';
import 'package:VirQ/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:VirQ/models/place.dart';


class PlaceTile extends StatelessWidget {
  
  final Place place;
  PlaceTile({ this.place });

  getData(name) {
    DatabaseService().placesCollection.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        if(doc.data['name']==name)
        {
          print(doc.data['name']);
          print(doc.data['tokenAvailable']);
          print(doc.data['totalPeople']);
          print(doc.documentID);
        }
      });
    });
  }

  getUserById(String id) {
    
    DatabaseService().placesCollection.document(id).get().then((DocumentSnapshot doc) {
      print(doc.data);
  
    });

  }


  @override
  Widget build(BuildContext context) {
    void showQueueDetailsPanel() {
      showModalBottomSheet(context: context, builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
          child: QueueDetails(),
        );
      });
    }
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
            title: Text(place.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(place.totalPeople.toString()),
                Text(place.tokenAvailable.toString()),
              ],
            ),
            
            trailing: FlatButton.icon(
              icon: Icon(Icons.add_box_rounded),
              label: Text('Join'),
              onPressed: () async {
                showQueueDetailsPanel();
                getData(place.name);
              },
            )
          ),
        )
    );
    }
}