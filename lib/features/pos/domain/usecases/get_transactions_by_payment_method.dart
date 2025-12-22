import '../repositories/transaction_repository.dart';
import '../entities/transaction_entity.dart';

/// Use case for getting transactions by payment method
class GetTransactionsByPaymentMethod {
  final TransactionRepository repository;

  GetTransactionsByPaymentMethod(this.repository);

  Future<List<TransactionEntity>> call(String paymentMethod) async {
    return await repository.getTransactionsByPaymentMethod(paymentMethod);
  }
}
