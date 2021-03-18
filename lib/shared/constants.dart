import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  hintStyle: TextStyle(color: Colors.white),
  border: OutlineInputBorder(),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.orange, width: 2.0)
    ),
    enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.green, width: 2.0)
  ),
);

