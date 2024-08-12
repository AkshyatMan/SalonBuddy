import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:salonbuddy/Pages/auth/loginPage.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  String _selectedRole = 'customer'; // Default role

  String _usernameError = '';
  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';
  String _phoneError = '';
  String _addressError = '';

  Future<void> _register(BuildContext context) async {
    // Reset error messages
    setState(() {
      _usernameError = '';
      _emailError = '';
      _passwordError = '';
      _confirmPasswordError = '';
      _phoneError = '';
      _addressError = '';
    });

    // Perform validation
    if (_usernameController.text.trim().isEmpty) {
      setState(() {
        _usernameError = 'Username is required';
      });
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      return;
    }

    if (_confirmPasswordController.text.trim().isEmpty) {
      setState(() {
        _confirmPasswordError = 'Confirm password is required';
      });
      return;
    }

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      return;
    }

    // Construct the JSON payload including the selected role
    final Map<String, dynamic> requestBody = {
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'password2': _confirmPasswordController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'role': _selectedRole, // Include the selected role here
    };

    final String apiUrl = 'http://192.168.10.80:8000/api/register/';

    final response = await http.post(
      Uri.parse(apiUrl),
      body: json.encode(requestBody),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      // Registration failed
      // Parse error message from response and display
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String errorMessage = responseData['message'];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration Failed'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Set app bar background color
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.white), // Set icon color
            SizedBox(width: 8),
            Text('User Registration', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      backgroundColor: Colors.grey[900], // Set background color
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                style: TextStyle(color: Colors.white), // Set text color
                decoration: InputDecoration(
                  labelText: 'Username',
                  errorText: _usernameError,
                  labelStyle: TextStyle(color: Colors.white), // Set label color
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.black), // Set border color
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                style: TextStyle(color: Colors.white), // Set text color
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _emailError,
                  labelStyle: TextStyle(color: Colors.white), // Set label color
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.black), // Set border color
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                style: TextStyle(color: Colors.white), // Set text color
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: _passwordError,
                  labelStyle: TextStyle(color: Colors.white), // Set label color
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.black), // Set border color
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _confirmPasswordController,
                style: TextStyle(color: Colors.white), // Set text color
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  errorText: _confirmPasswordError,
                  labelStyle: TextStyle(color: Colors.white), // Set label color
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.black), // Set border color
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                style: TextStyle(color: Colors.white), // Set text color
                decoration: InputDecoration(
                  labelText: 'Phone',
                  errorText: _phoneError,
                  labelStyle: TextStyle(color: Colors.white), // Set label color
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.black), // Set border color
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _addressController,
                style: TextStyle(color: Colors.white), // Set text color
                decoration: InputDecoration(
                  labelText: 'Address',
                  errorText: _addressError,
                  labelStyle: TextStyle(color: Colors.white), // Set label color
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.black), // Set border color
                  ),
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
                items: ['customer', 'barber', 'admin']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: TextStyle(
                                color: const Color.fromARGB(
                                    255, 0, 0, 0))), // Set text color
                      ),
                    )
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(color: Colors.white), // Set label color
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.black), // Set border color
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _register(context),
                child: Text(
                  'Register',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Set button color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
