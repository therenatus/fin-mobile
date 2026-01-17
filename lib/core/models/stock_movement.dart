enum MovementType {
  purchase,
  consumption,
  adjustment,
  returnType,
  transfer;

  String get label {
    switch (this) {
      case MovementType.purchase:
        return 'Закупка';
      case MovementType.consumption:
        return 'Расход';
      case MovementType.adjustment:
        return 'Корректировка';
      case MovementType.returnType:
        return 'Возврат';
      case MovementType.transfer:
        return 'Перемещение';
    }
  }

  static MovementType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PURCHASE':
        return MovementType.purchase;
      case 'CONSUMPTION':
        return MovementType.consumption;
      case 'ADJUSTMENT':
        return MovementType.adjustment;
      case 'RETURN':
        return MovementType.returnType;
      case 'TRANSFER':
        return MovementType.transfer;
      default:
        return MovementType.adjustment;
    }
  }

  String toJson() {
    switch (this) {
      case MovementType.returnType:
        return 'RETURN';
      default:
        return name.toUpperCase();
    }
  }
}

class StockMovementMaterial {
  final String id;
  final String name;
  final String sku;
  final String unit;

  StockMovementMaterial({
    required this.id,
    required this.name,
    required this.sku,
    required this.unit,
  });

  factory StockMovementMaterial.fromJson(Map<String, dynamic> json) {
    return StockMovementMaterial(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      unit: json['unit'] as String,
    );
  }
}

class StockMovementOrder {
  final String id;
  final String? orderNumber;

  StockMovementOrder({
    required this.id,
    this.orderNumber,
  });

  factory StockMovementOrder.fromJson(Map<String, dynamic> json) {
    return StockMovementOrder(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String?,
    );
  }
}

class StockMovementPurchase {
  final String id;
  final String number;

  StockMovementPurchase({
    required this.id,
    required this.number,
  });

  factory StockMovementPurchase.fromJson(Map<String, dynamic> json) {
    return StockMovementPurchase(
      id: json['id'] as String,
      number: json['number'] as String,
    );
  }
}

class StockMovement {
  final String id;
  final String materialId;
  final MovementType type;
  final double quantity;
  final double balanceAfter;
  final double? unitCost;
  final String? orderId;
  final String? purchaseId;
  final String? reason;
  final String? performedBy;
  final StockMovementMaterial? material;
  final StockMovementOrder? order;
  final StockMovementPurchase? purchase;
  final DateTime createdAt;

  StockMovement({
    required this.id,
    required this.materialId,
    required this.type,
    required this.quantity,
    required this.balanceAfter,
    this.unitCost,
    this.orderId,
    this.purchaseId,
    this.reason,
    this.performedBy,
    this.material,
    this.order,
    this.purchase,
    required this.createdAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as String,
      materialId: json['materialId'] as String,
      type: MovementType.fromString(json['type'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      balanceAfter: (json['balanceAfter'] as num).toDouble(),
      unitCost: (json['unitCost'] as num?)?.toDouble(),
      orderId: json['orderId'] as String?,
      purchaseId: json['purchaseId'] as String?,
      reason: json['reason'] as String?,
      performedBy: json['performedBy'] as String?,
      material: json['material'] != null
          ? StockMovementMaterial.fromJson(json['material'] as Map<String, dynamic>)
          : null,
      order: json['order'] != null
          ? StockMovementOrder.fromJson(json['order'] as Map<String, dynamic>)
          : null,
      purchase: json['purchase'] != null
          ? StockMovementPurchase.fromJson(json['purchase'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  bool get isIncoming => quantity > 0;

  String get formattedQuantity {
    final sign = quantity >= 0 ? '+' : '';
    return '$sign${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 2)}';
  }
}

class StockMovementsResponse {
  final List<StockMovement> movements;
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  StockMovementsResponse({
    required this.movements,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory StockMovementsResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>?;
    return StockMovementsResponse(
      movements: (json['movements'] as List<dynamic>)
          .map((e) => StockMovement.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: meta?['page'] as int? ?? 1,
      perPage: meta?['per_page'] as int? ?? 20,
      total: meta?['total'] as int? ?? 0,
      totalPages: meta?['total_pages'] as int? ?? 1,
    );
  }
}
