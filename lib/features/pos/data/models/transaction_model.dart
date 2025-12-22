import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction_entity.dart';
import 'cashier_info_model.dart';
import 'transaction_item_model.dart';

/// Data model for TransactionEntity with Firestore serialization
class TransactionModel extends TransactionEntity {
  TransactionModel({
    required super.uid,
    required super.transactionNumber,
    required super.transactionDate,
    required super.cashier,
    required super.items,
    required super.subtotal,
    required super.discount,
    required super.discountPercent,
    required super.tax,
    required super.totalAmount,
    required super.totalProfit,
    required super.paymentMethod,
    required super.amountPaid,
    required super.change,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.notes,
  });

  /// Create model from entity
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      uid: entity.uid,
      transactionNumber: entity.transactionNumber,
      transactionDate: entity.transactionDate,
      cashier: entity.cashier,
      items: entity.items,
      subtotal: entity.subtotal,
      discount: entity.discount,
      discountPercent: entity.discountPercent,
      tax: entity.tax,
      totalAmount: entity.totalAmount,
      totalProfit: entity.totalProfit,
      paymentMethod: entity.paymentMethod,
      amountPaid: entity.amountPaid,
      change: entity.change,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      notes: entity.notes,
    );
  }

  /// Create model from Firestore JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      uid: json['uid'] as String,
      transactionNumber: json['transaction_number'] as String,
      transactionDate: (json['transaction_date'] as Timestamp).toDate(),
      cashier:
          CashierInfoModel.fromJson(json['cashier'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((item) =>
              TransactionItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: json['subtotal'] as String,
      discount: json['discount'] as String,
      discountPercent: json['discount_percent'] as String,
      tax: json['tax'] as String,
      totalAmount: json['total_amount'] as String,
      totalProfit: json['total_profit'] as String,
      paymentMethod: json['payment_method'] as String,
      amountPaid: json['amount_paid'] as String,
      change: json['change'] as String,
      status: json['status'] as String,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
      notes: json['notes'] as String? ?? '',
    );
  }

  /// Convert to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'transaction_number': transactionNumber,
      'transaction_date': Timestamp.fromDate(transactionDate),
      'cashier': CashierInfoModel.fromEntity(cashier).toJson(),
      'items': items
          .map((item) => TransactionItemModel.fromEntity(item).toJson())
          .toList(),
      'subtotal': subtotal,
      'discount': discount,
      'discount_percent': discountPercent,
      'tax': tax,
      'total_amount': totalAmount,
      'total_profit': totalProfit,
      'payment_method': paymentMethod,
      'amount_paid': amountPaid,
      'change': change,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'notes': notes,
    };
  }
}
