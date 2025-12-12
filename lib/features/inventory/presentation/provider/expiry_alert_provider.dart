import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/expiry_alert_datasource.dart';
import '../../data/repositories/expiry_alert_repository_impl.dart';
import '../../domain/entities/item_entity.dart';

class ExpiryAlertState {
  final List<ItemEntity> items;
  final bool isLoading;
  final String? errorMessage;

  ExpiryAlertState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ExpiryAlertState copyWith({
    List<ItemEntity>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ExpiryAlertState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ExpiryAlertNotifier extends StateNotifier<ExpiryAlertState> {
  final ExpiryAlertRepositoryImpl repository;

  ExpiryAlertNotifier(this.repository) : super(ExpiryAlertState());

  Future<void> fetchExpiryAlertItems() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await repository.getExpiryAlertItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchItemsExpiringToday() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await repository.getItemsExpiringToday();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchItemsExpiringWithinDays(int days) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await repository.getItemsExpiringWithinDays(days);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchExpiredItems() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await repository.getExpiredItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchItemsByCategory(String category) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await repository.getItemsByCategory(category);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchItemsBySupplier(String supplier) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await repository.getItemsBySupplier(supplier);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// Provider
final expiryAlertProvider =
    StateNotifierProvider<ExpiryAlertNotifier, ExpiryAlertState>((ref) {
  final firestore = FirebaseFirestore.instance;
  final dataSource = ExpiryAlertDataSource(firestore);
  final repository = ExpiryAlertRepositoryImpl(dataSource);

  return ExpiryAlertNotifier(repository);
});
