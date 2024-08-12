import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:salonbuddy/Pages/Barber/appointment.dart';

class ApproveAppointmentPage extends StatefulWidget {
  final int barbershopId;
  final int appointmentId;
  final String accessToken;

  const ApproveAppointmentPage({
    Key? key,
    required this.barbershopId,
    required this.appointmentId,
    required this.accessToken,
  }) : super(key: key);

  @override
  _ApproveAppointmentPageState createState() => _ApproveAppointmentPageState();
}

class _ApproveAppointmentPageState extends State<ApproveAppointmentPage> {
  bool isLoading = false;

  Future<void> verifyAppointment() async {
    setState(() {
      isLoading = true;
    });

    final url =
        'http://192.168.10.80:8000/api/barbershops/${widget.barbershopId}/appointments/${widget.appointmentId}/';
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'verified': true}),
      );

      if (response.statusCode == 200) {
        // If the update is successful, navigate to the Appointments Page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentsPage(
              barbershopId: widget.barbershopId,
              accessToken: widget.accessToken,
            ),
          ),
          (Route<dynamic> route) => false, // No back navigation to this page
        );
      } else {
        // Handle non-200 status codes
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to verify appointment. Please try again.'),
          ),
        );
      }
    } catch (e) {
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying appointment. Please try again.'),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Verify Appointment', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black, // Set app bar background color
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[900], // Set background color
        child: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: verifyAppointment,
                  child: Text('Verify Appointment',
                      style: TextStyle(color: Colors.white)), // Set text color
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple, // Set button color
                  ),
                ),
        ),
      ),
    );
  }
}
