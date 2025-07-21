import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home Page'),
        backgroundColor: const Color(0xFF4B7F52),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Admin Home Page',
          style: TextStyle(fontSize: 24, color: Colors.black87),
        ),
      ),
    );
  }
}