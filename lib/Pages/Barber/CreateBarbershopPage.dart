import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:salonbuddy/Pages/Barber/bhomepage.dart';

class CreateBarbershopPage extends StatefulWidget {
  final String accessToken;
  CreateBarbershopPage({required this.accessToken});

  @override
  _CreateBarbershopPageState createState() => _CreateBarbershopPageState();
}

class _CreateBarbershopPageState extends State<CreateBarbershopPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;
  File? _image;

  Future<void> createBarbershop(BuildContext context) async {
    try {
      final int userId = extractUserIdFromToken(widget.accessToken);
      final String apiUrl =
          'http://192.168.10.80:8000/api/barbershops/create/$userId/';

      final uri = Uri.parse(apiUrl);

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer ${widget.accessToken}';

      request.fields['name'] = nameController.text;
      request.fields['address'] = addressController.text;
      request.fields['opening_time'] = openingTime != null
          ? '${openingTime!.hour}:${openingTime!.minute}'
          : '';
      request.fields['closing_time'] = closingTime != null
          ? '${closingTime!.hour}:${closingTime!.minute}'
          : '';
      request.fields['userId'] = userId.toString();

      if (_image != null) {
        final file = await http.MultipartFile.fromPath('image', _image!.path);
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        // Barbershop created successfully
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BHomePage(
              accessToken: widget.accessToken,
            ),
          ),
        );
      } else {
        // Show error message if failed
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to create barbershop'),
        ));
      }
    } catch (e) {
      print('Error creating barbershop: $e');
      // Show error message if failed
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to create barbershop'),
      ));
    }
  }

  int extractUserIdFromToken(String accessToken) {
    try {
      final parts = accessToken.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid access token');
      }
      final payload = parts[1];
      final decodedPayload = base64Url.decode(base64.normalize(payload));
      final Map<String, dynamic> payloadMap =
          json.decode(utf8.decode(decodedPayload));
      return payloadMap['userId'] ?? payloadMap['id'];
    } catch (e) {
      print('Error decoding access token:');
      print('Token: $accessToken');
      print('Error: $e');
      rethrow;
    }
  }

  Future<void> _selectOpeningTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        openingTime = selectedTime;
      });
    }
  }

  Future<void> _selectClosingTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        closingTime = selectedTime;
      });
    }
  }

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _clearImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Barbershop',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BHomePage(
                  accessToken: widget.accessToken,
                ),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Opening Time:', style: TextStyle(color: Colors.white)),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _selectOpeningTime(context),
                    child: Text(
                      openingTime != null
                          ? '${openingTime!.hour}:${openingTime!.minute}'
                          : 'Select Time',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[500],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Closing Time:  ',
                      style: TextStyle(color: Colors.white)),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _selectClosingTime(context),
                    child: Text(
                      closingTime != null
                          ? '${closingTime!.hour}:${closingTime!.minute}'
                          : 'Select Time',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[500],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _image == null
                  ? ElevatedButton(
                      onPressed: _getImage,
                      child: Text('Choose Image',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[500],
                      ),
                    )
                  : Column(
                      children: [
                        Image.file(_image!),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _clearImage,
                          child: Text('Clear Image',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[500],
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  createBarbershop(context);
                },
                child: Text('Create Barbershop',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[500],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[900],
    );
  }
}
