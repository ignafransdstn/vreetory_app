import '../entities/transaction_entity.dart';

/// Repository interface for transaction operations
abstract class TransactionRepository {
  /// Create a new transaction and update inventory
  Future<TransactionEntity> createTransaction(TransactionEntity transaction);

  /// Get transaction by ID
  Future<TransactionEntity?> getTransactionById(String uid);

  /// Get all transactions
  Future<List<TransactionEntity>> getAllTransactions();

  /// Get transactions by cashier
  Future<List<TransactionEntity>> getTransactionsByCashier(String cashierUid);

  /// Get transactions by date range
  Future<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get transactions by payment method
  Future<List<TransactionEntity>> getTransactionsByPaymentMethod(
    String paymentMethod,
  );

  /// Get transactions by status
  Future<List<TransactionEntity>> getTransactionsByStatus(String status);

  /// Update transaction status
  Future<void> updateTransactionStatus(String uid, String status);

  /// Delete transaction (admin only)
  Future<void> deleteTransaction(String uid);
}
