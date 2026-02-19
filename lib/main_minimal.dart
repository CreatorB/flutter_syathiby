import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'MINIMAL APP WORKING',
            style: TextStyle(fontSize: 32, color: Colors.blue),
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    ),
  );
}
