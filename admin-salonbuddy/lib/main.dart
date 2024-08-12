import 'package:flutter/material.dart';
import 'package:salonbuddy/Pages/auth/loginPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Django Authentication Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Set your authentication page as the home page
    );
  }
}
