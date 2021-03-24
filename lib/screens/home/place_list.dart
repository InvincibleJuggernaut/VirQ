import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:VirQ/models/place.dart';

class PlaceList extends StatefulWidget {
  @override
  _PlaceListState createState() => _PlaceListState();
}

class _PlaceListState extends State<PlaceList> {
  @override
  Widget build(BuildContext context) {

    final places = Provider.of<List<Place>>(context);
    places.forEach((place) {
      print(place.name);
      print(place.tokenAvailable);
      print(place.totalPeople);
    });

    return Container(
      
    );
  }
}