import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';

class ProfileEditPage extends StatefulWidget {
  final String accessToken;

  const ProfileEditPage({Key? key, required this.accessToken})
      : super(key: key);

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _fullNameController;
  late TextEditingController _bioController;
  File? _image;
  bool _isLoading = false;
  bool _hasImage = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePickerAndroid().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _hasImage = true; // Image selected
      });
    }
  }

  void _clearImage() {
    setState(() {
      _image = null;
      _hasImage = false; // Image cleared
    });
  }

  Future<void> _updateProfile() async {
    if (_fullNameController.text.isEmpty || _bioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Full Name and Bio are required')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final apiUrl = 'http://192.168.10.80:8000/api/profile/update/';
    final headers = {
      HttpHeaders.authorizationHeader: 'Bearer ${widget.accessToken}',
    };

    var request = http.MultipartRequest('PUT', Uri.parse(apiUrl));
    request.headers.addAll(headers);

    // Add form fields
    request.fields['full_name'] = _fullNameController.text;
    request.fields['bio'] = _bioController.text;

    // Add image file
    if (_image != null) {
      var image = await http.MultipartFile.fromPath('image', _image!.path);
      request.files.add(image);
    }

    try {
      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        // Profile updated successfully
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Profile updated')));
        // Navigate back to the previous page
        Navigator.pop(context);
      } else {
        // Failed to update profile
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (e) {
      // Error occurred
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _updateProfile,
            icon: Icon(Icons.save, color: Colors.white),
          ),
        ],
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _fullNameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            TextFormField(
              controller: _bioController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Bio',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            _hasImage
                ? Column(
                    children: [
                      Image.file(_image!),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _clearImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[700],
                        ),
                        child: Text(
                          'Clear Image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _isLoading ? null : _getImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                    ),
                    child: Text(
                      'Choose Image',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
