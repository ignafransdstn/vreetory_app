import 'package:flutter/material.dart';

class EditItemPage extends StatelessWidget {
  const EditItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text('Edit Item Page'),
      ),
    );
  }
}