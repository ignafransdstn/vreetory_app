import 'package:intl/intl.dart';

class ExpiryAlertItem {
  final String uid;
  final String itemName;
  final String itemCode;
  final String category;
  final double quantity;
  final DateTime expiryDate;
  final String measure;
  final String supplier;

  ExpiryAlertItem({
    required this.uid,
    required this.itemName,
    required this.itemCode,
    required this.category,
    required this.quantity,
    required this.expiryDate,
    required this.measure,
    required this.supplier,
  });

  // Get days until expiry (negative if already expired)
  int get daysUntilExpiry {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  // Get expiry status
  ExpiryStatus get expiryStatus {
    final days = daysUntilExpiry;
    if (days < 0) {
      return ExpiryStatus.expired;
    } else if (days == 0) {
      return ExpiryStatus.expiringToday;
    } else if (days <= 7) {
      return ExpiryStatus.expiringWithinWeek;
    } else if (days <= 30) {
      return ExpiryStatus.expiringWithinMonth;
    } else {
      return ExpiryStatus.safe;
    }
  }

  // Get formatted expiry date
  String get formattedExpiryDate {
    return DateFormat('dd MMM yyyy').format(expiryDate);
  }

  // Get risk score (higher = more urgent)
  int get riskScore {
    final days = daysUntilExpiry;
    if (days < 0) return 100; // Expired
    if (days == 0) return 90; // Expiring today
    if (days <= 7) return 80 - (days * 5); // Within week
    if (days <= 30) return 40 - (days ~/ 3); // Within month
    return 0; // Safe
  }
}

enum ExpiryStatus {
  expired,
  expiringToday,
  expiringWithinWeek,
  expiringWithinMonth,
  safe,
}

class ExpiryAlertSummary {
  final List<ExpiryAlertItem> allItems;
  final int totalItems;
  final int expiredItems;
  final int expiringTodayItems;
  final int expiringWithinWeekItems;
  final int expiringWithinMonthItems;
  final int safeItems;
  final List<ExpiryAlertItem> topRiskItems;
  final Map<String, int> itemsByCategory;

  ExpiryAlertSummary({
    required this.allItems,
    required this.totalItems,
    required this.expiredItems,
    required this.expiringTodayItems,
    required this.expiringWithinWeekItems,
    required this.expiringWithinMonthItems,
    required this.safeItems,
    required this.topRiskItems,
    required this.itemsByCategory,
  });

  // Get total at-risk items (expired + expiring within 30 days)
  int get totalAtRiskItems =>
      expiredItems +
      expiringTodayItems +
      expiringWithinWeekItems +
      expiringWithinMonthItems;

  // Get total quantity at risk
  double get totalAtRiskQuantity {
    return allItems
        .where((item) =>
            item.expiryStatus == ExpiryStatus.expired ||
            item.expiryStatus == ExpiryStatus.expiringToday ||
            item.expiryStatus == ExpiryStatus.expiringWithinWeek ||
            item.expiryStatus == ExpiryStatus.expiringWithinMonth)
        .fold(0.0, (sum, item) => sum + item.quantity);
  }

  // Get risk percentage
  double get riskPercentage {
    if (totalItems == 0) return 0;
    return (totalAtRiskItems / totalItems) * 100;
  }
}
