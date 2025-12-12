class StockValuationItem {
  final String uid;
  final String itemName;
  final String itemCode;
  final String category;
  final double quantity;
  final double buyRate;
  final double sellRate;
  final String measure;
  final String status;
  final String supplier;
  
  // Calculated fields
  double get inventoryValue => quantity * buyRate;
  double get potentialRevenue => quantity * sellRate;
  double get profitMargin => potentialRevenue - inventoryValue;
  double get profitMarginPercent => buyRate > 0 ? ((sellRate - buyRate) / buyRate * 100) : 0;

  StockValuationItem({
    required this.uid,
    required this.itemName,
    required this.itemCode,
    required this.category,
    required this.quantity,
    required this.buyRate,
    required this.sellRate,
    required this.measure,
    required this.status,
    required this.supplier,
  });
}

class StockValuationSummary {
  final double totalInventoryValue;
  final double totalPotentialRevenue;
  final double totalProfit;
  final int totalItems;
  final int activeItems;
  final int inactiveItems;
  final Map<String, double> valueByCategory;
  final List<StockValuationItem> topItemsByValue;

  StockValuationSummary({
    required this.totalInventoryValue,
    required this.totalPotentialRevenue,
    required this.totalProfit,
    required this.totalItems,
    required this.activeItems,
    required this.inactiveItems,
    required this.valueByCategory,
    required this.topItemsByValue,
  });

  double get totalProfitMarginPercent => 
    totalPotentialRevenue > 0 ? (totalProfit / totalPotentialRevenue * 100) : 0;
}
