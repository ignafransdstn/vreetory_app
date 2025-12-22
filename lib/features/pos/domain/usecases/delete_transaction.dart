import '../repositories/transaction_repository.dart';

/// Use case for deleting transaction (admin only)
class DeleteTransaction {
  final TransactionRepository repository;

  DeleteTransaction(this.repository);

  Future<void> call(String uid) async {
    return await repository.deleteTransaction(uid);
  }
}
