import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salonbuddy/Pages/Customer/CreateAppointment.dart'; // Import your create appointment page

class BarbershopDetailsPage extends StatefulWidget {
  final int barbershopId;
  final String accessToken;

  BarbershopDetailsPage({
    required this.barbershopId,
    required this.accessToken,
  });

  @override
  _BarbershopDetailsPageState createState() => _BarbershopDetailsPageState();
}

class _BarbershopDetailsPageState extends State<BarbershopDetailsPage> {
  late Future<String?> _phoneNumberFuture;
  late Future<String?> _imagePathFuture;

  @override
  void initState() {
    super.initState();
    _phoneNumberFuture = _getUserPhoneNumber(widget.barbershopId);
    _imagePathFuture = _getBarbershopImagePath(widget.barbershopId);
  }

  Future<String?> _getUserPhoneNumber(int barbershopId) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.10.80:8000/api/barbershops/$barbershopId'),
      );
      if (response.statusCode == 200) {
        final userId = json.decode(response.body)['user_id'];
        final userResponse = await http.get(
          Uri.parse('http://192.168.10.80:8000/api/users/$userId'),
        );
        if (userResponse.statusCode == 200) {
          return json.decode(userResponse.body)['phone'];
        } else {
          print('Failed to fetch phone number');
          return null;
        }
      } else {
        print('Failed to fetch user ID');
        return null;
      }
    } catch (e) {
      print('Error fetching phone number: $e');
      return null;
    }
  }

  Future<String?> _getBarbershopImagePath(int barbershopId) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.10.80:8000/api/barbershops/$barbershopId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body)['image'];
      } else {
        print('Failed to fetch barbershop image');
        return null;
      }
    } catch (e) {
      print('Error fetching barbershop image: $e');
      return null;
    }
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    if (phoneNumber.isNotEmpty) {
      if (await canLaunch('tel:$phoneNumber')) {
        await launch('tel:$phoneNumber');
      } else {
        print('Cannot launch phone app');
      }
    } else {
      print('Phone number is null or empty');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Barbershop Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.grey[850], // Dark background color
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 400,
            child: FutureBuilder<String?>(
              future: _imagePathFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final imagePath = snapshot.data;
                  if (imagePath != null) {
                    return _buildBarbershopImage(imagePath);
                  } else {
                    return Center(child: Text('Image not available'));
                  }
                }
              },
            ),
          ),
          SizedBox(height: 20),
          FutureBuilder<String?>(
            future: _phoneNumberFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final phoneNumber = snapshot.data;
                return ElevatedButton(
                  onPressed: () => _launchPhoneCall(phoneNumber ?? ''),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    backgroundColor: Colors.grey[600],
                    minimumSize: Size(double.infinity, 150),
                  ),
                  child: Text('Call Barbershop',
                      style: TextStyle(color: Colors.white)),
                );
              }
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateAppointmentPage(
                    barbershopId: widget.barbershopId,
                    accessToken: widget.accessToken,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              backgroundColor: Colors.grey[600],
              minimumSize: Size(double.infinity, 150),
            ),
            child: Text(
              'Create Appointment',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarbershopImage(String imageName) {
    // Remove the base URL part from the image path
    String imagePath = imageName.replaceAll('http://192.168.10.80:8000/', '');
    return Image.asset(
      'backend/$imagePath',
      fit: BoxFit.fill,
    );
  }
}
