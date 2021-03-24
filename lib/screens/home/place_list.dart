import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:VirQ/models/place.dart';
import 'package:VirQ/screens/home/place_tile.dart';

class PlaceList extends StatefulWidget {
  @override
  _PlaceListState createState() => _PlaceListState();
}

class _PlaceListState extends State<PlaceList> {
  @override
  Widget build(BuildContext context) {

    final places = Provider.of<List<Place>>(context);

    return ListView.builder(
      itemCount: places.length,
      itemBuilder: (context, index) {
        return PlaceTile(place: places[index]);

      },
      
    );
  }
}