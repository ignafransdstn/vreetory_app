import '../../domain/entities/item_entity.dart';
import '../datasources/inventory_movement_datasource.dart';

abstract class InventoryMovementRepository {
  Future<List<ItemEntity>> getInventoryMovements();
  Future<List<ItemEntity>> getMovementsByCategory(String category);
  Future<List<Map<String, dynamic>>> getMovementsByType(String type);
  Future<List<ItemEntity>> getMovementsBySupplier(String supplier);
}

class InventoryMovementRepositoryImpl implements InventoryMovementRepository {
  final InventoryMovementDataSource dataSource;

  InventoryMovementRepositoryImpl(this.dataSource);

  @override
  Future<List<ItemEntity>> getInventoryMovements() async {
    final items = await dataSource.getInventoryMovements();
    return List<ItemEntity>.from(items);
  }

  @override
  Future<List<ItemEntity>> getMovementsByCategory(String category) async {
    final items = await dataSource.getMovementsByCategory(category);
    return List<ItemEntity>.from(items);
  }

  @override
  Future<List<Map<String, dynamic>>> getMovementsByType(String type) async {
    final movements = await dataSource.getMovementsByType(type);
    return movements;
  }

  @override
  Future<List<ItemEntity>> getMovementsBySupplier(String supplier) async {
    final items = await dataSource.getMovementsBySupplier(supplier);
    return List<ItemEntity>.from(items);
  }
}
