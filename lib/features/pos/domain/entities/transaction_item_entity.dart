import '../../../inventory/domain/entities/item_entity.dart';

/// Represents a single item in a transaction
/// Contains quantity tracking integrated with inventory system
class TransactionItemEntity {
  // Item identification (from ItemEntity)
  final String itemId;
  final String itemName;
  final String itemCode;
  final String category;
  final String measure;

  // Quantity tracking (integrated with inventory)
  final String quantity; // Qty sold (String format to match ItemEntity)
  final String previousQuantity; // Stock before transaction
  final String newQuantity; // Stock after transaction

  // Pricing
  final String buyRate; // Purchase price
  final String sellRate; // Selling price
  final String unitPrice; // Price per unit (from sellRate)
  final String subtotal; // Total for this line item
  final String profit; // Profit for this line item

  TransactionItemEntity({
    required this.itemId,
    required this.itemName,
    required this.itemCode,
    required this.category,
    required this.measure,
    required this.quantity,
    required this.previousQuantity,
    required this.newQuantity,
    required this.buyRate,
    required this.sellRate,
    required this.unitPrice,
    required this.subtotal,
    required this.profit,
  });

  /// Factory method to create TransactionItemEntity from ItemEntity
  /// Automatically calculates pricing and new quantities
  factory TransactionItemEntity.fromItem(
    ItemEntity item,
    String soldQuantity,
  ) {
    final qty = double.parse(soldQuantity);
    final currentStock = double.parse(item.quantity);
    final buy = double.parse(item.buyRate);
    final sell = double.parse(item.sellRate);

    return TransactionItemEntity(
      itemId: item.uid,
      itemName: item.itemName,
      itemCode: item.itemCode,
      category: item.category,
      measure: item.measure,
      quantity: soldQuantity,
      previousQuantity: item.quantity,
      newQuantity: (currentStock - qty).toString(),
      buyRate: item.buyRate,
      sellRate: item.sellRate,
      unitPrice: item.sellRate,
      subtotal: (sell * qty).toStringAsFixed(0),
      profit: ((sell - buy) * qty).toStringAsFixed(0),
    );
  }

  /// Create a copy with modified fields
  TransactionItemEntity copyWith({
    String? itemId,
    String? itemName,
    String? itemCode,
    String? category,
    String? measure,
    String? quantity,
    String? previousQuantity,
    String? newQuantity,
    String? buyRate,
    String? sellRate,
    String? unitPrice,
    String? subtotal,
    String? profit,
  }) {
    return TransactionItemEntity(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemCode: itemCode ?? this.itemCode,
      category: category ?? this.category,
      measure: measure ?? this.measure,
      quantity: quantity ?? this.quantity,
      previousQuantity: previousQuantity ?? this.previousQuantity,
      newQuantity: newQuantity ?? this.newQuantity,
      buyRate: buyRate ?? this.buyRate,
      sellRate: sellRate ?? this.sellRate,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      profit: profit ?? this.profit,
    );
  }
}
