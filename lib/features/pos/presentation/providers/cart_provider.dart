import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vreetory_app/features/inventory/domain/repositories/item_repository.dart';
import 'package:vreetory_app/features/inventory/domain/entities/item_entity.dart';
import 'package:vreetory_app/features/inventory/presentation/provider/item_provider.dart';
import 'package:vreetory_app/features/pos/domain/entities/cart_item.dart';
import 'package:vreetory_app/features/pos/domain/entities/cart_state.dart';

/// Cart Notifier with real-time stock validation
class CartNotifier extends StateNotifier<CartState> {
  final ItemRepository itemRepository;

  CartNotifier(this.itemRepository) : super(CartState.initial());

  /// Add item to cart with real-time stock validation
  Future<bool> addToCart(ItemEntity item, {double quantity = 1}) async {
    try {
      state = state.asLoading();

      // Validate item status
      if (item.status.toLowerCase() != 'active') {
        state = state.asError('Item ${item.itemName} tidak aktif');
        return false;
      }

      // Check available stock
      final availableStock = double.parse(item.quantity);
      if (availableStock <= 0) {
        state = state.asError('Stok ${item.itemName} habis');
        return false;
      }

      // Check if item already in cart
      final existingIndex = state.items.indexWhere((i) => i.itemId == item.uid);

      List<CartItem> updatedItems;

      if (existingIndex >= 0) {
        // Item exists, update quantity
        final existingItem = state.items[existingIndex];
        final currentQty = double.parse(existingItem.quantity);
        final newQty = currentQty + quantity;

        // Validate total quantity against stock
        if (newQty > availableStock) {
          state = state.asError(
            'Stok tidak cukup!\n'
            'Tersedia: $availableStock ${item.measure}\n'
            'Di keranjang: $currentQty ${item.measure}\n'
            'Diminta tambahan: $quantity ${item.measure}',
          );
          return false;
        }

        // Update existing item
        updatedItems = List.from(state.items);
        updatedItems[existingIndex] = existingItem.copyWith(
          quantity: newQty.toString(),
          availableStock: item.quantity, // Update with latest stock
        );
      } else {
        // New item, validate quantity
        if (quantity > availableStock) {
          state = state.asError(
            'Stok tidak cukup!\n'
            'Tersedia: $availableStock ${item.measure}\n'
            'Diminta: $quantity ${item.measure}',
          );
          return false;
        }

        // Add new item to cart
        final cartItem = CartItem.fromItem(item, quantity.toString());
        updatedItems = [...state.items, cartItem];
      }

      state = state.withItems(updatedItems);
      return true;
    } catch (e) {
      state = state.asError('Error menambahkan ke keranjang: $e');
      return false;
    }
  }

  /// Update item quantity with stock validation
  Future<bool> updateQuantity(String itemId, double newQuantity) async {
    try {
      state = state.asLoading();

      // Validate new quantity
      if (newQuantity <= 0) {
        return removeItem(itemId);
      }

      // Find item in cart
      final itemIndex = state.items.indexWhere((i) => i.itemId == itemId);
      if (itemIndex == -1) {
        state = state.asError('Item tidak ditemukan di keranjang');
        return false;
      }

      final cartItem = state.items[itemIndex];

      // Get latest stock from database
      final currentItem = await itemRepository.getItem(itemId);
      if (currentItem == null) {
        state = state.asError('Item tidak ditemukan');
        return false;
      }

      // Validate stock
      final availableStock = double.parse(currentItem.quantity);
      if (newQuantity > availableStock) {
        state = state.asError(
          'Stok tidak cukup!\n'
          'Tersedia: $availableStock ${cartItem.measure}\n'
          'Diminta: $newQuantity ${cartItem.measure}',
        );
        return false;
      }

      // Update item
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[itemIndex] = cartItem.copyWith(
        quantity: newQuantity.toString(),
        availableStock: currentItem.quantity,
      );

      state = state.withItems(updatedItems);
      return true;
    } catch (e) {
      state = state.asError('Error update quantity: $e');
      return false;
    }
  }

  /// Increment item quantity
  Future<bool> incrementQuantity(String itemId) async {
    final item = state.items.firstWhere((i) => i.itemId == itemId);
    final currentQty = double.parse(item.quantity);
    final measure = item.measure.toUpperCase();
    final increment =
        (measure == 'KG' || measure == 'LITER' || measure == 'L') ? 0.5 : 1.0;
    return await updateQuantity(itemId, currentQty + increment);
  }

  /// Decrement item quantity
  Future<bool> decrementQuantity(String itemId) async {
    final item = state.items.firstWhere((i) => i.itemId == itemId);
    final currentQty = double.parse(item.quantity);
    final measure = item.measure.toUpperCase();
    final decrement =
        (measure == 'KG' || measure == 'LITER' || measure == 'L') ? 0.5 : 1.0;
    return await updateQuantity(itemId, currentQty - decrement);
  }

  /// Remove item from cart
  bool removeItem(String itemId) {
    try {
      final updatedItems =
          state.items.where((i) => i.itemId != itemId).toList();
      state = state.withItems(updatedItems);
      return true;
    } catch (e) {
      state = state.asError('Error menghapus item: $e');
      return false;
    }
  }

  /// Clear all items from cart
  void clearCart() {
    state = CartState.initial();
  }

  /// Apply discount (amount or percentage)
  void applyDiscount({double amount = 0, double percent = 0}) {
    double discountAmount = amount;

    if (percent > 0) {
      discountAmount = state.subtotal * (percent / 100);
    }

    // Ensure discount doesn't exceed subtotal
    if (discountAmount > state.subtotal) {
      discountAmount = state.subtotal;
    }

    state = state.withDiscount(discountAmount, percent);
  }

  /// Remove discount
  void removeDiscount() {
    state = state.withDiscount(0, 0);
  }

  /// Apply tax
  void applyTax(double taxAmount) {
    state = state.withTax(taxAmount);
  }

  /// Refresh stock for all items in cart
  Future<void> refreshStock() async {
    try {
      state = state.asLoading();

      final updatedItems = <CartItem>[];

      for (var cartItem in state.items) {
        // Get latest stock from database
        final currentItem = await itemRepository.getItem(cartItem.itemId);

        if (currentItem == null) {
          // Item no longer exists
          continue;
        }

        // Update cart item with latest stock
        updatedItems.add(
          cartItem.copyWith(availableStock: currentItem.quantity),
        );
      }

      state = state.withItems(updatedItems);
    } catch (e) {
      state = state.asError('Error refresh stok: $e');
    }
  }

  /// Validate all items before checkout
  Future<Map<String, dynamic>> validateCheckout() async {
    try {
      await refreshStock();

      if (state.hasInsufficientStock) {
        final insufficientItems = state.itemsWithInsufficientStock;
        return {
          'valid': false,
          'message': 'Beberapa item stok tidak cukup',
          'insufficientItems': insufficientItems,
        };
      }

      if (state.isEmpty) {
        return {
          'valid': false,
          'message': 'Keranjang kosong',
        };
      }

      return {
        'valid': true,
        'message': 'Validasi berhasil',
      };
    } catch (e) {
      return {
        'valid': false,
        'message': 'Error validasi: $e',
      };
    }
  }

  /// Get cart summary for display
  Map<String, dynamic> getCartSummary() {
    return {
      'itemCount': state.itemCount,
      'totalQuantity': state.totalQuantity,
      'subtotal': state.subtotal,
      'discount': state.discount,
      'discountPercent': state.discountPercent,
      'tax': state.tax,
      'total': state.total,
      'totalProfit': state.totalProfit,
    };
  }
}

/// Cart Provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final itemRepository = ref.watch(itemRepositoryProvider);
  return CartNotifier(itemRepository);
});
