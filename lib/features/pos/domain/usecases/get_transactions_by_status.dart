import '../repositories/transaction_repository.dart';
import '../entities/transaction_entity.dart';

/// Use case for getting transactions by status
class GetTransactionsByStatus {
  final TransactionRepository repository;

  GetTransactionsByStatus(this.repository);

  Future<List<TransactionEntity>> call(String status) async {
    return await repository.getTransactionsByStatus(status);
  }
}
