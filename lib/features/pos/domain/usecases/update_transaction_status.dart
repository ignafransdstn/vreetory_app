import '../repositories/transaction_repository.dart';

/// Use case for updating transaction status
class UpdateTransactionStatus {
  final TransactionRepository repository;

  UpdateTransactionStatus(this.repository);

  Future<void> call(String uid, String status) async {
    // Validate status
    const validStatuses = ['pending', 'completed', 'cancelled'];
    if (!validStatuses.contains(status.toLowerCase())) {
      throw Exception(
        'Invalid status: $status. Valid statuses are: ${validStatuses.join(', ')}',
      );
    }

    return await repository.updateTransactionStatus(uid, status);
  }
}
