import '../../domain/entities/transaction_item_entity.dart';

/// Data model for TransactionItemEntity with Firestore serialization
class TransactionItemModel extends TransactionItemEntity {
  TransactionItemModel({
    required super.itemId,
    required super.itemName,
    required super.itemCode,
    required super.category,
    required super.measure,
    required super.quantity,
    required super.previousQuantity,
    required super.newQuantity,
    required super.buyRate,
    required super.sellRate,
    required super.unitPrice,
    required super.subtotal,
    required super.profit,
  });

  /// Create model from entity
  factory TransactionItemModel.fromEntity(TransactionItemEntity entity) {
    return TransactionItemModel(
      itemId: entity.itemId,
      itemName: entity.itemName,
      itemCode: entity.itemCode,
      category: entity.category,
      measure: entity.measure,
      quantity: entity.quantity,
      previousQuantity: entity.previousQuantity,
      newQuantity: entity.newQuantity,
      buyRate: entity.buyRate,
      sellRate: entity.sellRate,
      unitPrice: entity.unitPrice,
      subtotal: entity.subtotal,
      profit: entity.profit,
    );
  }

  /// Create model from Firestore JSON
  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      itemId: json['item_id'] as String,
      itemName: json['item_name'] as String,
      itemCode: json['item_code'] as String,
      category: json['category'] as String,
      measure: json['measure'] as String,
      quantity: json['quantity'] as String,
      previousQuantity: json['previous_quantity'] as String,
      newQuantity: json['new_quantity'] as String,
      buyRate: json['buy_rate'] as String,
      sellRate: json['sell_rate'] as String,
      unitPrice: json['unit_price'] as String,
      subtotal: json['subtotal'] as String,
      profit: json['profit'] as String,
    );
  }

  /// Convert to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'item_code': itemCode,
      'category': category,
      'measure': measure,
      'quantity': quantity,
      'previous_quantity': previousQuantity,
      'new_quantity': newQuantity,
      'buy_rate': buyRate,
      'sell_rate': sellRate,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'profit': profit,
    };
  }
}
