import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/validate_stock.dart';
import '../../domain/usecases/get_all_transactions.dart';
import '../../domain/usecases/get_transaction_by_id.dart';
import '../../domain/usecases/get_transactions_by_cashier.dart';
import '../../domain/usecases/get_transactions_by_date_range.dart';
import '../../../inventory/presentation/provider/item_provider.dart';

/// Transaction Remote DataSource Provider
final transactionRemoteDataSourceProvider =
    Provider<TransactionRemoteDataSource>((ref) {
  return TransactionRemoteDataSource(FirebaseFirestore.instance);
});

/// Transaction Repository Provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dataSource = ref.watch(transactionRemoteDataSourceProvider);
  return TransactionRepositoryImpl(dataSource);
});

/// Validate Stock Use Case Provider
final validateStockProvider = Provider<ValidateStock>((ref) {
  final itemRepository = ref.watch(itemRepositoryProvider);
  return ValidateStock(itemRepository);
});

/// Create Transaction Use Case Provider
final createTransactionProvider = Provider<CreateTransaction>((ref) {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  final itemRepository = ref.watch(itemRepositoryProvider);
  final validateStock = ref.watch(validateStockProvider);

  return CreateTransaction(
    transactionRepository: transactionRepository,
    itemRepository: itemRepository,
    validateStock: validateStock,
  );
});

/// Get All Transactions Use Case Provider
final getAllTransactionsProvider = Provider<GetAllTransactions>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return GetAllTransactions(repository);
});

/// Get Transaction By Id Use Case Provider
final getTransactionByIdProvider = Provider<GetTransactionById>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return GetTransactionById(repository);
});

/// Get Transactions By Cashier Use Case Provider
final getTransactionsByCashierProvider =
    Provider<GetTransactionsByCashier>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return GetTransactionsByCashier(repository);
});

/// Get Transactions By Date Range Use Case Provider
final getTransactionsByDateRangeProvider =
    Provider<GetTransactionsByDateRange>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return GetTransactionsByDateRange(repository);
});
