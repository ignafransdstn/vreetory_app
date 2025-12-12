import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/item_model.dart';

class ExpiryAlertDataSource {
  final FirebaseFirestore firestore;

  ExpiryAlertDataSource(this.firestore);

  /// Parse date from dd/MM/yyyy format to DateTime
  DateTime? _parseExpiryDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get all items with expiry dates for expiry alert report
  Future<List<ItemModel>> getExpiryAlertItems() async {
    final querySnapshot = await firestore
        .collection('items')
        .get();
    
    return querySnapshot.docs
        .map((doc) => ItemModel.fromJson(doc.data()))
        .where((item) => item.expiredDate.isNotEmpty)
        .toList();
  }

  /// Get items expiring today
  Future<List<ItemModel>> getItemsExpiringToday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final querySnapshot = await firestore
        .collection('items')
        .get();

    return querySnapshot.docs
        .map((doc) => ItemModel.fromJson(doc.data()))
        .where((item) {
          if (item.expiredDate.isEmpty) return false;
          try {
            final expiryDate = _parseExpiryDate(item.expiredDate);
            if (expiryDate == null) return false;
            final expiryDateOnly = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
            return expiryDateOnly.isAtSameMomentAs(today) ||
                (expiryDateOnly.isAfter(today) && expiryDateOnly.isBefore(tomorrow));
          } catch (e) {
            return false;
          }
        })
        .toList();
  }

  /// Get items expiring within the next N days
  Future<List<ItemModel>> getItemsExpiringWithinDays(int days) async {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    final querySnapshot = await firestore
        .collection('items')
        .get();

    return querySnapshot.docs
        .map((doc) => ItemModel.fromJson(doc.data()))
        .where((item) {
          if (item.expiredDate.isEmpty) return false;
          try {
            final expiryDate = _parseExpiryDate(item.expiredDate);
            if (expiryDate == null) return false;
            return expiryDate.isAfter(now) && expiryDate.isBefore(futureDate);
          } catch (e) {
            return false;
          }
        })
        .toList();
  }

  /// Get expired items (past expiry date)
  Future<List<ItemModel>> getExpiredItems() async {
    final now = DateTime.now();

    final querySnapshot = await firestore
        .collection('items')
        .get();

    return querySnapshot.docs
        .map((doc) => ItemModel.fromJson(doc.data()))
        .where((item) {
          if (item.expiredDate.isEmpty) return false;
          try {
            final expiryDate = _parseExpiryDate(item.expiredDate);
            if (expiryDate == null) return false;
            return expiryDate.isBefore(now);
          } catch (e) {
            return false;
          }
        })
        .toList();
  }

  /// Get items by category
  Future<List<ItemModel>> getItemsByCategory(String category) async {
    final querySnapshot = await firestore
        .collection('items')
        .where('category', isEqualTo: category)
        .get();

    return querySnapshot.docs
        .map((doc) => ItemModel.fromJson(doc.data()))
        .where((item) => item.expiredDate.isNotEmpty)
        .toList();
  }

  /// Get items by supplier
  Future<List<ItemModel>> getItemsBySupplier(String supplier) async {
    final querySnapshot = await firestore
        .collection('items')
        .get();

    return querySnapshot.docs
        .map((doc) => ItemModel.fromJson(doc.data()))
        .where((item) {
          if (item.expiredDate.isEmpty) return false;
          
          // Handle "Other" for empty suppliers
          final itemSupplier = item.supplier.trim().isEmpty ? 'Other' : item.supplier.trim();
          return itemSupplier == supplier;
        })
        .toList();
  }
}
