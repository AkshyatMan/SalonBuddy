import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final String accessToken;

  ProfilePage({required this.accessToken});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> profileData = {};
  bool isLoading = true;

  Future<void> fetchProfileData(String token) async {
    final apiUrl = 'http://192.168.10.80:8000/api/profile/';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          profileData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print('Failed to fetch profile data');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData(widget.accessToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : profileData.isEmpty
              ? Center(child: Text('No profile data found'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Name: ${profileData['full_name']}',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Bio: ${profileData['bio']}',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Verified: ${profileData['verified'] ? 'Yes' : 'No'}',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      SizedBox(height: 10),
                      Image.network(
                        'http://192.168.10.80:8000/${profileData['image']}',
                        width: 200,
                        height: 200,
                      ),
                    ],
                  ),
                ),
    );
  }
}
