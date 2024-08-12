import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class UpdateBarbershopPage extends StatefulWidget {
  final int barbershopId;
  final String accessToken;

  UpdateBarbershopPage({
    required this.barbershopId,
    required this.accessToken,
  });

  @override
  _UpdateBarbershopPageState createState() => _UpdateBarbershopPageState();
}

class _UpdateBarbershopPageState extends State<UpdateBarbershopPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool inService = true; // Default to true
  bool isLoading = true; // Initially set to true to indicate loading
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;
  File? _image;

  @override
  void initState() {
    super.initState();
    fetchBarbershopDetails();
  }

  // Fetch barbershop details from the API
  Future<void> fetchBarbershopDetails() async {
    try {
      final apiUrl =
          'http://192.168.10.80:8000/api/barbershops/${widget.barbershopId}/';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nameController.text = data['name'];
          addressController.text = data['address'];
          inService = data['in_service'];
          isLoading = false; // Set loading to false once data is fetched
        });
      } else {
        throw Exception(
            'Failed to load barbershop details. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching barbershop details: $e');
    }
  }

  Future<void> updateBarbershop() async {
    setState(() {
      isLoading = true;
    });

    final apiUrl =
        'http://192.168.10.80:8000/api/barbershops/${widget.barbershopId}/update/';
    final uri = Uri.parse(apiUrl);
    final request = http.MultipartRequest('PATCH', uri);
    request.headers['Authorization'] = 'Bearer ${widget.accessToken}';

    // Add other data
    request.fields['name'] = nameController.text;
    request.fields['address'] = addressController.text;
    request.fields['in_service'] = inService.toString();

    // Add opening and closing time if they are not null
    if (openingTime != null) {
      request.fields['opening_time'] =
          '${openingTime!.hour}:${openingTime!.minute}';
    }
    if (closingTime != null) {
      request.fields['closing_time'] =
          '${closingTime!.hour}:${closingTime!.minute}';
    }

    // Add image file if available
    if (_image != null) {
      final file = await http.MultipartFile.fromPath('image', _image!.path);
      request.files.add(file);
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Barbershop updated successfully
        Navigator.pop(context, true); // Navigate back with success status
      } else {
        throw Exception(
            'Failed to update barbershop. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating barbershop: $e');
      // Handle error
    }

    setState(() {
      isLoading = false;
    });
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
        title: Text(
          'Update Barbershop',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black, // Set the app bar background color
      ),
      body: Container(
        color: Colors.grey[850], // Set the page background color
        child: isLoading // Show loading indicator while fetching data
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: nameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextField(
                        controller: addressController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Address',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Checkbox(
                            value: inService,
                            onChanged: (newValue) {
                              setState(() {
                                inService = newValue!;
                              });
                            },
                            fillColor: MaterialStateProperty.all(Colors.black),
                          ),
                          Text(
                            'In Service',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _selectOpeningTime(context),
                            child: Text(
                              'Select Opening Time',
                              style: TextStyle(
                                  color: Colors.white), // Text color white
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.purple),
                              // Set button color purple
                            ),
                          ),
                          SizedBox(width: 16.0),
                          ElevatedButton(
                            onPressed: () => _selectClosingTime(context),
                            child: Text(
                              'Select Closing Time',
                              style: TextStyle(
                                  color: Colors.white), // Text color white
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.purple),
                              // Set button color purple
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      if (_image ==
                          null) // Show the "Choose Image" button if no image is selected
                        ElevatedButton(
                          onPressed: _getImage,
                          child: Text('Choose Image'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.purple), // Set button color purple
                            foregroundColor: MaterialStateProperty.all(
                                Colors.white), // Set text color white
                          ),
                        ),
                      if (_image !=
                          null) // Show the "Clear Image" button if an image is selected
                        ElevatedButton(
                          onPressed: _clearImage,
                          child: Text('Clear Image'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.purple), // Set button color purple
                            foregroundColor: MaterialStateProperty.all(
                                Colors.white), // Set text color white
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          updateBarbershop();
                        },
                        child: Text('Update Barbershop'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Colors.purple), // Set button color purple
                          foregroundColor: MaterialStateProperty.all(
                              Colors.white), // Set text color white
                        ),
                      ),
                      SizedBox(
                        height: _image != null ? 16.0 : 0,
                        child: Container(
                          color: Colors.grey[850], // Set background color
                        ),
                      ),
                      if (_image != null) // Show the image if it's not null
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          child: Image.file(_image!),
                        ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
