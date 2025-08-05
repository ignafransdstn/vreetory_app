import 'package:vreetory_app/features/inventory/domain/entities/item_entity.dart';
import 'package:vreetory_app/features/inventory/domain/repositories/item_repository.dart';

class CreateItem {
  final ItemRepository repository;

  CreateItem(this.repository);

  Future<void> call(ItemEntity item) {
    return repository.createItem(item);
  }
}