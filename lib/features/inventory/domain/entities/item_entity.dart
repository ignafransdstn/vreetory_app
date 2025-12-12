class ItemEntity {
  final String uid;
  final String itemName;
  final String itemCode;
  final String category;
  final String quantity;
  final String previousQuantity;
  final String minimumStock;
  final String buyRate;
  final String sellRate;
  final String expiredDate;
  final String measure;
  final String supplier;
  final String description;
  final String imageUrl;
  final String status;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? quantityChangeReason;

  ItemEntity ({
    required this.uid,
    required this.itemName,
    required this.itemCode,
    required this.category,
    required this.quantity,
    required this.previousQuantity,
    required this.minimumStock,
    required this.buyRate,
    required this.sellRate,
    required this.expiredDate,
    required this.measure,
    required this.supplier,
    required this.description,
    required this.imageUrl,
    required this.status,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.quantityChangeReason,
  });
}