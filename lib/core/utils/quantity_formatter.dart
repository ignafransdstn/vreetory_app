/// Utility functions for formatting quantities based on measure type
class QuantityFormatter {
  /// Format quantity to display - removes unnecessary decimals for whole numbers
  /// Example: 1.0 kg -> "1", 1.5 kg -> "1.5", 2.0 pcs -> "2"
  static String format(String quantity) {
    final value = double.tryParse(quantity);
    if (value == null) return quantity;

    // If it's a whole number, show as integer
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }

    // Otherwise show with decimals (up to 2 decimal places)
    return value.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  /// Format quantity with measure
  /// Example: formatWithMeasure("1.5", "KG") -> "1.5 kg"
  static String formatWithMeasure(String quantity, String measure) {
    return '${format(quantity)} ${measure.toLowerCase()}';
  }

  /// Parse quantity string to double
  static double parse(String quantity) {
    return double.tryParse(quantity) ?? 0.0;
  }

  /// Check if a measure allows decimal quantities
  static bool allowsDecimal(String measure) {
    final upperMeasure = measure.toUpperCase();
    return upperMeasure == 'KG' ||
        upperMeasure == 'LITER' ||
        upperMeasure == 'L' ||
        upperMeasure == 'ML';
  }
}
