import '../../../inventory/domain/entities/item_entity.dart';

/// Represents an item in the shopping cart
class CartItem {
  final String itemId;
  final String itemName;
  final String itemCode;
  final String category;
  final String measure;

  // Quantity and pricing
  final String quantity; // Qty in cart (String to match ItemEntity format)
  final String availableStock; // Current available stock
  final String buyRate;
  final String sellRate;
  final String unitPrice; // Selling price per unit
  final String subtotal; // Total for this cart item
  final String profit; // Profit for this cart item

  // Additional info
  final String imageUrl;
  final DateTime addedAt;

  CartItem({
    required this.itemId,
    required this.itemName,
    required this.itemCode,
    required this.category,
    required this.measure,
    required this.quantity,
    required this.availableStock,
    required this.buyRate,
    required this.sellRate,
    required this.unitPrice,
    required this.subtotal,
    required this.profit,
    required this.imageUrl,
    required this.addedAt,
  });

  /// Create CartItem from ItemEntity
  factory CartItem.fromItem(ItemEntity item, String quantity) {
    final qty = double.parse(quantity);
    final buy = double.parse(item.buyRate);
    final sell = double.parse(item.sellRate);

    return CartItem(
      itemId: item.uid,
      itemName: item.itemName,
      itemCode: item.itemCode,
      category: item.category,
      measure: item.measure,
      quantity: quantity,
      availableStock: item.quantity,
      buyRate: item.buyRate,
      sellRate: item.sellRate,
      unitPrice: item.sellRate,
      subtotal: (sell * qty).toStringAsFixed(0),
      profit: ((sell - buy) * qty).toStringAsFixed(0),
      imageUrl: item.imageUrl,
      addedAt: DateTime.now(),
    );
  }

  /// Create a copy with modified fields
  CartItem copyWith({
    String? itemId,
    String? itemName,
    String? itemCode,
    String? category,
    String? measure,
    String? quantity,
    String? availableStock,
    String? buyRate,
    String? sellRate,
    String? unitPrice,
    String? subtotal,
    String? profit,
    String? imageUrl,
    DateTime? addedAt,
  }) {
    // Recalculate subtotal and profit if quantity changes
    if (quantity != null && quantity != this.quantity) {
      final qty = double.parse(quantity);
      final buy = double.parse(buyRate ?? this.buyRate);
      final sell = double.parse(sellRate ?? this.sellRate);

      return CartItem(
        itemId: itemId ?? this.itemId,
        itemName: itemName ?? this.itemName,
        itemCode: itemCode ?? this.itemCode,
        category: category ?? this.category,
        measure: measure ?? this.measure,
        quantity: quantity,
        availableStock: availableStock ?? this.availableStock,
        buyRate: buyRate ?? this.buyRate,
        sellRate: sellRate ?? this.sellRate,
        unitPrice: unitPrice ?? this.unitPrice,
        subtotal: (sell * qty).toStringAsFixed(0),
        profit: ((sell - buy) * qty).toStringAsFixed(0),
        imageUrl: imageUrl ?? this.imageUrl,
        addedAt: addedAt ?? this.addedAt,
      );
    }

    return CartItem(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemCode: itemCode ?? this.itemCode,
      category: category ?? this.category,
      measure: measure ?? this.measure,
      quantity: quantity ?? this.quantity,
      availableStock: availableStock ?? this.availableStock,
      buyRate: buyRate ?? this.buyRate,
      sellRate: sellRate ?? this.sellRate,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      profit: profit ?? this.profit,
      imageUrl: imageUrl ?? this.imageUrl,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Check if stock is sufficient
  bool get hasInsufficientStock {
    final qty = double.parse(quantity);
    final stock = double.parse(availableStock);
    return qty > stock;
  }

  /// Get warning message if stock is low
  String? get stockWarning {
    final qty = double.parse(quantity);
    final stock = double.parse(availableStock);

    if (qty > stock) {
      return 'Stok tidak cukup! Tersedia: $stock $measure';
    } else if (qty == stock) {
      return 'Ini adalah stok terakhir';
    } else if (stock - qty <= 5) {
      return 'Stok tinggal ${stock - qty} $measure setelah transaksi';
    }
    return null;
  }
}
