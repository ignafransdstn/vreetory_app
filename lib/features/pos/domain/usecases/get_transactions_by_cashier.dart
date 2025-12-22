import '../repositories/transaction_repository.dart';
import '../entities/transaction_entity.dart';

/// Use case for getting transactions by cashier
class GetTransactionsByCashier {
  final TransactionRepository repository;

  GetTransactionsByCashier(this.repository);

  Future<List<TransactionEntity>> call(String cashierUid) async {
    return await repository.getTransactionsByCashier(cashierUid);
  }
}
