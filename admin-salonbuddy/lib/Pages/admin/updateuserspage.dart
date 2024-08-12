import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateUserPage extends StatefulWidget {
  final int userId;

  UpdateUserPage({required this.userId});

  @override
  _UpdateUserPageState createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final response = await http.get(
      Uri.parse('http://192.168.10.80:8000/api/users/${widget.userId}'),
    );
    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      setState(() {
        _usernameController.text = userData['username'];
        _emailController.text = userData['email'];
        _phoneController.text = userData['phone'];
        _addressController.text = userData['address'];
      });
    } else {
      print('Failed to fetch user details: ${response.statusCode}');
    }
  }

  Future<void> updateUserDetails() async {
    final response = await http.patch(
      Uri.parse('http://192.168.10.80:8000/api/users/${widget.userId}/update/'),
      body: {
        'username': _usernameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
      },
    );
    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      print('Failed to update user details: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update User Details',
          style: TextStyle(color: Color.fromARGB(255, 190, 183, 183)),
        ),
        backgroundColor: Colors.black, // Dark app bar color
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              style: TextStyle(color: Colors.white), // Text color
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.white), // Label color
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              style: TextStyle(color: Colors.white), // Text color
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white), // Label color
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              style: TextStyle(color: Colors.white), // Text color
              decoration: InputDecoration(
                labelText: 'Phone',
                labelStyle: TextStyle(color: Colors.white), // Label color
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _addressController,
              style: TextStyle(color: Colors.white), // Text color
              decoration: InputDecoration(
                labelText: 'Address',
                labelStyle: TextStyle(color: Colors.white), // Label color
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updateUserDetails();
              },
              child: Text('Update'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    const Color.fromARGB(255, 166, 33, 243), // Text color
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black, // Dark background color
    );
  }
}
