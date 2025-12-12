import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class InventoryMovementDataSource {
  final FirebaseFirestore firestore;

  InventoryMovementDataSource(this.firestore);

  /// Get all items sorted by most recent update
  Future<List<ItemModel>> getInventoryMovements() async {
    final querySnapshot = await firestore
        .collection('items')
        .orderBy('updated_at', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ItemModel.fromJson(doc.data()))
        .toList();
  }

  /// Get items by category
  Future<List<ItemModel>> getMovementsByCategory(String category) async {
    final querySnapshot = await firestore
        .collection('items')
        .where('category', isEqualTo: category)
        .orderBy('updated_at', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ItemModel.fromJson(doc.data()))
        .toList();
  }

  /// Get items by movement type (inbound/outbound)
  /// inbound: quantity increased
  /// outbound: quantity decreased
  Future<List<Map<String, dynamic>>> getMovementsByType(String type) async {
    final querySnapshot = await firestore
        .collection('items')
        .orderBy('updated_at', descending: true)
        .get();

    final movements = <Map<String, dynamic>>[];

    for (final doc in querySnapshot.docs) {
      final item = ItemModel.fromJson(doc.data());
      final currentQty = int.tryParse(item.quantity) ?? 0;
      final previousQty = int.tryParse(item.previousQuantity) ?? 0;
      final change = currentQty - previousQty;

      if (type == 'inbound' && change > 0) {
        movements.add({
          'item': item,
          'change': change,
          'type': 'inbound',
        });
      } else if (type == 'outbound' && change < 0) {
        movements.add({
          'item': item,
          'change': change.abs(),
          'type': 'outbound',
        });
      }
    }

    return movements;
  }

  /// Get items by supplier
  Future<List<ItemModel>> getMovementsBySupplier(String supplier) async {
    final querySnapshot = await firestore
        .collection('items')
        .where('supplier', isEqualTo: supplier)
        .orderBy('updated_at', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ItemModel.fromJson(doc.data()))
        .toList();
  }
}

