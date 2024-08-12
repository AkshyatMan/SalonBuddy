import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:salonbuddy/Pages/Customer/C_appointment.dart';
import 'package:salonbuddy/Pages/Customer/barbershoplist.dart';
import 'package:salonbuddy/Pages/auth/ProfileCustomer.dart';

class ChomePage extends StatefulWidget {
  final String accessToken;

  ChomePage({required this.accessToken});

  @override
  _ChomePageState createState() => _ChomePageState();
}

class _ChomePageState extends State<ChomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  late int _userId;

  @override
  void initState() {
    super.initState();
    // Decode the access token to extract the user ID
    final Map<String, dynamic> tokenPayload = Jwt.parseJwt(widget.accessToken);
    _userId = tokenPayload['id'];

    // Initialize the pages list
    _pages = [
      BarbershopListPage(accessToken: widget.accessToken),
      AppointmentsPage(accessToken: widget.accessToken, userId: _userId),
      CProfilePage(accessToken: widget.accessToken),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: Color.fromARGB(255, 255, 255, 255),
        unselectedItemColor:
            Color.fromARGB(255, 255, 253, 253).withOpacity(0.5),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Barbershops',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
