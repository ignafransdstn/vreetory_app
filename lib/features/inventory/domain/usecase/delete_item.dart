import 'package:vreetory_app/features/inventory/domain/repositories/item_repository.dart';

class DeleteItem {
  final ItemRepository repository;
  
  DeleteItem(this.repository);

  Future<void> call(String uid) {
    return repository.deleteItem(uid);
  }
}
