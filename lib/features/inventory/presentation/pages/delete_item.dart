import 'package:flutter/material.dart';

class DeleteItemPage extends StatelessWidget {
  const DeleteItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text('Delete Item Page'),
      ),
    );
  }
}