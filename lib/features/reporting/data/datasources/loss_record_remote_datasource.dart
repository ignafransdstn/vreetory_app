import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/loss_record_entity.dart';
import '../models/loss_record_model.dart';

class LossRecordRemoteDataSource {
  final FirebaseFirestore firestore;

  LossRecordRemoteDataSource(this.firestore);

  Future<void> createLossRecord(LossRecordEntity record) async {
    if (record.uid.isEmpty) {
      // Add new record, let Firestore generate the ID
      final jsonData = {
        'item_uid': record.itemUid,
        'item_name': record.itemName,
        'item_code': record.itemCode,
        'category': record.category,
        'reason_type': record.reasonType,
        'quantity_lost': record.quantityLost,
        'buy_rate': record.buyRate,
        'total_loss': record.totalLoss,
        'created_by': record.createdBy,
        'created_at': record.createdAt,
        'notes': record.notes,
      };
      final docRef = await firestore.collection('loss_records').add(jsonData);
      // Update the document with the generated ID as uid
      await docRef.update({'uid': docRef.id});
    } else {
      // Use provided uid - convert to model for JSON serialization
      final model = record is LossRecordModel ? record : LossRecordModel(
        uid: record.uid,
        itemUid: record.itemUid,
        itemName: record.itemName,
        itemCode: record.itemCode,
        category: record.category,
        reasonType: record.reasonType,
        quantityLost: record.quantityLost,
        buyRate: record.buyRate,
        totalLoss: record.totalLoss,
        createdBy: record.createdBy,
        createdAt: record.createdAt,
        notes: record.notes,
      );
      await firestore.collection('loss_records').doc(record.uid).set(model.toJson());
    }
  }

  Future<List<LossRecordModel>> getAllLossRecords() async {
    final querySnapshot = await firestore
        .collection('loss_records')
        .orderBy('created_at', descending: true)
        .get();
    return querySnapshot.docs
        .map((doc) => LossRecordModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<LossRecordModel>> getLossRecordsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Adjust endDate to include the entire day (23:59:59)
    final adjustedEndDate = endDate.add(const Duration(days: 1));
    
    final querySnapshot = await firestore
        .collection('loss_records')
        .where('created_at', isGreaterThanOrEqualTo: startDate)
        .where('created_at', isLessThan: adjustedEndDate)
        .orderBy('created_at', descending: true)
        .get();
    return querySnapshot.docs
        .map((doc) => LossRecordModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<LossRecordModel>> getLossRecordsByReason(String reasonType) async {
    final querySnapshot = await firestore
        .collection('loss_records')
        .where('reason_type', isEqualTo: reasonType)
        .orderBy('created_at', descending: true)
        .get();
    return querySnapshot.docs
        .map((doc) => LossRecordModel.fromJson(doc.data()))
        .toList();
  }
}
