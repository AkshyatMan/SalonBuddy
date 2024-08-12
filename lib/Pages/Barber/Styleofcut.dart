import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:salonbuddy/Pages/Barber/createstyleofcut.dart';
import 'package:salonbuddy/Pages/Barber/editstyleofcut.dart';

class StyleOfCutPage extends StatefulWidget {
  final int barbershopId;
  final String accessToken;

  StyleOfCutPage({
    required this.barbershopId,
    required this.accessToken,
  });

  @override
  _StyleOfCutPageState createState() => _StyleOfCutPageState();
}

class _StyleOfCutPageState extends State<StyleOfCutPage> {
  bool _hasStylesOfCut = false;
  List<dynamic> _stylesOfCut = [];

  @override
  void initState() {
    super.initState();
    _fetchStylesOfCut();
  }

  Future<void> _fetchStylesOfCut() async {
    try {
      final apiUrl =
          'http://192.168.10.80:8000/api/barbershops/${widget.barbershopId}/style-of-cuts/';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _stylesOfCut = json.decode(response.body);
          _hasStylesOfCut = _stylesOfCut.isEmpty;
        });
      } else {
        throw Exception('Failed to load styles of cut');
      }
    } catch (e) {
      print('Error fetching styles of cut: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Style of Cut',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: _hasStylesOfCut
            ? ElevatedButton(
                onPressed: () {
                  _createDefaultStyles();
                },
                child: Text('Create Default Styles'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.purple,
                ),
              )
            : ListView.builder(
                itemCount: _stylesOfCut.length,
                itemBuilder: (BuildContext context, int index) {
                  final style = _stylesOfCut[index];
                  final double price =
                      double.tryParse(style['price'] ?? '0.0') ?? 0.0;

                  return ListTile(
                    title: Text(
                      style['name'],
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Price: ${style['price']}',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      _navigateToEditStyleOfCutPage(
                        style['id'], // Pass style ID
                        style['name'],
                        price,
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateStyleOfCutPage(
                barbershopId: widget.barbershopId,
                accessToken: widget.accessToken,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
      backgroundColor: Colors.grey[900],
    );
  }

  Future<void> _createDefaultStyles() async {
    try {
      final apiUrl =
          'http://192.168.10.80:8000/api/barbershops/${widget.barbershopId}/style-of-cuts/create-default-styles/';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Default styles created successfully.'),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StyleOfCutPage(
              barbershopId: widget.barbershopId,
              accessToken: widget.accessToken,
            ),
          ),
        );
      } else {
        throw Exception('Failed to create default styles');
      }
    } catch (e) {
      print('Error creating default styles: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating default styles.'),
        ),
      );
    }
  }

  void _navigateToEditStyleOfCutPage(
      int styleId, String styleName, double price) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStyleOfCutPage(
          styleId: styleId, // Pass style ID
          accessToken: widget.accessToken, // Pass access token
        ),
      ),
    );
  }
}
