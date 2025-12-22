import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pos/domain/entities/transaction_entity.dart';
import '../../../pos/presentation/providers/transaction_repository_provider.dart';
import '../../domain/entities/sales_summary_entity.dart';

/// Provider for date range selection
final selectedDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Provider for view mode (daily/monthly)
final salesViewModeProvider =
    StateProvider<SalesViewMode>((ref) => SalesViewMode.daily);

enum SalesViewMode { daily, monthly }

/// Provider to fetch transactions for selected date range
final salesTransactionsProvider =
    FutureProvider<List<TransactionEntity>>((ref) async {
  final dateRange = ref.watch(selectedDateRangeProvider);
  final repository = ref.watch(transactionRepositoryProvider);

  if (dateRange == null) {
    // Default to today's transactions
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    return await repository.getTransactionsByDateRange(startOfDay, endOfDay);
  }

  return await repository.getTransactionsByDateRange(
    dateRange.start,
    dateRange.end,
  );
});

/// Provider to compute sales summary from transactions
final salesSummaryProvider = Provider<SalesSummaryEntity?>((ref) {
  final transactionsAsync = ref.watch(salesTransactionsProvider);

  return transactionsAsync.when(
    data: (transactions) {
      if (transactions.isEmpty) return null;

      // Filter only completed transactions
      final completedTransactions =
          transactions.where((t) => t.status == 'completed').toList();

      if (completedTransactions.isEmpty) return null;

      // Calculate totals
      double totalSales = 0;
      double totalProfit = 0;
      double totalDiscount = 0;
      int totalItemsSold = 0;
      Map<String, double> paymentMethodBreakdown = {};
      Map<String, int> paymentMethodCount = {};

      for (var transaction in completedTransactions) {
        final sales = double.tryParse(transaction.totalAmount) ?? 0;
        final profit = double.tryParse(transaction.totalProfit) ?? 0;
        final discount = double.tryParse(transaction.discount) ?? 0;

        totalSales += sales;
        totalProfit += profit;
        totalDiscount += discount;
        totalItemsSold += transaction.items.length;

        // Payment method breakdown
        final method = transaction.paymentMethod;
        paymentMethodBreakdown[method] =
            (paymentMethodBreakdown[method] ?? 0) + sales;
        paymentMethodCount[method] = (paymentMethodCount[method] ?? 0) + 1;
      }

      final averageTransaction = completedTransactions.isNotEmpty
          ? (totalSales / completedTransactions.length).toDouble()
          : 0.0;

      // Use the first transaction date as reference
      final referenceDate = completedTransactions.first.transactionDate;

      return SalesSummaryEntity(
        date: referenceDate,
        totalTransactions: completedTransactions.length,
        totalSales: totalSales,
        totalProfit: totalProfit,
        totalDiscount: totalDiscount,
        averageTransaction: averageTransaction,
        paymentMethodBreakdown: paymentMethodBreakdown,
        paymentMethodCount: paymentMethodCount,
        totalItemsSold: totalItemsSold,
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider to compute top selling items
final topSellingItemsProvider = Provider<List<TopSellingItemEntity>>((ref) {
  final transactionsAsync = ref.watch(salesTransactionsProvider);

  return transactionsAsync.when(
    data: (transactions) {
      if (transactions.isEmpty) return [];

      // Filter only completed transactions
      final completedTransactions =
          transactions.where((t) => t.status == 'completed').toList();

      if (completedTransactions.isEmpty) return [];

      // Aggregate items
      Map<String, Map<String, dynamic>> itemAggregation = {};

      for (var transaction in completedTransactions) {
        for (var item in transaction.items) {
          if (!itemAggregation.containsKey(item.itemId)) {
            itemAggregation[item.itemId] = {
              'itemName': item.itemName,
              'itemId': item.itemId,
              'category': item.category,
              'quantitySold': 0.0,
              'totalRevenue': 0.0,
              'totalProfit': 0.0,
            };
          }

          final quantity = double.tryParse(item.quantity) ?? 0.0;
          final subtotal = double.tryParse(item.subtotal) ?? 0;
          final profit = double.tryParse(item.profit) ?? 0;

          itemAggregation[item.itemId]!['quantitySold'] += quantity;
          itemAggregation[item.itemId]!['totalRevenue'] += subtotal;
          itemAggregation[item.itemId]!['totalProfit'] += profit;
        }
      }

      // Convert to list and sort by quantity sold
      final topItems = itemAggregation.values.map((data) {
        return TopSellingItemEntity(
          itemName: data['itemName'] as String,
          itemId: data['itemId'] as String,
          quantitySold: data['quantitySold'] as double,
          totalRevenue: data['totalRevenue'] as double,
          totalProfit: data['totalProfit'] as double,
          category: data['category'] as String,
        );
      }).toList();

      // Sort by quantity sold (descending)
      topItems.sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

      // Return top 10
      return topItems.take(10).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for daily sales data (for charts)
final dailySalesDataProvider = Provider<List<DailySalesData>>((ref) {
  final transactionsAsync = ref.watch(salesTransactionsProvider);
  final viewMode = ref.watch(salesViewModeProvider);

  return transactionsAsync.when(
    data: (transactions) {
      if (transactions.isEmpty) return [];

      // Filter only completed transactions
      final completedTransactions =
          transactions.where((t) => t.status == 'completed').toList();

      if (completedTransactions.isEmpty) return [];

      // Group by date
      Map<DateTime, double> salesByDate = {};

      for (var transaction in completedTransactions) {
        final sales = double.tryParse(transaction.totalAmount) ?? 0;
        DateTime dateKey;

        if (viewMode == SalesViewMode.daily) {
          // Group by day
          dateKey = DateTime(
            transaction.transactionDate.year,
            transaction.transactionDate.month,
            transaction.transactionDate.day,
          );
        } else {
          // Group by month
          dateKey = DateTime(
            transaction.transactionDate.year,
            transaction.transactionDate.month,
          );
        }

        salesByDate[dateKey] = (salesByDate[dateKey] ?? 0) + sales;
      }

      // Convert to list and sort by date
      final dailyData = salesByDate.entries.map((entry) {
        return DailySalesData(date: entry.key, sales: entry.value);
      }).toList();

      dailyData.sort((a, b) => a.date.compareTo(b.date));

      return dailyData;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Helper class for daily sales chart data
class DailySalesData {
  final DateTime date;
  final double sales;

  DailySalesData({required this.date, required this.sales});
}
