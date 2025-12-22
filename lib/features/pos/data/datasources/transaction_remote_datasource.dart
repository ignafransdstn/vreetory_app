import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

/// Remote data source for transaction operations with Firestore
class TransactionRemoteDataSource {
  final FirebaseFirestore firestore;

  TransactionRemoteDataSource(this.firestore);

  /// Create a new transaction
  Future<TransactionModel> createTransaction(
      TransactionModel transaction) async {
    // Generate new document reference
    final docRef = firestore.collection('transactions').doc();

    // Create transaction with generated ID
    final newTransaction = TransactionModel.fromEntity(
      transaction.copyWith(uid: docRef.id),
    );

    // Save to Firestore
    await docRef.set(newTransaction.toJson());

    return newTransaction;
  }

  /// Get transaction by ID
  Future<TransactionModel?> getTransactionById(String uid) async {
    final doc = await firestore.collection('transactions').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      return TransactionModel.fromJson(doc.data()!);
    }
    return null;
  }

  /// Get all transactions
  Future<List<TransactionModel>> getAllTransactions() async {
    final querySnapshot = await firestore
        .collection('transactions')
        .orderBy('transaction_date', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data()))
        .toList();
  }

  /// Get transactions by cashier
  Future<List<TransactionModel>> getTransactionsByCashier(
      String cashierUid) async {
    final querySnapshot = await firestore
        .collection('transactions')
        .where('cashier.uid', isEqualTo: cashierUid)
        .orderBy('transaction_date', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data()))
        .toList();
  }

  /// Get transactions by date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final querySnapshot = await firestore
        .collection('transactions')
        .where('transaction_date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('transaction_date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('transaction_date', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data()))
        .toList();
  }

  /// Get transactions by payment method
  Future<List<TransactionModel>> getTransactionsByPaymentMethod(
    String paymentMethod,
  ) async {
    final querySnapshot = await firestore
        .collection('transactions')
        .where('payment_method', isEqualTo: paymentMethod)
        .orderBy('transaction_date', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data()))
        .toList();
  }

  /// Get transactions by status
  Future<List<TransactionModel>> getTransactionsByStatus(String status) async {
    final querySnapshot = await firestore
        .collection('transactions')
        .where('status', isEqualTo: status)
        .orderBy('transaction_date', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data()))
        .toList();
  }

  /// Update transaction status
  Future<void> updateTransactionStatus(String uid, String status) async {
    await firestore.collection('transactions').doc(uid).update({
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Delete transaction
  Future<void> deleteTransaction(String uid) async {
    await firestore.collection('transactions').doc(uid).delete();
  }

  /// Get daily sales summary for a specific date
  Future<Map<String, dynamic>> getDailySalesSummary(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final querySnapshot = await firestore
        .collection('transactions')
        .where('transaction_date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('transaction_date',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .where('status', isEqualTo: 'completed')
        .get();

    double totalRevenue = 0;
    double totalProfit = 0;
    int totalTransactions = querySnapshot.docs.length;
    Map<String, int> cashierTransactions = {};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      totalRevenue += double.parse(data['total_amount'] as String);
      totalProfit += double.parse(data['total_profit'] as String);

      final cashierUid = data['cashier']['uid'] as String;
      cashierTransactions[cashierUid] =
          (cashierTransactions[cashierUid] ?? 0) + 1;
    }

    return {
      'date': date.toIso8601String(),
      'total_transactions': totalTransactions,
      'total_revenue': totalRevenue,
      'total_profit': totalProfit,
      'cashier_transactions': cashierTransactions,
    };
  }
}
