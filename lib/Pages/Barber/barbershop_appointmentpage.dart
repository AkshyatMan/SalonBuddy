import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:printing/printing.dart';

class BarberAppointmentsPage extends StatefulWidget {
  final int barbershopId;
  final String accessToken;

  BarberAppointmentsPage({
    required this.barbershopId,
    required this.accessToken,
  });

  @override
  _BarberAppointmentsPageState createState() => _BarberAppointmentsPageState();
}

class _BarberAppointmentsPageState extends State<BarberAppointmentsPage> {
  List<dynamic> appointments = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final apiUrl =
          'http://192.168.10.80:8000/api/barber-appointments/${widget.barbershopId}/verified/';
      final response = await http.get(Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer ${widget.accessToken}'});

      if (response.statusCode == 200) {
        setState(() {
          appointments = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      print('Error fetching appointments: $e');
      setState(() {
        isLoading = false;
        error = 'Failed to fetch appointments: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Barber Appointments', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black, // Set app bar background color
        actions: [
          IconButton(
            icon: Icon(Icons.print, color: Colors.white), // Set icon color
            onPressed: generatePdfAndView,
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[900], // Set background color
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : error != null
                ? Center(
                    child: Text(error!, style: TextStyle(color: Colors.white)))
                : appointments.isEmpty
                    ? Center(
                        child: Text('No appointments found.',
                            style: TextStyle(color: Colors.white)))
                    : ListView.builder(
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          return ListTile(
                            title: Text('Appointment ID: ${appointment['id']}',
                                style: TextStyle(color: Colors.white)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: ${appointment['date_time']}',
                                    style: TextStyle(color: Colors.white)),
                                FutureBuilder<Map<String, dynamic>>(
                                  future:
                                      fetchBarberName(appointment['barber']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.waiting ||
                                        snapshot.connectionState ==
                                            ConnectionState.none) {
                                      return Text('Barber: Loading...',
                                          style:
                                              TextStyle(color: Colors.white));
                                    }
                                    if (snapshot.hasError) {
                                      return Text('Barber: Error',
                                          style:
                                              TextStyle(color: Colors.white));
                                    }
                                    return Text(
                                        'Barber: ${snapshot.data?['name'] ?? 'N/A'}',
                                        style: TextStyle(color: Colors.white));
                                  },
                                ),
                                Text(
                                    'Style of Cut: ${appointment['style_of_cut'] ?? 'None'}',
                                    style: TextStyle(color: Colors.white)),
                                Text('Verified: ${appointment['verified']}',
                                    style: TextStyle(color: Colors.white)),
                                Text(
                                    'Service Rated: ${appointment['service_rated']}',
                                    style: TextStyle(color: Colors.white)),
                                Text('Rating: ${appointment['rating']}',
                                    style: TextStyle(color: Colors.white)),
                                Text(
                                    'Rating Comment: ${appointment['rating_comment'] ?? 'None'}',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Future<Map<String, dynamic>> fetchBarberName(int barberId) async {
    final apiUrl =
        'http://192.168.10.80:8000/api/barbershop/${widget.barbershopId}/barbers/$barberId';
    final response = await http.get(Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load barber name');
    }
  }

  Future<void> generatePdfAndView() async {
    final pdfLib.Document pdf = pdfLib.Document();

    pdf.addPage(
      pdfLib.Page(
        build: (context) {
          return pdfLib.ListView(
            children: [
              for (var appointment in appointments)
                pdfLib.Container(
                  margin: pdfLib.EdgeInsets.symmetric(vertical: 10.0),
                  child: pdfLib.Column(
                    crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
                    children: [
                      pdfLib.Text('Appointment ID: ${appointment['id']}'),
                      pdfLib.Text('Date: ${appointment['date_time']}'),
                      pdfLib.Text(
                          'Style of Cut: ${appointment['style_of_cut'] ?? 'None'}'),
                      pdfLib.Text('Verified: ${appointment['verified']}'),
                      pdfLib.Text(
                          'Service Rated: ${appointment['service_rated']}'),
                      pdfLib.Text('Rating: ${appointment['rating']}'),
                      pdfLib.Text(
                          'Rating Comment: ${appointment['rating_comment'] ?? 'None'}'),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
