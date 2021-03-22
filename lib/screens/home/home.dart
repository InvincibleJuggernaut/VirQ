import 'package:VirQ/services/auth.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.green[500],
      ),
      backgroundColor: Colors.green[500],
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