import 'package:intl/intl.dart';

class InventoryMovementItem {
  final String uid;
  final String itemName;
  final String itemCode;
  final String category;
  final int quantityBefore;
  final int quantityAfter;
  final int movementQty;
  final MovementType movementType;
  final String reference;
  final DateTime movementDate;
  final String notes;
  final String supplier;
  final String measure;

  InventoryMovementItem({
    required this.uid,
    required this.itemName,
    required this.itemCode,
    required this.category,
    required this.quantityBefore,
    required this.quantityAfter,
    required this.movementQty,
    required this.movementType,
    required this.reference,
    required this.movementDate,
    required this.notes,
    required this.supplier,
    required this.measure,
  });

  // Get formatted date
  String get formattedDate {
    return DateFormat('dd MMM yyyy').format(movementDate);
  }

  // Get formatted time
  String get formattedTime {
    return DateFormat('HH:mm').format(movementDate);
  }

  // Get movement direction
  String get movementDirection {
    switch (movementType) {
      case MovementType.inbound:
        return 'IN';
      case MovementType.outbound:
        return 'OUT';
      case MovementType.adjustment:
        return 'ADJ';
      case MovementType.return_:
        return 'RTN';
    }
  }
}

enum MovementType {
  inbound,      // Penerimaan barang
  outbound,     // Pengeluaran barang
  adjustment,   // Penyesuaian stok
  return_,      // Pengembalian barang
}

class InventoryMovementSummary {
  final List<InventoryMovementItem> allMovements;
  final int totalMovements;
  final int inboundMovements;
  final int outboundMovements;
  final int adjustmentMovements;
  final int returnMovements;
  final int totalInboundQty;
  final int totalOutboundQty;
  final int totalAdjustmentQty;
  final int totalReturnQty;
  final Map<String, int> movementsByCategory;
  final Map<String, int> movementsByType;
  final List<InventoryMovementItem> topMovements;

  InventoryMovementSummary({
    required this.allMovements,
    required this.totalMovements,
    required this.inboundMovements,
    required this.outboundMovements,
    required this.adjustmentMovements,
    required this.returnMovements,
    required this.totalInboundQty,
    required this.totalOutboundQty,
    required this.totalAdjustmentQty,
    required this.totalReturnQty,
    required this.movementsByCategory,
    required this.movementsByType,
    required this.topMovements,
  });

  // Get net movement (in - out)
  int get netMovement => totalInboundQty - totalOutboundQty;

  // Get total transaction value (hypothetical)
  int get totalTransactions =>
      inboundMovements +
      outboundMovements +
      adjustmentMovements +
      returnMovements;

  // Get inbound percentage
  double get inboundPercentage {
    if (totalMovements == 0) return 0;
    return (inboundMovements / totalMovements) * 100;
  }

  // Get outbound percentage
  double get outboundPercentage {
    if (totalMovements == 0) return 0;
    return (outboundMovements / totalMovements) * 100;
  }

  // Get adjustment percentage
  double get adjustmentPercentage {
    if (totalMovements == 0) return 0;
    return (adjustmentMovements / totalMovements) * 100;
  }

  // Get return percentage
  double get returnPercentage {
    if (totalMovements == 0) return 0;
    return (returnMovements / totalMovements) * 100;
  }
}
