import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class ItemRemoteDataSource {
  final FirebaseFirestore firestore;

  ItemRemoteDataSource(this.firestore);

  Future<void> createItem(ItemModel item) async {
    await firestore.collection('items').doc(item.uid).set(
          item.toJson(),
        );
  }

  Future<ItemModel?> getItem(String uid) async {
    final doc = await firestore.collection('items').doc(uid).get();
    if (doc.exists) {
      return ItemModel.fromJson(doc.data()!);
    } else {
      return null;
    }
  }
}
