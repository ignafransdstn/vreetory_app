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
        icon: Icons.add_circle_outline,
        label: 'ADD ITEM',
        color: Colors.green,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddItemPage()),
        ),
      ),
      _MenuItem(
        icon: Icons.touch_app,
        label: 'EDIT ITEM',
        color: Colors.amber,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditItemPage()),
        ),
      ),
      _MenuItem(
        icon: Icons.cancel,
        label: 'DELETE ITEM',
        color: Colors.red,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DeleteItemPage()),
        ),
      ),
      _MenuItem(
        icon: Icons.inventory_2,
        label: 'UPDATE STOCK',
        color: Colors.blue,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UpdateStockPage()),
        ),
      ),
      _MenuItem(
        icon: Icons.list_alt,
        label: 'LIST ITEM STOCK',
        color: Colors.black,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ListItemStockPage()),
        ),
      ),
      _MenuItem(
        icon: Icons.monitor,
        label: 'REPORTING',
        color: Colors.orange,
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
            const SizedBox(height: 16),
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
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
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
          CircleAvatar(
            radius: 44,
            backgroundColor: item.color.withOpacity(0.15),
            child: Icon(item.icon, size: 56, color: item.color),
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