class ItemEntity {
  final String uid;
  final String itemName;
  final String itemCode;
  final String category;
  final String quantity;
  final String buyRate;
  final String sellRate;
  final String expiredDate;
  final String measure;
  final String supplier;
  final String description;
  final String imageUrl;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemEntity ({
    required this.uid,
    required this.itemName,
    required this.itemCode,
    required this.category,
    required this.quantity,
    required this.buyRate,
    required this.sellRate,
    required this.expiredDate,
    required this.measure,
    required this.supplier,
    required this.description,
    required this.imageUrl,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt
  });
}