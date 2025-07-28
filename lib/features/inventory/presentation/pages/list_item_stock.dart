import 'package:flutter/material.dart';

class ListItemStockPage extends StatelessWidget {
  const ListItemStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Item Stock'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text('List Item Stock Page'),
      ),
    );
  }
}