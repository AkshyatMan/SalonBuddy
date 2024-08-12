import 'package:flutter/material.dart';
import 'package:salonbuddy/Pages/admin/managebarbershoppage.dart';
import 'package:salonbuddy/Pages/admin/userspage.dart';
import 'package:salonbuddy/Pages/auth/loginPage.dart'; // Assuming LoginPage is in Login.dart

class AHomePage extends StatelessWidget {
  final String accessToken;

  AHomePage({required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Admin Home Page',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            icon: Icon(Icons.logout),
            color: Colors.white,
          ),
        ],
      ),
      body: Container(
        color: Colors.black, // Dark background color
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ManageBarbershopPage(accessToken: accessToken),
                    ),
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/barbershop_background.jpg',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: Colors.black
                          .withOpacity(0.5), // Semi-transparent black overlay
                      child: Center(
                        child: Text(
                          'Manage Barbershops',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageUserPage()),
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/user_background.jpg',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: Colors.black
                          .withOpacity(0.5), // Semi-transparent black overlay
                      child: Center(
                        child: Text(
                          'Manage Users',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
