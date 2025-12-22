import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/low_stock_alert_item.dart';

class LowStockDatasource {
  final FirebaseFirestore firestore;

  LowStockDatasource({required this.firestore});

  /// Fetch all items and calculate low stock status
  Future<List<LowStockAlertItem>> getLowStockItems() async {
    try {
      final querySnapshot = await firestore.collection('items').get();

      List<LowStockAlertItem> lowStockItems = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        // Parse required fields - handle String, double, int, and empty values
        final itemName = data['item_name'] as String? ?? 'Unknown';
        final quantityValue = data['quantity'];
        final quantity = _parseToDouble(quantityValue);
        final minimumStockValue = data['minimum_stock'];
        final minimumStock = _parseToDouble(minimumStockValue);
        final category = data['category'] as String? ?? 'Uncategorized';
        var supplier = data['supplier'] as String? ?? '';
        // Treat empty suppliers as 'Others'
        if (supplier.isEmpty || supplier.trim().isEmpty) {
          supplier = 'Others';
        }
        final measure = data['measure'] as String? ?? 'units';

        // Skip items with no minimum stock requirement
        if (minimumStock == 0) continue;

        // Calculate status
        final stockPercentage =
            minimumStock > 0 ? (quantity / minimumStock) * 100 : 100.0;

        final status = _calculateStatus(quantity, minimumStock);

        // Only include items that are not in "Normal" status OR all items depending on filter
        // For now, include all items with minimum_stock > 0
        lowStockItems.add(
          LowStockAlertItem(
            itemId: doc.id,
            itemName: itemName,
            currentQuantity: quantity,
            minimumStock: minimumStock,
            category: category,
            supplier: supplier,
            measure: measure,
            status: status,
            stockPercentage: stockPercentage,
          ),
        );
      }

      // Sort by stock percentage (critical first)
      lowStockItems
          .sort((a, b) => a.stockPercentage.compareTo(b.stockPercentage));

      return lowStockItems;
    } catch (e) {
      rethrow;
    }
  }

  /// Parse any value type (String, double, int, null) to double safely
  /// Returns 0.0 if value is null, empty string, or cannot be parsed
  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;

    // If already double or int, convert to double
    if (value is num) return value.toDouble();

    // If string, trim and parse
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return 0.0;
      return double.tryParse(trimmed) ?? 0.0;
    }

    // Default to 0.0 for other types
    return 0.0;
  }

  /// Calculate low stock status based on quantity vs minimum stock
  LowStockStatus _calculateStatus(double currentQuantity, double minimumStock) {
    if (minimumStock == 0) return LowStockStatus.normal;

    final percentage = (currentQuantity / minimumStock) * 100;

    if (currentQuantity < minimumStock) {
      return LowStockStatus.critical; // Below minimum
    } else if (percentage < 120) {
      return LowStockStatus.warning; // Within 20% above minimum
    } else {
      return LowStockStatus.normal; // Well above minimum
    }
  }

  /// Get unique categories from items with minimum stock
  Future<List<String>> getCategories() async {
    try {
      final querySnapshot = await firestore.collection('items').get();
      final categories = <String>{};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final minimumStock =
            int.tryParse(data['minimum_stock'] as String? ?? '0') ?? 0;

        if (minimumStock > 0) {
          final category = data['category'] as String? ?? 'Uncategorized';
          categories.add(category);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      rethrow;
    }
  }

  /// Get unique suppliers from items with minimum stock
  /// Empty suppliers are categorized as 'Others'
  Future<List<String>> getSuppliers() async {
    try {
      final querySnapshot = await firestore.collection('items').get();
      final suppliers = <String>{};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final minimumStock =
            int.tryParse(data['minimum_stock'] as String? ?? '0') ?? 0;

        if (minimumStock > 0) {
          var supplier = data['supplier'] as String? ?? '';
          // Treat empty suppliers as 'Others'
          if (supplier.isEmpty || supplier.trim().isEmpty) {
            supplier = 'Others';
          }
          suppliers.add(supplier);
        }
      }

      return suppliers.toList()..sort();
    } catch (e) {
      rethrow;
    }
  }
}
