import 'package:VirQ/screens/authenticate/authenticate.dart';
import 'package:VirQ/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:VirQ/models/user.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    print(user);
 
    if(user == null){
      return Authenticate();
    } else {
      return Home();
    }
  }
}