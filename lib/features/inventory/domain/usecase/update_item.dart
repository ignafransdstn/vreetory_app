import '../entities/item_entity.dart';
import '../repositories/item_repository.dart';

class UpdateItem {
  final ItemRepository repository;
  UpdateItem(this.repository);

  Future<void> call(ItemEntity item) async {
    return await repository.updateItem(item);
  }
}