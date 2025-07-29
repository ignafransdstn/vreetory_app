import 'package:flutter/material.dart';
import 'package:vreetory_app/features/inventory/presentation/pages/add_item.dart';
import 'package:vreetory_app/features/inventory/presentation/pages/edit_item.dart';
import 'package:vreetory_app/features/inventory/presentation/pages/delete_item.dart';
import 'package:vreetory_app/features/inventory/presentation/pages/update_stock.dart';
import 'package:vreetory_app/features/inventory/presentation/pages/list_item_stock.dart';
import 'package:vreetory_app/features/inventory/presentation/pages/reporting.dart';

class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(
        image: 'assets/images/asset4.png',
        label: 'ADD ITEM',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddItemPage()),
        ),
      ),
      _MenuItem(
        image: 'assets/images/asset5.png',
        label: 'EDIT ITEM',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditItemPage()),
        ),
      ),
      _MenuItem(
        image: 'assets/images/asset6.png',
        label: 'DELETE ITEM',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DeleteItemPage()),
        ),
      ),
      _MenuItem(
        image: 'assets/images/asset7.png',
        label: 'UPDATE STOCK',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UpdateStockPage()),
        ),
      ),
      _MenuItem(
        image: 'assets/images/asset8.png',
        label: 'LIST ITEM STOCK',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ListItemStockPage()),
        ),
      ),
      _MenuItem(
        image: 'assets/images/asset9.png',
        label: 'REPORTING',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportingPage()),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFD6FFB7),
      body: SafeArea(
        child: Column(
          children: [
            // Logo and App Name
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/asset1.png',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Inventory App',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Text(
                    'VreeTory',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF4B7F52),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Menu Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                mainAxisSpacing: 32,
                crossAxisSpacing: 32,
                children: menuItems.map((item) => _MenuButton(item: item)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final String image;
  final String label;
  final VoidCallback onTap;

  _MenuItem({
    required this.image,
    required this.label,
    required this.onTap,
  });
}

class _MenuButton extends StatelessWidget {
  final _MenuItem item;
  const _MenuButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                item.image,
                fit: BoxFit.contain,
                width: 64,
                height: 64,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}