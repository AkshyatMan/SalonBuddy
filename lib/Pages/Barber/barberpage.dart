import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:salonbuddy/Pages/Barber/createbarberpage.dart';

class BarberPage extends StatefulWidget {
  final int barbershopId;
  final String accessToken;

  BarberPage({required this.barbershopId, required this.accessToken});

  @override
  _BarberPageState createState() => _BarberPageState();
}

class _BarberPageState extends State<BarberPage> {
  List<dynamic> barbers = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchBarbers();
  }

  Future<void> fetchBarbers() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.10.80:8000/api/barbershop/${widget.barbershopId}/barbers/'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          barbers = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load barbers');
      }
    } catch (e) {
      print('Error fetching barbers: $e');
      setState(() {
        isLoading = false;
        error = 'Failed to fetch barbers: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Barbers',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[800],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text(
                    error!,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : barbers.isEmpty
                  ? Center(
                      child: Text(
                        'No barbers found.',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: barbers.length,
                      itemBuilder: (context, index) {
                        final barber = barbers[index];
                        return Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white),
                          ),
                          child: ListTile(
                            title: Text(
                              'Barber ID: ${barber['id']}',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${barber['name']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Phone: ${barber['phone_number']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Address: ${barber['address']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Handle onTap
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateBarberPage(
                accessToken: widget.accessToken,
                barbershopId: widget.barbershopId,
              ),
            ),
          ).then((_) {
            fetchBarbers(); // Refresh the list of barbers after creating a new one
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
