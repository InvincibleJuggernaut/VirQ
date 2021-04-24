import 'package:VirQ/screens/home/ticket_list.dart';
import 'package:VirQ/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

//ignore: must_be_immutable
class SideDrawer extends StatelessWidget {

  final AuthService _auth = AuthService();
  
  String uid;
  String value;

  Future<void> userData(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user  = await auth.currentUser();
    uid = user.uid;
    return ticketScreen(context, uid);
  }

  Future<void> ticketScreen(BuildContext context, String uid) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketList(value: uid),
      ),
    );
  }
  
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
            leading: Icon(Icons.account_balance_wallet_rounded),
            title: Text('Tickets'),
            onTap: () {
              userData(context);
            },
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