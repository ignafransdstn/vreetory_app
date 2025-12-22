import 'cart_item.dart';

/// State for shopping cart
class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;

  // Pricing summary
  final double subtotal;
  final double discount;
  final double discountPercent;
  final double tax;
  final double total;
  final double totalProfit;

  CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.subtotal = 0,
    this.discount = 0,
    this.discountPercent = 0,
    this.tax = 0,
    this.total = 0,
    this.totalProfit = 0,
  });

  /// Create initial empty cart
  factory CartState.initial() {
    return CartState();
  }

  /// Create loading state
  CartState asLoading() {
    return CartState(
      items: items,
      isLoading: true,
      error: null,
      subtotal: subtotal,
      discount: discount,
      discountPercent: discountPercent,
      tax: tax,
      total: total,
      totalProfit: totalProfit,
    );
  }

  /// Create error state
  CartState asError(String error) {
    return CartState(
      items: items,
      isLoading: false,
      error: error,
      subtotal: subtotal,
      discount: discount,
      discountPercent: discountPercent,
      tax: tax,
      total: total,
      totalProfit: totalProfit,
    );
  }

  /// Create success state with recalculated totals
  CartState withItems(List<CartItem> items) {
    final calculatedSubtotal = items.fold<double>(
      0,
      (sum, item) => sum + double.parse(item.subtotal),
    );

    final calculatedProfit = items.fold<double>(
      0,
      (sum, item) => sum + double.parse(item.profit),
    );

    final calculatedTotal = calculatedSubtotal - discount + tax;

    return CartState(
      items: items,
      isLoading: false,
      error: null,
      subtotal: calculatedSubtotal,
      discount: discount,
      discountPercent: discountPercent,
      tax: tax,
      total: calculatedTotal,
      totalProfit: calculatedProfit,
    );
  }

  /// Update discount
  CartState withDiscount(double discount, double discountPercent) {
    final calculatedTotal = subtotal - discount + tax;

    return CartState(
      items: items,
      isLoading: false,
      error: null,
      subtotal: subtotal,
      discount: discount,
      discountPercent: discountPercent,
      tax: tax,
      total: calculatedTotal,
      totalProfit: totalProfit,
    );
  }

  /// Update tax
  CartState withTax(double tax) {
    final calculatedTotal = subtotal - discount + tax;

    return CartState(
      items: items,
      isLoading: false,
      error: null,
      subtotal: subtotal,
      discount: discount,
      discountPercent: discountPercent,
      tax: tax,
      total: calculatedTotal,
      totalProfit: totalProfit,
    );
  }

  /// Clear all
  CartState clear() {
    return CartState.initial();
  }

  /// Copy with
  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
    double? subtotal,
    double? discount,
    double? discountPercent,
    double? tax,
    double? total,
    double? totalProfit,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      discountPercent: discountPercent ?? this.discountPercent,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      totalProfit: totalProfit ?? this.totalProfit,
    );
  }

  /// Getters
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get itemCount => items.length;
  double get totalQuantity => items.fold<double>(
        0.0,
        (sum, item) => sum + double.parse(item.quantity),
      );

  /// Check if any item has insufficient stock
  bool get hasInsufficientStock =>
      items.any((item) => item.hasInsufficientStock);

  /// Get items with insufficient stock
  List<CartItem> get itemsWithInsufficientStock =>
      items.where((item) => item.hasInsufficientStock).toList();
}
