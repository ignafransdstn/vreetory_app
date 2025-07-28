import 'package:flutter/material.dart';

class AddItemPage extends StatelessWidget {
  const AddItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text('Add Item Page'),
      ),
    );
  }
}