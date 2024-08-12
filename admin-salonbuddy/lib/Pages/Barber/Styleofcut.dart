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
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Style of Cut'),
        ),
        body: Center(
          child: _hasStylesOfCut
              ? ElevatedButton(
                  onPressed: () {
                    ();
                  },
                  child: Text('There are no style of cut from the barbershop'),
                )
              : ListView.builder(
                  itemCount: _stylesOfCut.length,
                  itemBuilder: (BuildContext context, int index) {
                    final style = _stylesOfCut[index];
                    final double price =
                        double.tryParse(style['price'] ?? '0.0') ?? 0.0;

                    return ListTile(
                      title: Text(style['name']),
                      subtitle: Text('Price: ${style['price']}'),
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
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => CreateStyleOfCutPage(
        //           barbershopId: widget.barbershopId,
        //           accessToken: widget.accessToken,
        //         ),
        //       ),
        //     );
        //   },
        //   child: Icon(Icons.add),
        // ),
      ),
    );
  }

  // Future<void> _createDefaultStyles() async {
  //   try {
  //     final apiUrl =
  //         'http://192.168.10.80:8000/api/barbershops/${widget.barbershopId}/style-of-cuts/create-default-styles/';
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: {'Authorization': 'Bearer ${widget.accessToken}'},
  //     );

  //     if (response.statusCode == 200) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Default styles created successfully.'),
  //         ),
  //       );
  //     } else {
  //       throw Exception('Failed to create default styles');
  //     }
  //   } catch (e) {
  //     print('Error creating default styles: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error creating default styles.'),
  //       ),
  //     );
  //   }
  // }

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
