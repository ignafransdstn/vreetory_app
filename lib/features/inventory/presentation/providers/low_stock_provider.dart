import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/low_stock_datasource.dart';
import '../../data/repositories/low_stock_repository.dart';
import '../../domain/entities/low_stock_alert_item.dart';
import '../provider/item_provider.dart';

// Firebase provider
final firebaseProvider = Provider((ref) => FirebaseFirestore.instance);

// Low stock datasource provider
final lowStockDatasourceProvider = Provider((ref) {
  final firestore = ref.watch(firebaseProvider);
  return LowStockDatasource(firestore: firestore);
});

// Low stock repository provider
final lowStockRepositoryProvider = Provider((ref) {
  final datasource = ref.watch(lowStockDatasourceProvider);
  return LowStockRepositoryImpl(datasource: datasource);
});

// Low stock items provider (fetches all items with low stock data)
// This watches itemProvider to ensure low stock data refreshes when items change
final lowStockItemsProvider = FutureProvider<List<LowStockAlertItem>>((ref) async {
  // Watch itemProvider to trigger refresh when items change
  ref.watch(itemProvider);
  
  final repository = ref.watch(lowStockRepositoryProvider);
  return repository.getLowStockItems();
});

// Categories provider
final lowStockCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(lowStockRepositoryProvider);
  return repository.getCategories();
});

// Suppliers provider
final lowStockSuppliersProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(lowStockRepositoryProvider);
  return repository.getSuppliers();
});

// Filter state providers
final lowStockStatusFilterProvider = StateProvider<List<LowStockStatus>>((ref) {
  return [LowStockStatus.critical, LowStockStatus.warning, LowStockStatus.normal];
});

final lowStockCategoryFilterProvider = StateProvider<List<String>>((ref) {
  return [];
});

final lowStockSupplierFilterProvider = StateProvider<List<String>>((ref) {
  return [];
});

// Filtered items provider
final filteredLowStockItemsProvider = Provider<AsyncValue<List<LowStockAlertItem>>>((ref) {
  final itemsAsync = ref.watch(lowStockItemsProvider);
  final statusFilters = ref.watch(lowStockStatusFilterProvider);
  final categoryFilters = ref.watch(lowStockCategoryFilterProvider);
  final supplierFilters = ref.watch(lowStockSupplierFilterProvider);

  return itemsAsync.whenData((items) {
    return items.where((item) {
      // Filter by status
      if (!statusFilters.contains(item.status)) return false;

      // Filter by category
      if (categoryFilters.isNotEmpty && !categoryFilters.contains(item.category)) {
        return false;
      }

      // Filter by supplier
      if (supplierFilters.isNotEmpty && !supplierFilters.contains(item.supplier)) {
        return false;
      }

      return true;
    }).toList();
  });
});

// Summary statistics provider
final lowStockSummaryProvider =
    Provider<AsyncValue<({int critical, int warning, int normal, int total})>>((ref) {
  final itemsAsync = ref.watch(filteredLowStockItemsProvider);

  return itemsAsync.whenData((items) {
    int critical = 0;
    int warning = 0;
    int normal = 0;

    for (var item in items) {
      switch (item.status) {
        case LowStockStatus.critical:
          critical++;
          break;
        case LowStockStatus.warning:
          warning++;
          break;
        case LowStockStatus.normal:
          normal++;
          break;
      }
    }

    return (
      critical: critical,
      warning: warning,
      normal: normal,
      total: items.length,
    );
  });
});
