import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:salonbuddy/Pages/auth/loginPage.dart';
import 'notification_service.dart'; // Import your notification service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
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
