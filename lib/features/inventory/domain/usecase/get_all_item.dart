import '../entities/item_entity.dart';
import '../repositories/item_repository.dart';

class GetAllItem {
  final ItemRepository repository;
  GetAllItem(this.repository);

  Future<List<ItemEntity>> call() async {
    return await repository.getAllItems();
  }
}