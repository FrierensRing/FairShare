import 'package:flutter/material.dart';

// Full-screen details page
class UserDetailsFullScreen extends StatelessWidget {
  final int index;
  
  const UserDetailsFullScreen({Key? key, required this.index}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User ${index + 1} Details"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          "Content for User ${index + 1} goes here",
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}