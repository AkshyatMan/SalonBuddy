import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:salonbuddy/Pages/Customer/Cust_barbershop.dart';
import 'package:salonbuddy/Pages/auth/loginPage.dart';

class BarbershopListPage extends StatefulWidget {
  final String accessToken;

  BarbershopListPage({required this.accessToken});

  @override
  _BarbershopListPageState createState() => _BarbershopListPageState();
}

class _BarbershopListPageState extends State<BarbershopListPage> {
  List<dynamic> barbershops = [];
  List<dynamic> filteredBarbershops = [];
  String dropdownValue = 'Name'; // Default sorting option

  @override
  void initState() {
    super.initState();
    fetchBarbershops();
  }

  Future<void> fetchBarbershops() async {
    final apiUrl =
        'http://192.168.10.80:8000/api/barbershops/in-service-barbershops/';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          barbershops = json.decode(response.body);
          filteredBarbershops = List.from(barbershops);
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

  void sortBarbershops() {
    setState(() {
      switch (dropdownValue) {
        case 'Name':
          // Sort by name
          filteredBarbershops.sort((a, b) => a['name'].compareTo(b['name']));
          break;
        case 'Address':
          filteredBarbershops
              .sort((a, b) => a['address'].compareTo(b['address']));
          break;
        // Add more cases for additional sorting options
      }
    });
  }

  void searchBarbershops(String query) {
    setState(() {
      filteredBarbershops = barbershops
          .where((barbershop) =>
              barbershop['name'].toLowerCase().contains(query.toLowerCase()) ||
              barbershop['address'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void navigateToBarbershopDetailsPage(
      BuildContext context, dynamic barbershop) {
    // Implement navigation logic to barbershop details page
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

  Future<void> logout(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Barbershops',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          // Search Bar
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () async {
              final String? result = await showSearch(
                context: context,
                delegate: BarberShopSearchDelegate(
                  barbershops: filteredBarbershops,
                  navigateToBarbershopDetailsPage:
                      navigateToBarbershopDetailsPage,
                ),
              );
              if (result != null) {
                searchBarbershops(result);
              }
            },
          ),
          // Sorting Dropdown Button
          DropdownButton<String>(
            value: dropdownValue,
            icon: Icon(Icons.sort, color: Colors.white),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  dropdownValue = newValue;
                  sortBarbershops();
                });
              }
            },
            dropdownColor: const Color.fromARGB(255, 37, 36, 36),
            items: <String>['Name', 'Address'] // Add more sorting options
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[850], // Set background color of the container
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: filteredBarbershops.length,
                  itemBuilder: (context, index) {
                    final barbershop = filteredBarbershops[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: Card(
                        elevation: 2.0,
                        color: Colors
                            .grey[700], // Set background color of the card
                        child: ListTile(
                          leading: Icon(
                            Icons
                                .storefront, // Choose an appropriate icon from the available options
                            color: Colors.white, // Set the icon color
                          ),
                          title: Text(
                            barbershop['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Set text color to white
                            ),
                          ),
                          subtitle: Text(
                            barbershop['address'],
                            style: TextStyle(
                                color: Colors.white), // Set text color to white
                          ),
                          onTap: () {
                            navigateToBarbershopDetailsPage(
                                context, barbershop);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Search Delegate for AppBar Search
class BarberShopSearchDelegate extends SearchDelegate<String> {
  final List<dynamic> barbershops;
  final Function(BuildContext context, dynamic barbershop)
      navigateToBarbershopDetailsPage;

  BarberShopSearchDelegate({
    required this.barbershops,
    required this.navigateToBarbershopDetailsPage,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredBarbershops = query.isEmpty
        ? barbershops
        : barbershops
            .where((barbershop) =>
                barbershop['name']
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                barbershop['address']
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();

    return Container(
      color: Colors.grey[850], // Set background color of the container
      child: ListView.builder(
        itemCount: filteredBarbershops.length,
        itemBuilder: (context, index) {
          final barbershop = filteredBarbershops[index];
          return Card(
            elevation: 2.0,
            color: Color.fromARGB(
                255, 155, 148, 148), // Set background color of the card
            child: ListTile(
              title: Text(
                barbershop['name'],
                style: TextStyle(
                    color: Colors.white), // Change text color to white
              ),
              subtitle: Text(
                barbershop['address'],
                style: TextStyle(
                    color: Colors.white), // Change text color to white
              ),
              onTap: () {
                navigateToBarbershopDetailsPage(context, barbershop);
              },
            ),
          );
        },
      ),
    );
  }
}
