import 'package:vreetory_app/features/inventory/domain/entities/item_entity.dart';
import 'package:vreetory_app/features/inventory/domain/repositories/item_repository.dart';

class GetItem {
  final ItemRepository repository;

  GetItem(this.repository);

  Future<ItemEntity?> call(String uid) {
    return repository.getItem(uid);
  }
}