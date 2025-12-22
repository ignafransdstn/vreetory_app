import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/get_all_transactions.dart';
import '../../domain/usecases/get_transactions_by_cashier.dart';
import '../../domain/usecases/get_transactions_by_date_range.dart';
import 'transaction_repository_provider.dart';
import 'cashier_session_provider.dart';

/// Transaction History State
class TransactionHistoryState {
  final List<TransactionEntity> transactions;
  final bool isLoading;
  final String? error;

  TransactionHistoryState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  factory TransactionHistoryState.initial() => TransactionHistoryState();

  TransactionHistoryState copyWith({
    List<TransactionEntity>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return TransactionHistoryState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Transaction History Notifier
class TransactionHistoryNotifier
    extends StateNotifier<TransactionHistoryState> {
  final GetAllTransactions getAllTransactions;
  final GetTransactionsByCashier getTransactionsByCashier;
  final GetTransactionsByDateRange getTransactionsByDateRange;
  final Ref ref;

  TransactionHistoryNotifier({
    required this.getAllTransactions,
    required this.getTransactionsByCashier,
    required this.getTransactionsByDateRange,
    required this.ref,
  }) : super(TransactionHistoryState.initial());

  /// Fetch all transactions (admin only)
  Future<void> fetchAllTransactions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final transactions = await getAllTransactions.call();
      state = state.copyWith(
        transactions: transactions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading transactions: $e',
      );
    }
  }

  /// Fetch current cashier's transactions
  Future<void> fetchMyCashierTransactions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashier = ref.read(currentCashierProvider);
      if (cashier == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not logged in',
        );
        return;
      }

      final transactions = await getTransactionsByCashier.call(cashier.uid);
      state = state.copyWith(
        transactions: transactions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading transactions: $e',
      );
    }
  }

  /// Fetch transactions by date range
  Future<void> fetchTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final transactions = await getTransactionsByDateRange.call(
        startDate,
        endDate,
      );
      state = state.copyWith(
        transactions: transactions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading transactions: $e',
      );
    }
  }

  /// Get today's transactions
  Future<void> fetchTodayTransactions() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    await fetchTransactionsByDateRange(startOfDay, endOfDay);
  }

  /// Calculate summary statistics
  Map<String, dynamic> calculateSummary() {
    final transactions = state.transactions;

    double totalRevenue = 0;
    double totalProfit = 0;
    int totalTransactions = transactions.length;

    Map<String, int> paymentMethods = {};

    for (var transaction in transactions) {
      if (transaction.status == 'completed') {
        totalRevenue += double.parse(transaction.totalAmount);
        totalProfit += double.parse(transaction.totalProfit);

        paymentMethods[transaction.paymentMethod] =
            (paymentMethods[transaction.paymentMethod] ?? 0) + 1;
      }
    }

    return {
      'totalRevenue': totalRevenue,
      'totalProfit': totalProfit,
      'totalTransactions': totalTransactions,
      'averageTransaction':
          totalTransactions > 0 ? totalRevenue / totalTransactions : 0,
      'paymentMethods': paymentMethods,
    };
  }
}

/// Transaction History Provider
final transactionHistoryProvider =
    StateNotifierProvider<TransactionHistoryNotifier, TransactionHistoryState>(
        (ref) {
  return TransactionHistoryNotifier(
    getAllTransactions: ref.watch(getAllTransactionsProvider),
    getTransactionsByCashier: ref.watch(getTransactionsByCashierProvider),
    getTransactionsByDateRange: ref.watch(getTransactionsByDateRangeProvider),
    ref: ref,
  );
});
