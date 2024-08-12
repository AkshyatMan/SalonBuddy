import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:salonbuddy/Pages/admin/updateuserspage.dart';
import 'dart:convert';

class ManageUserPage extends StatefulWidget {
  @override
  _ManageUserPageState createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  List<Map<String, dynamic>> users = [];
  late List<Map<String, dynamic>> filteredUsers;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
    filteredUsers = [];
  }

  Future<void> fetchUsers() async {
    final response =
        await http.get(Uri.parse('http://192.168.10.80:8000/api/users/'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        users =
            responseData.map((data) => data as Map<String, dynamic>).toList();
        filteredUsers.addAll(users);
      });
    } else {
      print('Failed to fetch users: ${response.statusCode}');
    }
  }

  void filterUsers(String query) {
    filteredUsers.clear();
    if (query.isNotEmpty) {
      users.forEach((user) {
        if (user['username'].toLowerCase().contains(query.toLowerCase()) ||
            user['email'].toLowerCase().contains(query.toLowerCase()) ||
            user['role'].toLowerCase().contains(query.toLowerCase())) {
          filteredUsers.add(user);
        }
      });
    } else {
      filteredUsers.addAll(users);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Users',
          style: TextStyle(color: const Color.fromARGB(255, 190, 183, 183)),
        ),
        backgroundColor: Colors.grey[800],
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Colors.black, // Dark background color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: searchController,
              onChanged: (value) {
                filterUsers(value);
              },
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UpdateUserPage(userId: user['id']),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.grey[800], // Card background color
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          'Username: ${user['username']}',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email: ${user['email']}',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Role: ${user['role']}',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Phone: ${user['phone']}',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Address: ${user['address']}',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
