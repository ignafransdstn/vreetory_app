class LossRecordEntity {
  final String uid;
  final String itemUid;
  final String itemName;
  final String itemCode;
  final String category;
  final String reasonType; // 'Expired', 'Demaged/Defective', 'Lost'
  final String quantityLost;
  final String buyRate;
  final String totalLoss; // quantityLost × buyRate
  final String createdBy;
  final DateTime createdAt;
  final String? notes;

  LossRecordEntity({
    required this.uid,
    required this.itemUid,
    required this.itemName,
    required this.itemCode,
    required this.category,
    required this.reasonType,
    required this.quantityLost,
    required this.buyRate,
    required this.totalLoss,
    required this.createdBy,
    required this.createdAt,
    this.notes,
  });
}
