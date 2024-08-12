import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:salonbuddy/Pages/admin/ahomepage.dart';
import 'package:salonbuddy/Pages/auth/forget_Password.dart';
import 'package:salonbuddy/Pages/auth/register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final String apiUrl = 'http://192.168.10.80:8000/api/token/';

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String accessToken = responseData['access'];
      final Map<String, dynamic> payload = json.decode(utf8
          .decode(base64.decode(base64.normalize(accessToken.split(".")[1]))));
      final String role = payload['role'];

      if (role == 'customer') {
        _showErrorDialog(context, 'Only Admin Login Allowed.');
      } else if (role == 'barber') {
        _showErrorDialog(context, 'Only Admin Login Allowed.');
      } else if (role == 'admin') {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AHomePage(accessToken: accessToken)));
      } else {
        _showErrorDialog(context, 'You do not have permission to log in.');
      }
    } else {
      final dynamic responseData = json.decode(response.body);
      final String? errorMessage = responseData['detail'];
      _showErrorDialog(context, errorMessage ?? 'An unknown error occurred.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Failed'),
          content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(32),
              constraints: BoxConstraints(
                  maxWidth:
                      400), // Ensuring the container does not stretch too wide on large screens
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/barberboss.jpg',
                    width: 200, // Adjusted for web
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 20),
                  _buildTextField(_emailController, 'Email', false),
                  SizedBox(height: 20),
                  _buildTextField(_passwordController, 'Password', true),
                  SizedBox(height: 20),
                  _buildForgotPasswordButton(context),
                  SizedBox(height: 20),
                  _buildLoginButton(context),
                  SizedBox(height: 20),
                  _buildSignUpButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, bool obscureText) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey),
        ),
        filled: true,
        fillColor: Colors.white24,
      ),
      style: TextStyle(color: Colors.white),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
        },
        child: Text(
          "Forgot Password?",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              decoration: TextDecoration.underline),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _login(context),
      child: Text('Login'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RegisterPage()));
      },
      child: Text(
        "Don't have an account? Sign up",
        style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            decoration: TextDecoration.underline),
      ),
    );
  }
}
