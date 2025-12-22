import '../repositories/transaction_repository.dart';
import '../entities/transaction_entity.dart';

/// Use case for getting all transactions
class GetAllTransactions {
  final TransactionRepository repository;

  GetAllTransactions(this.repository);

  Future<List<TransactionEntity>> call() async {
    return await repository.getAllTransactions();
  }
}
