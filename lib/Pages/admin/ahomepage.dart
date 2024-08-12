import 'package:flutter/material.dart';
import 'package:salonbuddy/Pages/auth/Profile.dart';
import 'package:salonbuddy/Pages/auth/loginPage.dart'; // Assuming LoginPage is in Login.dart

class AHomePage extends StatelessWidget {
  final String accessToken;

  AHomePage({required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Admin Page!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Profile page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(accessToken: accessToken),
                  ),
                );
              },
              child: Text('Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                // Logout and navigate back to the login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
