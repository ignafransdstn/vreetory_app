/// Entity representing aggregated sales data for a specific period
/// Used for daily and monthly sales reporting
class SalesSummaryEntity {
  final DateTime date;
  final int totalTransactions;
  final double totalSales;
  final double totalProfit;
  final double totalDiscount;
  final double averageTransaction;
  final Map<String, double>
      paymentMethodBreakdown; // {cash: 1000, transfer: 500, ...}
  final Map<String, int> paymentMethodCount; // {cash: 5, transfer: 3, ...}
  final int totalItemsSold;

  const SalesSummaryEntity({
    required this.date,
    required this.totalTransactions,
    required this.totalSales,
    required this.totalProfit,
    required this.totalDiscount,
    required this.averageTransaction,
    required this.paymentMethodBreakdown,
    required this.paymentMethodCount,
    required this.totalItemsSold,
  });

  SalesSummaryEntity copyWith({
    DateTime? date,
    int? totalTransactions,
    double? totalSales,
    double? totalProfit,
    double? totalDiscount,
    double? averageTransaction,
    Map<String, double>? paymentMethodBreakdown,
    Map<String, int>? paymentMethodCount,
    int? totalItemsSold,
  }) {
    return SalesSummaryEntity(
      date: date ?? this.date,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      totalSales: totalSales ?? this.totalSales,
      totalProfit: totalProfit ?? this.totalProfit,
      totalDiscount: totalDiscount ?? this.totalDiscount,
      averageTransaction: averageTransaction ?? this.averageTransaction,
      paymentMethodBreakdown:
          paymentMethodBreakdown ?? this.paymentMethodBreakdown,
      paymentMethodCount: paymentMethodCount ?? this.paymentMethodCount,
      totalItemsSold: totalItemsSold ?? this.totalItemsSold,
    );
  }

  @override
  String toString() {
    return 'SalesSummaryEntity(date: $date, totalTransactions: $totalTransactions, totalSales: $totalSales)';
  }
}

/// Entity representing top-selling items in a period
class TopSellingItemEntity {
  final String itemName;
  final String itemId;
  final double quantitySold;
  final double totalRevenue;
  final double totalProfit;
  final String category;

  const TopSellingItemEntity({
    required this.itemName,
    required this.itemId,
    required this.quantitySold,
    required this.totalRevenue,
    required this.totalProfit,
    required this.category,
  });

  @override
  String toString() {
    return 'TopSellingItemEntity(itemName: $itemName, quantitySold: $quantitySold, totalRevenue: $totalRevenue)';
  }
}
