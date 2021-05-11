import 'package:VirQ/services/auth.dart';
import 'package:VirQ/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:VirQ/shared/constants.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;
  SignIn({ this.toggleView });

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.green[900],
      
      body: Container(
        margin: EdgeInsets.only(left:50, right:50, top:200, bottom: 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Email', hintStyle: TextStyle(color: Colors.grey)),
                style: TextStyle(color: Colors.white),
                validator: (val) => val.isEmpty ? 'Enter an email' : null,
                onChanged: (val) {
                  setState(() => email = val);

                }
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Password', hintStyle: TextStyle(color: Colors.grey)),
                style: TextStyle(color: Colors.white),
                validator: (val) => val.length < 6 ? 'Enter a password with atleast 6 characters' : null,
                obscureText: true,
                onChanged: (val) {
                  setState(() => password = val);

                }
              ),
              SizedBox(height: 12.0),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              ),

              SizedBox(height: 20.0),
              RaisedButton(
                color: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()){
                    
                    setState(() => loading = true);
                    dynamic result = await _auth.signInWithEmailAndPassword(email, password);

                    if(result == null) {
                      setState(() {
                        error = 'Please provide valid credentials';
                        loading = false;
                      });

                    }
                  }

                }
              ),
              SizedBox(height: 20.0),
              RaisedButton(
                elevation: 0,
                hoverElevation: 0,
                focusElevation: 0,
                highlightElevation: 0,
                color: Colors.green[900],
                child: Text(
                  'New here? Sign Up',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  widget.toggleView();
                }
              ),
              
            ],
          )
        )
        )
    );
  }
}