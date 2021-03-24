import 'package:flutter/material.dart';
import 'package:VirQ/models/place.dart';


class PlaceTile extends StatelessWidget {
  
  final Place place;
  PlaceTile({ this.place });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.white,
          ),
            title: Text(place.name),
            subtitle: Text(place.totalPeople.toString()),
          ),
        )
    );
    }
}