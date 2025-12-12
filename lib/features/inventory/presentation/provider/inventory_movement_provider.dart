import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/inventory_movement_datasource.dart';
import '../../data/repositories/inventory_movement_repository_impl.dart';
import '../../domain/entities/item_entity.dart';

class InventoryMovementItem {
  final ItemEntity item;
  final int quantityChange;
  final String movementType; // 'new_item', 'inbound' or 'outbound'
  final String sign; // '+', '-' or 'N' for new item

  InventoryMovementItem({
    required this.item,
    required this.quantityChange,
    required this.movementType,
    required this.sign,
  });
}

class InventoryMovementState {
  final List<InventoryMovementItem> movements;
  final bool isLoading;
  final String? errorMessage;

  InventoryMovementState({
    this.movements = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  InventoryMovementState copyWith({
    List<InventoryMovementItem>? movements,
    bool? isLoading,
    String? errorMessage,
  }) {
    return InventoryMovementState(
      movements: movements ?? this.movements,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class InventoryMovementNotifier extends StateNotifier<InventoryMovementState> {
  final InventoryMovementRepositoryImpl repository;

  InventoryMovementNotifier(this.repository) : super(InventoryMovementState());

  Future<void> fetchInventoryMovements() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await repository.getInventoryMovements();
      final movements = _convertToMovementItems(items);
      state = state.copyWith(movements: movements, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchMovementsByCategory(String category) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await repository.getMovementsByCategory(category);
      final movements = _convertToMovementItems(items);
      state = state.copyWith(movements: movements, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchMovementsByType(String type) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final movementsData = await repository.getMovementsByType(type);
      final movements = movementsData.map((m) {
        final item = m['item'] as ItemEntity;
        final change = m['change'] as int;
        final moveType = m['type'] as String;
        return InventoryMovementItem(
          item: item,
          quantityChange: change,
          movementType: moveType,
          sign: moveType == 'inbound' ? '+' : '-',
        );
      }).toList();
      state = state.copyWith(movements: movements, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchMovementsBySupplier(String supplier) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await repository.getMovementsBySupplier(supplier);
      final movements = _convertToMovementItems(items);
      state = state.copyWith(movements: movements, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  List<InventoryMovementItem> _convertToMovementItems(List<ItemEntity> items) {
    return items.map((item) {
      final currentQty = int.tryParse(item.quantity) ?? 0;
      final previousQty = int.tryParse(item.previousQuantity) ?? 0;
      final change = currentQty - previousQty;
      
      // Determine movement type
      String movementType;
      String sign;
      
      // Check if item is new: createdAt == updatedAt (same timestamp)
      final isNewItem = item.createdAt.isAtSameMomentAs(item.updatedAt);
      
      if (isNewItem) {
        // New item - created with initial quantity (could be 0 or more)
        movementType = 'new_item';
        sign = 'N';
      } else if (change > 0) {
        movementType = 'inbound';
        sign = '+';
      } else if (change < 0) {
        movementType = 'outbound';
        sign = '-';
      } else {
        // change == 0, no movement
        movementType = 'new_item';
        sign = 'N';
      }
      
      return InventoryMovementItem(
        item: item,
        quantityChange: change.abs(),
        movementType: movementType,
        sign: sign,
      );
    }).toList();
  }
}

// Provider
final inventoryMovementProvider =
    StateNotifierProvider<InventoryMovementNotifier, InventoryMovementState>(
        (ref) {
  final firestore = FirebaseFirestore.instance;
  final dataSource = InventoryMovementDataSource(firestore);
  final repository = InventoryMovementRepositoryImpl(dataSource);

  return InventoryMovementNotifier(repository);
});
