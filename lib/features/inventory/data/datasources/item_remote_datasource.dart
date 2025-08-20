import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class ItemRemoteDataSource {
  final FirebaseFirestore firestore;

  ItemRemoteDataSource(this.firestore);

  Future<void> createItem(ItemModel item) async {
    if (item.uid.isEmpty) {
      // Add new item, let Firestore generate the ID
      final docRef = await firestore.collection('items').add(item.toJson());
      // Update the document with the generated ID as uid
      await docRef.update({'uid': docRef.id});
    } else {
      // Use provided uid (for update or custom ID)
      await firestore.collection('items').doc(item.uid).set(item.toJson());
    }
  }

  Future<ItemModel?> getItem(String uid) async {
    final doc = await firestore.collection('items').doc(uid).get();
    if (doc.exists) {
      return ItemModel.fromJson(doc.data()!);
    } else {
      return null;
    }
  }
  Future<List<ItemModel>> getAllItems() async {
    final querySnapshot = await firestore.collection('items').get();
    return querySnapshot.docs
        .map((doc) => ItemModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> updateItem(ItemModel item) async {
    await firestore.collection('items').doc(item.uid).update(item.toJson());
  }

  Future<void> deleteItem(String uid) async {
    await firestore.collection('items').doc(uid).delete();
  }

  Future<bool> isItemCodeRegistered(String itemCode) async {
    final querySnapshot = await firestore
        .collection('items')
        .where('itemCode', isEqualTo: itemCode)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }
}
