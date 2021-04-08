import 'package:VirQ/screens/home/queue_details_form.dart';
import 'package:flutter/material.dart';
import 'package:VirQ/models/place.dart';


class PlaceTile extends StatelessWidget {
  
  final Place place;
  PlaceTile({ this.place });

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
              onPressed: () => showQueueDetailsPanel(),
            )
          ),
        )
    );
    }
}