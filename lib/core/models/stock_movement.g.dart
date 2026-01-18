// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockMovementMaterial _$StockMovementMaterialFromJson(
  Map<String, dynamic> json,
) => StockMovementMaterial(
  id: json['id'] as String,
  name: json['name'] as String,
  sku: json['sku'] as String,
  unit: json['unit'] as String,
);

Map<String, dynamic> _$StockMovementMaterialToJson(
  StockMovementMaterial instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sku': instance.sku,
  'unit': instance.unit,
};

StockMovementOrder _$StockMovementOrderFromJson(Map<String, dynamic> json) =>
    StockMovementOrder(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String?,
    );

Map<String, dynamic> _$StockMovementOrderToJson(StockMovementOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.orderNumber case final value?) 'orderNumber': value,
    };

StockMovementPurchase _$StockMovementPurchaseFromJson(
  Map<String, dynamic> json,
) => StockMovementPurchase(
  id: json['id'] as String,
  number: json['number'] as String,
);

Map<String, dynamic> _$StockMovementPurchaseToJson(
  StockMovementPurchase instance,
) => <String, dynamic>{'id': instance.id, 'number': instance.number};

StockMovement _$StockMovementFromJson(Map<String, dynamic> json) =>
    StockMovement(
      id: json['id'] as String,
      materialId: json['materialId'] as String,
      type: _movementTypeFromJson(json['type'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      balanceAfter: (json['balanceAfter'] as num).toDouble(),
      unitCost: (json['unitCost'] as num?)?.toDouble(),
      orderId: json['orderId'] as String?,
      purchaseId: json['purchaseId'] as String?,
      reason: json['reason'] as String?,
      performedBy: json['performedBy'] as String?,
      material: json['material'] == null
          ? null
          : StockMovementMaterial.fromJson(
              json['material'] as Map<String, dynamic>,
            ),
      order: json['order'] == null
          ? null
          : StockMovementOrder.fromJson(json['order'] as Map<String, dynamic>),
      purchase: json['purchase'] == null
          ? null
          : StockMovementPurchase.fromJson(
              json['purchase'] as Map<String, dynamic>,
            ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$StockMovementToJson(StockMovement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'materialId': instance.materialId,
      'type': _movementTypeToJson(instance.type),
      'quantity': instance.quantity,
      'balanceAfter': instance.balanceAfter,
      if (instance.unitCost case final value?) 'unitCost': value,
      if (instance.orderId case final value?) 'orderId': value,
      if (instance.purchaseId case final value?) 'purchaseId': value,
      if (instance.reason case final value?) 'reason': value,
      if (instance.performedBy case final value?) 'performedBy': value,
      if (instance.material?.toJson() case final value?) 'material': value,
      if (instance.order?.toJson() case final value?) 'order': value,
      if (instance.purchase?.toJson() case final value?) 'purchase': value,
      'createdAt': instance.createdAt.toIso8601String(),
    };

StockMovementsResponse _$StockMovementsResponseFromJson(
  Map<String, dynamic> json,
) => StockMovementsResponse(
  movements: (json['movements'] as List<dynamic>)
      .map((e) => StockMovement.fromJson(e as Map<String, dynamic>))
      .toList(),
  page: (_readPage(json, 'page') as num?)?.toInt() ?? 1,
  perPage: (_readPerPage(json, 'perPage') as num?)?.toInt() ?? 20,
  total: (_readTotal(json, 'total') as num?)?.toInt() ?? 0,
  totalPages: (_readTotalPages(json, 'totalPages') as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$StockMovementsResponseToJson(
  StockMovementsResponse instance,
) => <String, dynamic>{
  'movements': instance.movements.map((e) => e.toJson()).toList(),
  'page': instance.page,
  'perPage': instance.perPage,
  'total': instance.total,
  'totalPages': instance.totalPages,
};
