import 'package:flutter/material.dart';

class UserMenuPage extends StatelessWidget {
  const UserMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'User Menu Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}