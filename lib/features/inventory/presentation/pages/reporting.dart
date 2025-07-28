import 'package:flutter/material.dart';

class ReportingPage extends StatelessWidget {
  const ReportingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporting'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text('Reporting Page'),
      ),
    );
  }
}