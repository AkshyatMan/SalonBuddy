import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
        Navigator.pop(context, true); // Assuming success leads to pop
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
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Verify Appointment'),
        ),
        body: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: verifyAppointment,
                  child: Text('Verify Appointment'),
                ),
        ),
      ),
    );
  }
}
