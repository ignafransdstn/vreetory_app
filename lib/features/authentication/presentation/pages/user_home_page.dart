import 'package:flutter/material.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Home Page'),
        backgroundColor: const Color(0xFF4B7F52),
      ),
      body: const Center(
        child: Text(
          'Welcome to the User Home Page',
          style: TextStyle(fontSize: 24, color: Colors.black87),
        ),
      ),
    );
  }
}