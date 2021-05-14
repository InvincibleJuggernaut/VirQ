import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF008604),
      child: Center(
        child: SpinKitFadingCube(
          color: Color(0xFF00EE45),
          size: 50.0,
        ),
      )
    );
  }
}