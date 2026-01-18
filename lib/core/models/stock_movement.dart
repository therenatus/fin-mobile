import 'package:json_annotation/json_annotation.dart';
import 'json_converters.dart';

part 'stock_movement.g.dart';

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

@JsonSerializable()
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

  factory StockMovementMaterial.fromJson(Map<String, dynamic> json) =>
      _$StockMovementMaterialFromJson(json);
  Map<String, dynamic> toJson() => _$StockMovementMaterialToJson(this);
}

@JsonSerializable()
class StockMovementOrder {
  final String id;
  final String? orderNumber;

  StockMovementOrder({
    required this.id,
    this.orderNumber,
  });

  factory StockMovementOrder.fromJson(Map<String, dynamic> json) =>
      _$StockMovementOrderFromJson(json);
  Map<String, dynamic> toJson() => _$StockMovementOrderToJson(this);
}

@JsonSerializable()
class StockMovementPurchase {
  final String id;
  final String number;

  StockMovementPurchase({
    required this.id,
    required this.number,
  });

  factory StockMovementPurchase.fromJson(Map<String, dynamic> json) =>
      _$StockMovementPurchaseFromJson(json);
  Map<String, dynamic> toJson() => _$StockMovementPurchaseToJson(this);
}

@JsonSerializable()
class StockMovement {
  final String id;
  final String materialId;
  @JsonKey(fromJson: _movementTypeFromJson, toJson: _movementTypeToJson)
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
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isIncoming => quantity > 0;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedQuantity {
    final sign = quantity >= 0 ? '+' : '';
    return '$sign${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 2)}';
  }

  factory StockMovement.fromJson(Map<String, dynamic> json) =>
      _$StockMovementFromJson(json);
  Map<String, dynamic> toJson() => _$StockMovementToJson(this);
}

// Helper functions for MovementType
MovementType _movementTypeFromJson(String value) =>
    MovementType.fromString(value);

String _movementTypeToJson(MovementType type) => type.toJson();

@JsonSerializable()
class StockMovementsResponse {
  final List<StockMovement> movements;
  @JsonKey(readValue: _readPage, defaultValue: 1)
  final int page;
  @JsonKey(readValue: _readPerPage, defaultValue: 20)
  final int perPage;
  @JsonKey(readValue: _readTotal, defaultValue: 0)
  final int total;
  @JsonKey(readValue: _readTotalPages, defaultValue: 1)
  final int totalPages;

  StockMovementsResponse({
    required this.movements,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory StockMovementsResponse.fromJson(Map<String, dynamic> json) =>
      _$StockMovementsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StockMovementsResponseToJson(this);
}

// Helper functions for reading meta fields
Object? _readPage(Map<dynamic, dynamic> json, String key) =>
    (json['meta'] as Map<String, dynamic>?)?['page'];
Object? _readPerPage(Map<dynamic, dynamic> json, String key) =>
    (json['meta'] as Map<String, dynamic>?)?['per_page'];
Object? _readTotal(Map<dynamic, dynamic> json, String key) =>
    (json['meta'] as Map<String, dynamic>?)?['total'];
Object? _readTotalPages(Map<dynamic, dynamic> json, String key) =>
    (json['meta'] as Map<String, dynamic>?)?['total_pages'];
