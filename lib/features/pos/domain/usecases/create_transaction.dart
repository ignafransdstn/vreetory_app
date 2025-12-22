import '../repositories/transaction_repository.dart';
import '../entities/transaction_entity.dart';
import '../entities/transaction_item_entity.dart';
import '../../../inventory/domain/repositories/item_repository.dart';
import '../../../inventory/domain/entities/item_entity.dart';
import 'validate_stock.dart';

/// Use case for creating a transaction and updating inventory
class CreateTransaction {
  final TransactionRepository transactionRepository;
  final ItemRepository itemRepository;
  final ValidateStock validateStock;

  CreateTransaction({
    required this.transactionRepository,
    required this.itemRepository,
    required this.validateStock,
  });

  /// Create a new transaction with automatic inventory update
  /// Validates stock before processing
  Future<TransactionEntity> call(TransactionEntity transaction) async {
    // 1. VALIDATE STOCK FOR ALL ITEMS
    final itemsToValidate = transaction.items
        .map((item) => {
              'itemId': item.itemId,
              'quantity': item.quantity,
            })
        .toList();

    final validation = await validateStock(itemsToValidate);

    if (validation['valid'] != true) {
      final insufficientItems = validation['insufficientItems'] as List;
      final inactiveItems = validation['inactiveItems'] as List;

      String errorMessage = 'Transaction validation failed:\n';

      if (insufficientItems.isNotEmpty) {
        errorMessage += '\nInsufficient stock:\n';
        for (var item in insufficientItems) {
          errorMessage += '• ${item['itemName']}: '
              'Available ${item['available']} ${item['measure']}, '
              'Requested ${item['requested']} ${item['measure']}\n';
        }
      }

      if (inactiveItems.isNotEmpty) {
        errorMessage += '\nInactive items:\n';
        for (var item in inactiveItems) {
          errorMessage += '• ${item['itemName']} (${item['status']})\n';
        }
      }

      throw Exception(errorMessage);
    }

    // 2. SAVE TRANSACTION TO DATABASE
    final savedTransaction =
        await transactionRepository.createTransaction(transaction);

    // 3. UPDATE INVENTORY FOR EACH ITEM
    try {
      for (var transactionItem in savedTransaction.items) {
        await _updateItemQuantity(transactionItem, transaction.cashier.email);
      }
    } catch (e) {
      // If inventory update fails, we should log this
      // but transaction is already saved
      print('⚠️ Error updating inventory: $e');
      // In production, consider implementing rollback or compensation logic
      rethrow;
    }

    return savedTransaction;
  }

  /// Update item quantity in inventory after sale
  Future<void> _updateItemQuantity(
    TransactionItemEntity transactionItem,
    String cashierEmail,
  ) async {
    // Get current item
    final currentItem = await itemRepository.getItem(transactionItem.itemId);
    if (currentItem == null) {
      throw Exception(
          'Item ${transactionItem.itemName} not found during inventory update');
    }

    // Calculate new quantity
    final currentQty = double.parse(currentItem.quantity);
    final soldQty = double.parse(transactionItem.quantity);
    final newQty = currentQty - soldQty;

    // Ensure we don't go negative (should not happen due to validation)
    if (newQty < 0) {
      throw Exception('Negative stock detected for ${currentItem.itemName}');
    }

    // Create updated item entity (using existing ItemEntity format)
    final updatedItem = ItemEntity(
      uid: currentItem.uid,
      itemName: currentItem.itemName,
      itemCode: currentItem.itemCode,
      category: currentItem.category,
      quantity: newQty.toString(), // NEW QUANTITY
      previousQuantity: currentItem.quantity, // TRACKING
      minimumStock: currentItem.minimumStock,
      buyRate: currentItem.buyRate,
      sellRate: currentItem.sellRate,
      expiredDate: currentItem.expiredDate,
      measure: currentItem.measure,
      supplier: currentItem.supplier,
      description: currentItem.description,
      imageUrl: currentItem.imageUrl,
      status: currentItem.status,
      createdBy: currentItem.createdBy,
      updatedBy: cashierEmail, // AUDIT TRAIL - cashier who made the sale
      createdAt: currentItem.createdAt,
      updatedAt: DateTime.now(),
      quantityChangeReason: 'Sale', // NEW REASON TYPE for POS transactions
    );

    // Update using existing repository method
    await itemRepository.updateItem(updatedItem);

    // Check for low stock and log warning
    final minStock = double.parse(updatedItem.minimumStock);
    if (newQty <= minStock) {
      print('⚠️ LOW STOCK ALERT: ${updatedItem.itemName} - '
          'Current: $newQty, Minimum: $minStock ${updatedItem.measure}');
      // Could trigger notification here in future
    }
  }

  /// Generate transaction number
  /// Format: INV-YYYYMMDD-XXXXX
  static String generateTransactionNumber() {
    final now = DateTime.now();
    final datePart = '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final timePart = now.millisecondsSinceEpoch.toString().substring(8);
    return 'INV-$datePart-$timePart';
  }
}
