import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:salonbuddy/Pages/Customer/ratingspage.dart';

class AppointmentsPage extends StatefulWidget {
  final String accessToken;
  final int userId;

  AppointmentsPage({required this.accessToken, required this.userId});

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  List<dynamic> appointments = [];

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      final apiUrl =
          'http://192.168.10.80:8000/api/verified-appointments/${widget.userId}/';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          appointments = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      print('Error fetching appointments: $e');
      throw Exception('Error fetching appointments');
    }
  }

  Future<String> fetchBarbershopName(int barbershopId) async {
    final apiUrl = 'http://192.168.10.80:8000/api/barbershops/$barbershopId/';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> barbershop = json.decode(response.body);
      return barbershop['name'];
    } else {
      throw Exception('Failed to load barbershop name');
    }
  }

  Future<String> fetchBarberName(int barbershopId, int barberId) async {
    final apiUrl =
        'http://192.168.10.80:8000/api/barbershop/$barbershopId/barbers/$barberId/';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> barber = json.decode(response.body);
      return barber['name'];
    } else {
      throw Exception('Failed to load barber name');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appointments',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[850], // Set container color to grey
        child: ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            final DateTime dateTime = DateTime.parse(appointment['date_time']);
            final formattedDateTime =
                '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';

            return GestureDetector(
              onTap: () {
                // Navigate to the rating page when tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentRatingPage(
                        appointmentId: appointment['id'],
                        barbershop: appointment['barbershop'],
                        userId: widget.userId,
                        // barberId: appointment['barber'],
                        accessToken: widget.accessToken // Pass barbershopId
                        ),
                  ),
                );
              },
              child: Card(
                elevation: 2.0,
                color: Colors.grey[700], // Set card color to lighter grey
                child: ListTile(
                  title: Text(
                    'Appointment ID: ${appointment['id']}',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: FutureBuilder(
                    future: Future.wait([
                      fetchBarbershopName(appointment['barbershop']),
                      fetchBarberName(
                          appointment['barbershop'], appointment['barber']),
                    ]),
                    builder: (context, AsyncSnapshot<List<String>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.white),
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date and Time: $formattedDateTime',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Barbershop: ${snapshot.data![0]}',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Barber: ${snapshot.data![1]}',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Style of Cut: ${appointment['style_of_cut']}',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              appointment['rating'] != null
                                  ? 'Rating: ${appointment['rating']}'
                                  : 'Please rate the appointment',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
