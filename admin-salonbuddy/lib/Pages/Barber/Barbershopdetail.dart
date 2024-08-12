import 'package:flutter/material.dart';
import 'package:salonbuddy/Pages/Barber/Styleofcut.dart';
import 'package:salonbuddy/Pages/Barber/UpdateBarbershopPage.dart';
import 'package:salonbuddy/Pages/Barber/appointment.dart';

class BarbershopDetailsPage extends StatelessWidget {
  final int barbershopId;
  final String accessToken;

  BarbershopDetailsPage({
    required this.barbershopId,
    required this.accessToken,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Barbershop Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Barbershop Details'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StyleOfCutPage(
                        barbershopId: barbershopId,
                        accessToken: accessToken,
                      ),
                    ),
                  );
                },
                child: Text('Navigate to Style of Cut Page'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BarberAppointmentsPage(
                        barbershopId: barbershopId,
                        accessToken: accessToken,
                      ),
                    ),
                  );
                },
                child: Text('View Appointments'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateBarbershopPage(
                        barbershopId: barbershopId,
                        accessToken: accessToken,
                      ),
                    ),
                  );
                },
                child: Text('Edit Barbershop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
