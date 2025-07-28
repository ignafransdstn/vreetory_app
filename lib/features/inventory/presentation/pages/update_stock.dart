import 'package:flutter/material.dart';

class UpdateStockPage extends StatelessWidget {
  const UpdateStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Stock'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text('Update Stock Page'),
      ),
    );
  }
}