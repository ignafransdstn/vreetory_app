import '../repositories/transaction_repository.dart';
import '../entities/transaction_entity.dart';

/// Use case for getting transactions by date range
class GetTransactionsByDateRange {
  final TransactionRepository repository;

  GetTransactionsByDateRange(this.repository);

  Future<List<TransactionEntity>> call(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await repository.getTransactionsByDateRange(startDate, endDate);
  }
}
