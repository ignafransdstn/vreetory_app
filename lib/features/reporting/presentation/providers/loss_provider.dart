import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/loss_record_remote_datasource.dart';
import '../../data/models/loss_record_model.dart';
import '../../domain/entities/loss_record_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final lossRecordRemoteDataSourceProvider =
    Provider<LossRecordRemoteDataSource>((ref) {
  return LossRecordRemoteDataSource(FirebaseFirestore.instance);
});

final lossRecordsProvider = FutureProvider<List<LossRecordEntity>>((ref) async {
  final dataSource = ref.watch(lossRecordRemoteDataSourceProvider);
  final records = await dataSource.getAllLossRecords();
  return records.cast<LossRecordEntity>();
});

final lossRecordsByDateRangeProvider = FutureProvider.family<
    List<LossRecordEntity>,
    (DateTime startDate, DateTime endDate)>((ref, params) async {
  final dataSource = ref.watch(lossRecordRemoteDataSourceProvider);
  final records =
      await dataSource.getLossRecordsByDateRange(params.$1, params.$2);
  return records.cast<LossRecordEntity>();
});

final lossRecordsByReasonProvider =
    FutureProvider.family<List<LossRecordEntity>, String>((ref, reason) async {
  final dataSource = ref.watch(lossRecordRemoteDataSourceProvider);
  final records = await dataSource.getLossRecordsByReason(reason);
  return records.cast<LossRecordEntity>();
});

// Computed providers for summary statistics
final totalLossValueProvider =
    FutureProvider.family<double, (DateTime?, DateTime?)>((ref, params) async {
  final records = params.$1 != null && params.$2 != null
      ? await ref.watch(
          lossRecordsByDateRangeProvider((params.$1!, params.$2!)).future)
      : await ref.watch(lossRecordsProvider.future);
  double total = 0;
  for (final record in records) {
    total += double.tryParse(record.totalLoss) ?? 0;
  }
  return total;
});

final totalLossByReasonProvider = FutureProvider.family<
    Map<String, Map<String, dynamic>>,
    (DateTime?, DateTime?)>((ref, params) async {
  final records = params.$1 != null && params.$2 != null
      ? await ref.watch(
          lossRecordsByDateRangeProvider((params.$1!, params.$2!)).future)
      : await ref.watch(lossRecordsProvider.future);
  final resultMap = <String, Map<String, dynamic>>{
    'Expired': {'quantity': 0.0, 'totalLoss': 0.0},
    'Demaged/Defective': {'quantity': 0.0, 'totalLoss': 0.0},
    'Lost': {'quantity': 0.0, 'totalLoss': 0.0},
  };

  for (final record in records) {
    final reason = record.reasonType;
    if (resultMap.containsKey(reason)) {
      resultMap[reason]!['quantity'] =
          (resultMap[reason]!['quantity'] as double) +
              (double.tryParse(record.quantityLost) ?? 0.0);
      resultMap[reason]!['totalLoss'] =
          (resultMap[reason]!['totalLoss'] as double) +
              (double.tryParse(record.totalLoss) ?? 0.0);
    }
  }

  return resultMap;
});

final createLossRecordProvider =
    FutureProvider.family<void, LossRecordModel>((ref, record) async {
  final dataSource = ref.watch(lossRecordRemoteDataSourceProvider);
  await dataSource.createLossRecord(record as LossRecordEntity);
  // Refresh the records after creating - invalidate all dependent providers
  ref.invalidate(lossRecordsProvider);
  ref.invalidate(lossRecordsByDateRangeProvider);
  ref.invalidate(lossRecordsByReasonProvider);
});
