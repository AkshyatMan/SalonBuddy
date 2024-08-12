import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:salonbuddy/Pages/Barber/Barbershopdetail.dart';
import 'package:salonbuddy/Pages/Barber/CreateBarbershopPage.dart';
import 'package:salonbuddy/Pages/auth/Profile.dart';
import 'package:salonbuddy/Pages/auth/loginPage.dart';

class BHomePage extends StatefulWidget {
  final String accessToken;

  BHomePage({required this.accessToken});

  @override
  _BHomePageState createState() => _BHomePageState();
}

class _BHomePageState extends State<BHomePage> {
  int _selectedIndex = 0;
  List<dynamic> barbershops = [];

  @override
  void initState() {
    super.initState();
    fetchBarbershops();
  }

  Future<void> fetchBarbershops() async {
    try {
      final userId = extractUserIdFromToken(widget.accessToken);
      final apiUrl = 'http://192.168.10.80:8000/api/barbershops/user/$userId/';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          barbershops = json.decode(response.body);
        });
      } else {
        throw Exception(
            'Failed to load barbershops. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching barbershops: $e');
      throw Exception('Error fetching barbershops');
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
      return payloadMap['user_id'] ??
          payloadMap['id']; // Try 'user_id' first, fallback to 'id'
    } catch (e) {
      print('Error decoding access token:');
      print('Token: $accessToken');
      print('Error: $e');
      rethrow;
    }
  }

  Future<void> deleteBarbershop(String id) async {
    final response = await http.delete(
      Uri.parse('http://192.168.10.80:8000/api/barbershops/$id/delete/'),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );

    if (response.statusCode == 204) {
      fetchBarbershops();
    } else {
      throw Exception('Failed to delete barbershop');
    }
  }

  Future<void> navigateToCreateBarbershopPage(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CreateBarbershopPage(
          accessToken: widget.accessToken,
        ),
      ),
    );
  }

  Future<void> navigateToBarbershopDetailsPage(
      BuildContext context, dynamic barbershop) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarbershopDetailsPage(
          barbershopId: barbershop['id'],
          accessToken: widget.accessToken,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Barberboss',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: Colors.white,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[900],
        child: _getSelectedWidget(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[500],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Barbershops',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create Barbershop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _getSelectedWidget() {
    switch (_selectedIndex) {
      case 0:
        return _buildBarbershopsWidget();
      case 1:
        return SizedBox.shrink();
      case 2:
        return ProfilePage(accessToken: widget.accessToken);
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildBarbershopsWidget() {
    return ListView.builder(
      itemCount: barbershops.length,
      itemBuilder: (context, index) {
        final barbershop = barbershops[index];
        return Card(
          color: Colors
              .grey[850], // Slightly lighter than the background for contrast
          margin: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            title: Text(barbershop['name'],
                style: TextStyle(color: Colors.white, fontSize: 18)),
            subtitle: Text(barbershop['address'],
                style: TextStyle(color: Colors.white70)),
            onTap: () => navigateToBarbershopDetailsPage(context, barbershop),
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete Barbershop'),
                    content: Text(
                        'Are you sure you want to delete this barbershop?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel',
                            style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          deleteBarbershop(barbershop['id'].toString());
                        },
                        child:
                            Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                    backgroundColor: Colors.black,
                    titleTextStyle:
                        TextStyle(color: Colors.white, fontSize: 20),
                    contentTextStyle: TextStyle(color: Colors.white70),
                  );
                },
              );
            },
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: Icon(Icons.store, color: Colors.white, size: 30),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (index != 1) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      navigateToCreateBarbershopPage(context);
    }
  }
}
