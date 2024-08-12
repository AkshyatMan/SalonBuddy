import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateStyleOfCutPage extends StatelessWidget {
  final int barbershopId;
  final String accessToken;

  CreateStyleOfCutPage({
    required this.barbershopId,
    required this.accessToken,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Style of Cut',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black, // Set app bar background color
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.white), // Set back button color
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.grey[900], // Set background color
        child: Center(
          child: CreateStyleOfCutForm(
            barbershopId: barbershopId,
            accessToken: accessToken,
          ),
        ),
      ),
    );
  }
}

class CreateStyleOfCutForm extends StatefulWidget {
  final int barbershopId;
  final String accessToken;

  CreateStyleOfCutForm({
    required this.barbershopId,
    required this.accessToken,
  });

  @override
  _CreateStyleOfCutFormState createState() => _CreateStyleOfCutFormState();
}

class _CreateStyleOfCutFormState extends State<CreateStyleOfCutForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            style: TextStyle(color: Colors.white), // Set text color
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: Colors.white), // Set label color
              border: OutlineInputBorder(
                // Add border
                borderSide: BorderSide(color: Colors.white), // Set border color
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the name';
              }
              return null;
            },
          ),
          SizedBox(height: 16), // Add spacing between text fields
          TextFormField(
            controller: _priceController,
            style: TextStyle(color: Colors.white), // Set text color
            decoration: InputDecoration(
              labelText: 'Price',
              labelStyle: TextStyle(color: Colors.white), // Set label color
              border: OutlineInputBorder(
                // Add border
                borderSide: BorderSide(color: Colors.white), // Set border color
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the price';
              }
              return null;
            },
          ),
          SizedBox(height: 16), // Add spacing between text fields
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _createStyleOfCut().then((success) {
                  if (success) {
                    // Navigate back to the previous page
                    Navigator.pop(context);
                  }
                });
              }
            },
            child: Text('Submit'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.purple, // Set text color
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _createStyleOfCut() async {
    try {
      final apiUrl =
          'http://192.168.10.80:8000/api/${widget.barbershopId}/style-of-cut/create/';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'barbershop': widget.barbershopId,
          'name': _nameController.text,
          'price': double.parse(_priceController.text),
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Style of cut created successfully.'),
            backgroundColor: Colors.grey[800], // Set SnackBar background color
          ),
        );
        // Clear form fields after successful creation
        _nameController.clear();
        _priceController.clear();
        return true;
      } else {
        throw Exception('Failed to create style of cut');
      }
    } catch (e) {
      print('Error creating style of cut: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating style of cut.'),
          backgroundColor: Colors.red, // Set SnackBar background color
        ),
      );
      return false;
    }
  }
}
