import 'package:vreetory_app/features/inventory/data/datasources/item_remote_datasource.dart';
import 'package:vreetory_app/features/inventory/data/models/item_model.dart';
import 'package:vreetory_app/features/inventory/domain/entities/item_entity.dart';
import 'package:vreetory_app/features/inventory/domain/repositories/item_repository.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDataSource remoteDataSource;

  ItemRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createItem(ItemEntity item) async {
    final isItemCodeTaken =
        await remoteDataSource.isItemCodeRegistered(item.itemCode);
    if (isItemCodeTaken) {
      throw Exception('Item is already registered');
    }
    final model = ItemModel(
      uid: item.uid,
      itemName: item.itemName,
      itemCode: item.itemCode,
      category: item.category,
      quantity: item.quantity,
      buyRate: item.buyRate,
      sellRate: item.sellRate,
      expiredDate: item.expiredDate,
      measure: item.measure,
      supplier: item.supplier,
      description: item.description,
      imageUrl: item.imageUrl,
      status: item.status,
      createdBy: item.createdBy,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
    await remoteDataSource.createItem(model);
  }

  @override
  Future<ItemEntity?> getItem(String uid) async {
    final model = await remoteDataSource.getItem(uid);
    return model;
  }
  
  @override
  Future<void> deleteItem(String uid) {
    // TODO: implement deleteItem
    throw UnimplementedError();
  }
  
  @override
  Future<List<ItemEntity>> getAllItems() {
    // TODO: implement getAllItems
    throw UnimplementedError();
  }
  
  @override
  Future<void> updateItem(ItemEntity item) {
    // TODO: implement updateItem
    throw UnimplementedError();
  }
}
