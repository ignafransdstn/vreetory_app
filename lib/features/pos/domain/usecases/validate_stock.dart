import '../../../inventory/domain/repositories/item_repository.dart';

/// Use case for validating stock availability before transaction
class ValidateStock {
  final ItemRepository itemRepository;

  ValidateStock(this.itemRepository);

  /// Validate if items have sufficient stock for transaction
  /// Returns map of item validation results
  Future<Map<String, dynamic>> call(
    List<Map<String, dynamic>> requestedItems,
  ) async {
    final insufficientItems = <Map<String, dynamic>>[];
    final inactiveItems = <Map<String, dynamic>>[];
    bool allValid = true;

    for (var requestedItem in requestedItems) {
      final itemId = requestedItem['itemId'] as String;
      final requestedQty = double.parse(requestedItem['quantity'] as String);

      // Get current item from inventory
      final currentItem = await itemRepository.getItem(itemId);

      if (currentItem == null) {
        allValid = false;
        insufficientItems.add({
          'itemId': itemId,
          'reason': 'Item not found',
          'requested': requestedQty,
          'available': 0,
        });
        continue;
      }

      // Check if item is active
      if (currentItem.status.toLowerCase() != 'active') {
        allValid = false;
        inactiveItems.add({
          'itemId': itemId,
          'itemName': currentItem.itemName,
          'status': currentItem.status,
        });
        continue;
      }

      // Check stock availability
      final currentStock = double.parse(currentItem.quantity);
      if (currentStock < requestedQty) {
        allValid = false;
        insufficientItems.add({
          'itemId': itemId,
          'itemName': currentItem.itemName,
          'itemCode': currentItem.itemCode,
          'requested': requestedQty,
          'available': currentStock,
          'measure': currentItem.measure,
        });
      }
    }

    return {
      'valid': allValid,
      'insufficientItems': insufficientItems,
      'inactiveItems': inactiveItems,
    };
  }

  /// Validate single item stock
  Future<bool> validateSingleItem(String itemId, double quantity) async {
    final currentItem = await itemRepository.getItem(itemId);

    if (currentItem == null) {
      throw Exception('Item not found');
    }

    if (currentItem.status.toLowerCase() != 'active') {
      throw Exception('Item ${currentItem.itemName} is not active');
    }

    final currentStock = double.parse(currentItem.quantity);
    if (currentStock < quantity) {
      throw Exception(
        'Insufficient stock for ${currentItem.itemName}. '
        'Available: $currentStock ${currentItem.measure}, '
        'Requested: $quantity ${currentItem.measure}',
      );
    }

    return true;
  }
}
