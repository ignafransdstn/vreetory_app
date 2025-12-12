import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/loss_record_entity.dart';

class LossRecordModel extends LossRecordEntity {
  LossRecordModel({
    required super.uid,
    required super.itemUid,
    required super.itemName,
    required super.itemCode,
    required super.category,
    required super.reasonType,
    required super.quantityLost,
    required super.buyRate,
    required super.totalLoss,
    required super.createdBy,
    required super.createdAt,
    super.notes,
  });

  factory LossRecordModel.fromJson(Map<String, dynamic> json) {
    return LossRecordModel(
      uid: json['uid'] ?? '',
      itemUid: json['item_uid'] ?? '',
      itemName: json['item_name'] ?? '',
      itemCode: json['item_code'] ?? '',
      category: json['category'] ?? '',
      reasonType: json['reason_type'] ?? '',
      quantityLost: json['quantity_lost'] ?? '0',
      buyRate: json['buy_rate'] ?? '0',
      totalLoss: json['total_loss'] ?? '0',
      createdBy: json['created_by'] ?? '',
      createdAt: (json['created_at'] as Timestamp).toDate(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'item_uid': itemUid,
    'item_name': itemName,
    'item_code': itemCode,
    'category': category,
    'reason_type': reasonType,
    'quantity_lost': quantityLost,
    'buy_rate': buyRate,
    'total_loss': totalLoss,
    'created_by': createdBy,
    'created_at': createdAt,
    'notes': notes,
  };
}
