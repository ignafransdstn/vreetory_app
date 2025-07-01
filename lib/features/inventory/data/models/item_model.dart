import 'package:vreetory_app/features/inventory/domain/entities/item_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel extends ItemEntity {
  ItemModel(
      {required super.uid,
      required super.itemName,
      required super.itemCode,
      required super.category,
      required super.quantity,
      required super.buyRate,
      required super.sellRate,
      required super.expiredDate,
      required super.measure,
      required super.supplier,
      required super.description,
      required super.imageUrl,
      required super.status,
      required super.createdBy,
      required super.createdAt,
      required super.updatedAt});

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      uid: json['uid'],
      itemName: json['item_name'],
      itemCode: json['item_code'],
      category: json['category'],
      quantity: json['quantity'],
      buyRate: json['buy_rate'],
      sellRate: json['sell_rate'],
      expiredDate: json['expired_date'],
      measure: json['measure'],
      supplier: json['supplier'],
      description: json['description'],
      imageUrl: json['image_url'],
      status: json['status'],
      createdBy: json['created_by'],
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid' : uid,
    'item_name' : itemName,
    'item_code' : itemCode,
    'category' : category,
    'quantity' : quantity,
    'buy_rate' : buyRate,
    'sell_rate' : sellRate,
    'expired_date' : expiredDate,
    'measure' : measure,
    'supplier' : supplier,
    'description' : description,
    'image_url' : imageUrl,
    'status' : status,
    'created_by' : createdBy,
    'created_at' : createdAt,
    'updated_at' : updatedAt,
  };
}
