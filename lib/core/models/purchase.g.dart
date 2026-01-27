// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseSupplier _$PurchaseSupplierFromJson(Map<String, dynamic> json) =>
    PurchaseSupplier(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$PurchaseSupplierToJson(PurchaseSupplier instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

PurchaseItemMaterial _$PurchaseItemMaterialFromJson(
  Map<String, dynamic> json,
) => PurchaseItemMaterial(
  id: json['id'] as String,
  name: json['name'] as String,
  sku: json['sku'] as String,
  unit: json['unit'] as String,
  quantity: (json['quantity'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PurchaseItemMaterialToJson(
  PurchaseItemMaterial instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sku': instance.sku,
  'unit': instance.unit,
  if (instance.quantity case final value?) 'quantity': value,
};

PurchaseItem _$PurchaseItemFromJson(Map<String, dynamic> json) => PurchaseItem(
  id: json['id'] as String,
  purchaseId: json['purchaseId'] as String,
  materialId: json['materialId'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  receivedQty: (json['receivedQty'] as num?)?.toDouble() ?? 0.0,
  unitPrice: (json['unitPrice'] as num).toDouble(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  material: json['material'] == null
      ? null
      : PurchaseItemMaterial.fromJson(json['material'] as Map<String, dynamic>),
  createdAt: dateTimeFromJson(json['createdAt']),
  updatedAt: dateTimeFromJson(json['updatedAt']),
  remainingQty: (json['remainingQty'] as num?)?.toDouble(),
  isFullyReceived: json['isFullyReceived'] as bool?,
);

Map<String, dynamic> _$PurchaseItemToJson(PurchaseItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'purchaseId': instance.purchaseId,
      'materialId': instance.materialId,
      'quantity': instance.quantity,
      'receivedQty': instance.receivedQty,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      if (instance.material?.toJson() case final value?) 'material': value,
      'createdAt': dateTimeToJson(instance.createdAt),
      'updatedAt': dateTimeToJson(instance.updatedAt),
      if (instance.remainingQty case final value?) 'remainingQty': value,
      if (instance.isFullyReceived case final value?) 'isFullyReceived': value,
    };

Purchase _$PurchaseFromJson(Map<String, dynamic> json) => Purchase(
  id: json['id'] as String,
  number: json['number'] as String,
  status: _purchaseStatusFromJson(json['status'] as String),
  supplierId: json['supplierId'] as String?,
  supplier: json['supplier'] == null
      ? null
      : PurchaseSupplier.fromJson(json['supplier'] as Map<String, dynamic>),
  orderDate: nullableDateTimeFromJson(json['orderDate']),
  expectedDate: nullableDateTimeFromJson(json['expectedDate']),
  receivedDate: nullableDateTimeFromJson(json['receivedDate']),
  totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
  notes: json['notes'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => PurchaseItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  itemsCount: (_readItemsCount(json, 'itemsCount') as num?)?.toInt() ?? 0,
  createdAt: dateTimeFromJson(json['createdAt']),
  updatedAt: dateTimeFromJson(json['updatedAt']),
  isFullyReceived: json['isFullyReceived'] as bool?,
);

Map<String, dynamic> _$PurchaseToJson(Purchase instance) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'status': _purchaseStatusToJson(instance.status),
  if (instance.supplierId case final value?) 'supplierId': value,
  if (instance.supplier?.toJson() case final value?) 'supplier': value,
  if (nullableDateTimeToJson(instance.orderDate) case final value?)
    'orderDate': value,
  if (nullableDateTimeToJson(instance.expectedDate) case final value?)
    'expectedDate': value,
  if (nullableDateTimeToJson(instance.receivedDate) case final value?)
    'receivedDate': value,
  'totalAmount': instance.totalAmount,
  if (instance.notes case final value?) 'notes': value,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'itemsCount': instance.itemsCount,
  'createdAt': dateTimeToJson(instance.createdAt),
  'updatedAt': dateTimeToJson(instance.updatedAt),
  if (instance.isFullyReceived case final value?) 'isFullyReceived': value,
};

PurchasesResponse _$PurchasesResponseFromJson(Map<String, dynamic> json) =>
    PurchasesResponse(
      purchases: (json['purchases'] as List<dynamic>)
          .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (_readPage(json, 'page') as num?)?.toInt() ?? 1,
      perPage: (_readPerPage(json, 'perPage') as num?)?.toInt() ?? 20,
      total: (_readTotal(json, 'total') as num?)?.toInt() ?? 0,
      totalPages: (_readTotalPages(json, 'totalPages') as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$PurchasesResponseToJson(PurchasesResponse instance) =>
    <String, dynamic>{
      'purchases': instance.purchases.map((e) => e.toJson()).toList(),
      'page': instance.page,
      'perPage': instance.perPage,
      'total': instance.total,
      'totalPages': instance.totalPages,
    };
