import 'package:VirQ/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:VirQ/services/database.dart';
import 'package:provider/provider.dart';
import 'package:VirQ/models/place.dart';
import 'package:VirQ/screens/home/place_list.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Place>>.value(
        value: DatabaseService().places,
        child: Scaffold(
        drawer: SideDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.green[500],
        ),
        body: PlaceList(),
        backgroundColor: Colors.green[500],
      ),
    );
  }
}

class SideDrawer extends StatelessWidget {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            child: Center(
            ),
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
            ),
            ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Sign Out'),
            onTap: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
    );
  }

}