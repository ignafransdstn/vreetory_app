import 'package:vreetory_app/features/inventory/domain/entities/item_entity.dart';

abstract class ItemRepository {
  Future<void> createItem(ItemEntity item);
  Future<ItemEntity?> getItem(String uid);
  Future<List<ItemEntity>> getAllItems();
  Future<void> updateItem(ItemEntity item);
  Future<void> deleteItem(String uid);
}