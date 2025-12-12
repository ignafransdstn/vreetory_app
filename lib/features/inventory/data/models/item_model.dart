import 'package:vreetory_app/features/inventory/domain/entities/item_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel extends ItemEntity {
  ItemModel(
      {required super.uid,
      required super.itemName,
      required super.itemCode,
      required super.category,
      required super.quantity,
      required super.previousQuantity,
      required super.minimumStock,
      required super.buyRate,
      required super.sellRate,
      required super.expiredDate,
      required super.measure,
      required super.supplier,
      required super.description,
      required super.imageUrl,
      required super.status,
      required super.createdBy,
      required super.updatedBy,
      required super.createdAt,
      required super.updatedAt,
      super.quantityChangeReason});

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final quantity = json['quantity'] ?? '';
    return ItemModel(
      uid: json['uid'],
      itemName: json['item_name'],
      itemCode: json['item_code'],
      category: json['category'],
      quantity: quantity,
      previousQuantity: json['previous_quantity'] ?? quantity, // Default to current quantity if not set (backward compatibility)
      minimumStock: json['minimum_stock'] ?? '0', // Default to 0 if not set (backward compatibility)
      buyRate: json['buy_rate'],
      sellRate: json['sell_rate'],
      expiredDate: json['expired_date'],
      measure: json['measure'],
      supplier: json['supplier'],
      description: json['description'],
      imageUrl: json['image_url'],
      status: json['status'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'] ?? json['created_by'], // Default to createdBy if not set (backward compatibility)
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
      quantityChangeReason: json['quantity_change_reason'],
    );
  }

  Map<String, dynamic> toJson() => {
    'uid' : uid,
    'item_name' : itemName,
    'item_code' : itemCode,
    'category' : category,
    'quantity' : quantity,
    'previous_quantity' : previousQuantity,
    'minimum_stock' : minimumStock,
    'buy_rate' : buyRate,
    'sell_rate' : sellRate,
    'expired_date' : expiredDate,
    'measure' : measure,
    'supplier' : supplier,
    'description' : description,
    'image_url' : imageUrl,
    'status' : status,
    'created_by' : createdBy,
    'updated_by' : updatedBy,
    'created_at' : createdAt,
    'updated_at' : updatedAt,
    'quantity_change_reason' : quantityChangeReason,
  };
}
