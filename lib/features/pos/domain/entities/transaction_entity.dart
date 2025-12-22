import 'cashier_info.dart';
import 'transaction_item_entity.dart';

/// Represents a complete sales transaction
/// Integrates with user session for cashier tracking
/// Automatically updates inventory upon completion
class TransactionEntity {
  final String uid;
  final String transactionNumber; // e.g., INV-20251217-001
  final DateTime transactionDate;

  // Cashier info (integrated with user session)
  final CashierInfo cashier;

  // Transaction items
  final List<TransactionItemEntity> items;

  // Pricing summary
  final String subtotal; // Sum of all item subtotals
  final String discount; // Discount amount
  final String discountPercent; // Discount percentage
  final String tax; // Tax amount (if applicable)
  final String totalAmount; // Final total after discount and tax
  final String totalProfit; // Total profit from this transaction

  // Payment information
  final String paymentMethod; // cash, transfer, qris, card
  final String amountPaid; // Amount paid by customer
  final String change; // Change returned to customer

  // Status and metadata
  final String status; // pending, completed, cancelled
  final DateTime createdAt;
  final DateTime updatedAt;
  final String notes; // Additional notes

  TransactionEntity({
    required this.uid,
    required this.transactionNumber,
    required this.transactionDate,
    required this.cashier,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.discountPercent,
    required this.tax,
    required this.totalAmount,
    required this.totalProfit,
    required this.paymentMethod,
    required this.amountPaid,
    required this.change,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.notes,
  });

  /// Create a copy with modified fields
  TransactionEntity copyWith({
    String? uid,
    String? transactionNumber,
    DateTime? transactionDate,
    CashierInfo? cashier,
    List<TransactionItemEntity>? items,
    String? subtotal,
    String? discount,
    String? discountPercent,
    String? tax,
    String? totalAmount,
    String? totalProfit,
    String? paymentMethod,
    String? amountPaid,
    String? change,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return TransactionEntity(
      uid: uid ?? this.uid,
      transactionNumber: transactionNumber ?? this.transactionNumber,
      transactionDate: transactionDate ?? this.transactionDate,
      cashier: cashier ?? this.cashier,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      discountPercent: discountPercent ?? this.discountPercent,
      tax: tax ?? this.tax,
      totalAmount: totalAmount ?? this.totalAmount,
      totalProfit: totalProfit ?? this.totalProfit,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
      change: change ?? this.change,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }

  /// Calculate total items count
  int get totalItems => items.length;

  /// Calculate total quantity sold
  int get totalQuantitySold {
    return items.fold<int>(
      0,
      (sum, item) => sum + (int.tryParse(item.quantity) ?? 0),
    );
  }
}
