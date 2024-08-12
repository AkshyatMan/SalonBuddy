import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:salonbuddy/Pages/Barber/approveappointmentpage.dart';
import 'package:salonbuddy/Pages/Barber/barbershop_appointmentpage.dart';

class AppointmentsPage extends StatefulWidget {
  final int barbershopId;
  final String accessToken;

  AppointmentsPage({
    required this.barbershopId,
    required this.accessToken,
  });

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
          'http://192.168.10.80:8000/api/barber-appointments/${widget.barbershopId}/not_verified/';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          appointments = json.decode(response.body);
        });
      } else {
        throw Exception(
            'Failed to load appointments. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching appointments: $e');
      throw Exception('Error fetching appointments');
    }
  }

  Future<dynamic> fetchCustomer(int customerId) async {
    final apiUrl = 'http://192.168.10.80:8000/api/users/$customerId/';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load customer details. Status Code: ${response.statusCode}');
    }
  }

  Future<String> fetchBarberName(int barberId) async {
    final apiUrl =
        'http://192.168.10.80:8000/api/barbershop/${widget.barbershopId}/barbers/$barberId/';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> barberData = json.decode(response.body);
      return barberData['name'];
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
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BarberAppointmentsPage(
                    barbershopId: widget.barbershopId,
                    accessToken: widget.accessToken,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          final DateTime dateTime = DateTime.parse(appointment['date_time']);
          final formattedDateTime =
              '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
          final styleOfCut = appointment['style_of_cut'];

          return FutureBuilder(
            future: Future.wait([
              fetchCustomer(appointment['customer']),
              fetchBarberName(appointment['barber']),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white),
                );
              } else {
                final customer = snapshot.data?[0];
                final barberName = snapshot.data?[1];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApproveAppointmentPage(
                          barbershopId: widget.barbershopId,
                          appointmentId: appointment['id'],
                          accessToken: widget.accessToken,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(
                      'Appointment ID: ${appointment['id']}',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Date and Time: $formattedDateTime\nCustomer: ${customer['username']}\nBarber: $barberName\nStyle of Cut: $styleOfCut',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
      backgroundColor: Colors.grey[900],
    );
  }
}
