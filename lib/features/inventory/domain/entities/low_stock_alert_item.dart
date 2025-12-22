/// Status enum for low stock items
enum LowStockStatus {
  critical, // Below minimum stock
  warning, // Within 20% of minimum stock
  normal, // Above minimum stock
}

class LowStockAlertItem {
  final String itemId;
  final String itemName;
  final double currentQuantity;
  final double minimumStock;
  final String category;
  final String supplier;
  final String measure;
  final LowStockStatus status;
  final double stockPercentage; // (currentQuantity / minimumStock) * 100

  const LowStockAlertItem({
    required this.itemId,
    required this.itemName,
    required this.currentQuantity,
    required this.minimumStock,
    required this.category,
    required this.supplier,
    required this.measure,
    required this.status,
    required this.stockPercentage,
  });

  String get statusLabel {
    switch (status) {
      case LowStockStatus.critical:
        return 'Critical';
      case LowStockStatus.warning:
        return 'Warning';
      case LowStockStatus.normal:
        return 'Normal';
    }
  }

  /// Calculate deficit quantity (how much more is needed to reach minimum stock)
  double get deficitQuantity {
    final deficit = minimumStock - currentQuantity;
    return deficit > 0 ? deficit : 0;
  }
}
