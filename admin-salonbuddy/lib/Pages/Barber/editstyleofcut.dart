import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditStyleOfCutPage extends StatefulWidget {
  final int styleId;
  final String accessToken;

  EditStyleOfCutPage({
    required this.styleId,
    required this.accessToken,
  });

  @override
  _EditStyleOfCutPageState createState() => _EditStyleOfCutPageState();
}

class _EditStyleOfCutPageState extends State<EditStyleOfCutPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _fetchStyleOfCut();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _fetchStyleOfCut() async {
    try {
      final apiUrl =
          'http://192.168.10.80:8000/api/style-of-cut/${widget.styleId}/';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        final style = json.decode(response.body);
        _nameController.text = style['name'];
        _priceController.text = style['price'].toString();
      } else {
        throw Exception('Failed to load style of cut');
      }
    } catch (e) {
      print('Error fetching style of cut: $e');
    }
  }

  Future<void> _updateStyleOfCut() async {
    try {
      final apiUrl =
          'http://192.168.10.80:8000/api/style-of-cut/${widget.styleId}/';
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'price': double.parse(_priceController.text),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Style of cut updated successfully.'),
          ),
        );
        // Navigate back to the previous page after a delay
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      } else {
        throw Exception('Failed to update style of cut');
      }
    } catch (e) {
      print('Error updating style of cut: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating style of cut.'),
        ),
      );
    }
  }

  Future<void> _deleteStyleOfCut() async {
    try {
      final apiUrl =
          'http://192.168.10.80:8000/api/style-of-cut/${widget.styleId}/';
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Style of cut deleted successfully.'),
          ),
        );
        // Navigate back to the previous page after a delay
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      } else {
        throw Exception('Failed to delete style of cut');
      }
    } catch (e) {
      print('Error deleting style of cut: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting style of cut.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData.dark(),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Edit Style of Cut'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Style Name'),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _updateStyleOfCut,
                      child: Text('Save'),
                    ),
                    ElevatedButton(
                      onPressed: _deleteStyleOfCut,
                      child: Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ).merge(
                        ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
