import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:salonbuddy/Pages/Barber/Barbershopdetail.dart';

class ManageBarbershopPage extends StatefulWidget {
  final String accessToken;

  ManageBarbershopPage({required this.accessToken});

  @override
  _ManageBarbershopPageState createState() => _ManageBarbershopPageState();
}

class _ManageBarbershopPageState extends State<ManageBarbershopPage> {
  late String _searchQuery = '';
  late Future<List<Map<String, dynamic>>> _barbershopsFuture;

  @override
  void initState() {
    super.initState();
    _barbershopsFuture = _fetchBarbershops();
  }

  Future<List<Map<String, dynamic>>> _fetchBarbershops() async {
    final response = await http.get(
      Uri.parse('http://192.168.10.80:8000/api/barbershops/'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load barbershops');
    }
  }

  Future<Map<String, dynamic>> _fetchUser(int userId) async {
    final response = await http.get(
      Uri.parse('http://192.168.10.80:8000/api/users/$userId/'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load user details');
    }
  }

  List<Map<String, dynamic>> _filterBarbershops(
      List<Map<String, dynamic>> barbershops) {
    if (_searchQuery.isEmpty) {
      return barbershops;
    } else {
      return barbershops.where((barbershop) {
        return barbershop['name']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            barbershop['address']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by name or address',
              hintStyle: TextStyle(color: Colors.white70),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _barbershopsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Map<String, dynamic>> barbershops =
                  _filterBarbershops(snapshot.data!);
              return ListView.builder(
                itemCount: barbershops.length,
                itemBuilder: (context, index) {
                  final barbershop = barbershops[index];
                  final int userId = barbershop['user_id'];
                  late Future<Map<String, dynamic>> userFuture =
                      _fetchUser(userId);

                  return FutureBuilder<Map<String, dynamic>>(
                    future: userFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(title: Text('Loading...'));
                      } else if (snapshot.hasError) {
                        return ListTile(
                            title: Text('Error: ${snapshot.error}'));
                      } else {
                        final user = snapshot.data!;
                        return Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ListTile(
                            title: Text(barbershop['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(barbershop['address']),
                                SizedBox(height: 4),
                                Text('Owner: ${user['username']}'),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BarbershopDetailsPage(
                                    barbershopId: barbershop['id'],
                                    accessToken: widget.accessToken,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
