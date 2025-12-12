import '../../domain/entities/low_stock_alert_item.dart';
import '../datasources/low_stock_datasource.dart';

abstract class LowStockRepository {
  Future<List<LowStockAlertItem>> getLowStockItems();
  Future<List<String>> getCategories();
  Future<List<String>> getSuppliers();
}

class LowStockRepositoryImpl implements LowStockRepository {
  final LowStockDatasource datasource;

  LowStockRepositoryImpl({required this.datasource});

  @override
  Future<List<LowStockAlertItem>> getLowStockItems() {
    return datasource.getLowStockItems();
  }

  @override
  Future<List<String>> getCategories() {
    return datasource.getCategories();
  }

  @override
  Future<List<String>> getSuppliers() {
    return datasource.getSuppliers();
  }
}
