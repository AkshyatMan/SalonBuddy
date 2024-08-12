import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  // Update barbershop details
  Future<void> updateBarbershop() async {
    setState(() {
      isLoading = true;
    });

    final apiUrl =
        'http://192.168.10.80:8000/api/barbershops/${widget.barbershopId}/update/';
    final Map<String, dynamic> updatedData = {
      'name': nameController.text,
      'address': addressController.text,
      'in_service': inService,
    };

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedData),
      );

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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Update Barbershop'),
        ),
        body: isLoading // Show loading indicator while fetching data
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(labelText: 'Address'),
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
                        ),
                        Text('In Service'),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        updateBarbershop();
                      },
                      child: Text('Update Barbershop'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
