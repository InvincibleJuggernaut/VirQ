import 'package:VirQ/services/auth.dart';
import 'package:VirQ/shared/constants.dart';
import 'package:VirQ/shared/loading.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {

  final Function toggleView;
  Register({ this.toggleView });


  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

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
      backgroundColor: Color(0xFF008604),
      
      body: Container(
        margin: EdgeInsets.only(left:50, right:50, top:200, bottom: 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Email', hintStyle: TextStyle(color: Color(0xFF470045))),
                style: TextStyle(color: Colors.white),
                validator: (val) => val.isEmpty ? 'Enter an email' : null,
                onChanged: (val) {
                  setState(() => email = val);

                }
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Password', hintStyle: TextStyle(color: Color(0xFF470045))),
                style: TextStyle(color: Colors.white),
                obscureText: true,
                validator: (val) => val.length < 6 ? 'Enter a password with atleast 6 characters' : null,
                onChanged: (val) {
                  setState(() => password = val);

                }
              ),
              SizedBox(height: 12.0),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              ),

              SizedBox(height: 20.0, width: 30.0),
              RaisedButton(
                padding: EdgeInsets.fromLTRB(27, 10, 27, 10),
                color: Color(0xFF470045),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()){
                    setState(() => loading = true);
                    dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                    if(result == null) {
                      setState(() {
                        error = 'Please provide a valid email';
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
                color: Color(0xFF008604),
                child: Text(
                  'Already have an account? Sign In',
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