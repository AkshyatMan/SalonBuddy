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
        title: Text('Create Style of Cut'),
      ),
      body: Center(
        child: CreateStyleOfCutForm(
          barbershopId: barbershopId,
          accessToken: accessToken,
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
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _priceController,
            decoration: InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the price';
              }
              return null;
            },
          ),
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
        ),
      );
      return false;
    }
  }
}
