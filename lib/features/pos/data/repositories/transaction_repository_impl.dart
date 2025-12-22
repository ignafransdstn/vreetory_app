import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

/// Implementation of TransactionRepository
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl(this.remoteDataSource);

  @override
  Future<TransactionEntity> createTransaction(
      TransactionEntity transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    final result = await remoteDataSource.createTransaction(model);
    return result;
  }

  @override
  Future<TransactionEntity?> getTransactionById(String uid) async {
    return await remoteDataSource.getTransactionById(uid);
  }

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    final models = await remoteDataSource.getAllTransactions();
    return models.cast<TransactionEntity>();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByCashier(
      String cashierUid) async {
    final models = await remoteDataSource.getTransactionsByCashier(cashierUid);
    return models.cast<TransactionEntity>();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final models = await remoteDataSource.getTransactionsByDateRange(
      startDate,
      endDate,
    );
    return models.cast<TransactionEntity>();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByPaymentMethod(
    String paymentMethod,
  ) async {
    final models = await remoteDataSource.getTransactionsByPaymentMethod(
      paymentMethod,
    );
    return models.cast<TransactionEntity>();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByStatus(String status) async {
    final models = await remoteDataSource.getTransactionsByStatus(status);
    return models.cast<TransactionEntity>();
  }

  @override
  Future<void> updateTransactionStatus(String uid, String status) async {
    await remoteDataSource.updateTransactionStatus(uid, status);
  }

  @override
  Future<void> deleteTransaction(String uid) async {
    await remoteDataSource.deleteTransaction(uid);
  }
}
