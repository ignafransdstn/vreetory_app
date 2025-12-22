import '../repositories/transaction_repository.dart';
import '../entities/transaction_entity.dart';

/// Use case for getting transaction by ID
class GetTransactionById {
  final TransactionRepository repository;

  GetTransactionById(this.repository);

  Future<TransactionEntity?> call(String uid) async {
    return await repository.getTransactionById(uid);
  }
}
