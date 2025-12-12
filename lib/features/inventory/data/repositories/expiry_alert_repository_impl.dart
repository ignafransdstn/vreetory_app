import '../../domain/entities/item_entity.dart';
import '../datasources/expiry_alert_datasource.dart';

abstract class ExpiryAlertRepository {
  Future<List<ItemEntity>> getExpiryAlertItems();
  Future<List<ItemEntity>> getItemsExpiringToday();
  Future<List<ItemEntity>> getItemsExpiringWithinDays(int days);
  Future<List<ItemEntity>> getExpiredItems();
  Future<List<ItemEntity>> getItemsByCategory(String category);
  Future<List<ItemEntity>> getItemsBySupplier(String supplier);
}

class ExpiryAlertRepositoryImpl implements ExpiryAlertRepository {
  final ExpiryAlertDataSource dataSource;

  ExpiryAlertRepositoryImpl(this.dataSource);

  @override
  Future<List<ItemEntity>> getExpiryAlertItems() async {
    final items = await dataSource.getExpiryAlertItems();
    return List<ItemEntity>.from(items);
  }

  @override
  Future<List<ItemEntity>> getItemsExpiringToday() async {
    final items = await dataSource.getItemsExpiringToday();
    return List<ItemEntity>.from(items);
  }

  @override
  Future<List<ItemEntity>> getItemsExpiringWithinDays(int days) async {
    final items = await dataSource.getItemsExpiringWithinDays(days);
    return List<ItemEntity>.from(items);
  }

  @override
  Future<List<ItemEntity>> getExpiredItems() async {
    final items = await dataSource.getExpiredItems();
    return List<ItemEntity>.from(items);
  }

  @override
  Future<List<ItemEntity>> getItemsByCategory(String category) async {
    final items = await dataSource.getItemsByCategory(category);
    return List<ItemEntity>.from(items);
  }

  @override
  Future<List<ItemEntity>> getItemsBySupplier(String supplier) async {
    final items = await dataSource.getItemsBySupplier(supplier);
    return List<ItemEntity>.from(items);
  }
}
