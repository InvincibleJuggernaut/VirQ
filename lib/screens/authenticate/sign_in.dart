import 'package:VirQ/services/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[900],
      appBar: AppBar(
        backgroundColor: Colors.yellow[900],
        elevation: 0.0,
        title: Text('LOGIN'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: RaisedButton(
          child: Text('Sign in anonymously'),
          onPressed: () async {
            dynamic result = await _auth.signInAnon();
            if(result == null) {
              print('Error');
            } else {
              print('Signed in');
              print(result.uid);
            }
          }
        )
      )
    );
  }
}