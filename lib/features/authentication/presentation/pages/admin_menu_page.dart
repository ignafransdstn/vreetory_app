import 'package:flutter/material.dart';

class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Admin Menu Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}