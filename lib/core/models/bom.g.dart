// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bom.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BomItem _$BomItemFromJson(Map<String, dynamic> json) => BomItem(
  id: json['id'] as String,
  bomId: json['bomId'] as String,
  materialId: json['materialId'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  wastePct: (json['wastePct'] as num?)?.toDouble() ?? 5.0,
  effectiveQty: (json['effectiveQty'] as num?)?.toDouble(),
  unitCost: (json['unitCost'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
  material: json['material'] == null
      ? null
      : BomMaterial.fromJson(json['material'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BomItemToJson(BomItem instance) => <String, dynamic>{
  'id': instance.id,
  'bomId': instance.bomId,
  'materialId': instance.materialId,
  'quantity': instance.quantity,
  'wastePct': instance.wastePct,
  if (instance.effectiveQty case final value?) 'effectiveQty': value,
  if (instance.unitCost case final value?) 'unitCost': value,
  if (instance.notes case final value?) 'notes': value,
  if (instance.material?.toJson() case final value?) 'material': value,
};

BomMaterial _$BomMaterialFromJson(Map<String, dynamic> json) => BomMaterial(
  id: json['id'] as String,
  name: json['name'] as String,
  sku: json['sku'] as String,
  unit: json['unit'] as String? ?? 'METER',
  costPrice: (json['costPrice'] as num?)?.toDouble(),
);

Map<String, dynamic> _$BomMaterialToJson(BomMaterial instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sku': instance.sku,
      'unit': instance.unit,
      if (instance.costPrice case final value?) 'costPrice': value,
    };

BomOperation _$BomOperationFromJson(Map<String, dynamic> json) => BomOperation(
  id: json['id'] as String,
  bomId: json['bomId'] as String,
  name: json['name'] as String,
  sequence: (json['sequence'] as num).toInt(),
  setupTime: (json['setupTime'] as num?)?.toInt() ?? 0,
  unitTime: (json['unitTime'] as num).toInt(),
  hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
  requiredRole: json['requiredRole'] as String?,
  laborCost: (json['laborCost'] as num?)?.toDouble(),
);

Map<String, dynamic> _$BomOperationToJson(BomOperation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bomId': instance.bomId,
      'name': instance.name,
      'sequence': instance.sequence,
      'setupTime': instance.setupTime,
      'unitTime': instance.unitTime,
      if (instance.hourlyRate case final value?) 'hourlyRate': value,
      if (instance.requiredRole case final value?) 'requiredRole': value,
      if (instance.laborCost case final value?) 'laborCost': value,
    };

BomModel _$BomModelFromJson(Map<String, dynamic> json) =>
    BomModel(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$BomModelToJson(BomModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

Bom _$BomFromJson(Map<String, dynamic> json) => Bom(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  modelId: json['modelId'] as String,
  version: (json['version'] as num).toInt(),
  isActive: json['isActive'] as bool? ?? false,
  notes: json['notes'] as String?,
  createdBy: json['createdBy'] as String?,
  totalMaterialCost: (json['totalMaterialCost'] as num?)?.toDouble() ?? 0.0,
  totalLaborCost: (json['totalLaborCost'] as num?)?.toDouble() ?? 0.0,
  totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => BomItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  operations:
      (json['operations'] as List<dynamic>?)
          ?.map((e) => BomOperation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  model: json['model'] == null
      ? null
      : BomModel.fromJson(json['model'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BomToJson(Bom instance) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'modelId': instance.modelId,
  'version': instance.version,
  'isActive': instance.isActive,
  if (instance.notes case final value?) 'notes': value,
  if (instance.createdBy case final value?) 'createdBy': value,
  'totalMaterialCost': instance.totalMaterialCost,
  'totalLaborCost': instance.totalLaborCost,
  'totalCost': instance.totalCost,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'operations': instance.operations.map((e) => e.toJson()).toList(),
  if (instance.model?.toJson() case final value?) 'model': value,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

BomVersion _$BomVersionFromJson(Map<String, dynamic> json) => BomVersion(
  id: json['id'] as String,
  version: (json['version'] as num).toInt(),
  isActive: json['isActive'] as bool? ?? false,
  totalMaterialCost: (json['totalMaterialCost'] as num?)?.toDouble() ?? 0.0,
  totalLaborCost: (json['totalLaborCost'] as num?)?.toDouble() ?? 0.0,
  totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BomVersionToJson(BomVersion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'version': instance.version,
      'isActive': instance.isActive,
      'totalMaterialCost': instance.totalMaterialCost,
      'totalLaborCost': instance.totalLaborCost,
      'totalCost': instance.totalCost,
      if (instance.notes case final value?) 'notes': value,
      'createdAt': instance.createdAt.toIso8601String(),
    };

BomVersionsResponse _$BomVersionsResponseFromJson(Map<String, dynamic> json) =>
    BomVersionsResponse(
      versions: (json['versions'] as List<dynamic>)
          .map((e) => BomVersion.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BomVersionsResponseToJson(
  BomVersionsResponse instance,
) => <String, dynamic>{
  'versions': instance.versions.map((e) => e.toJson()).toList(),
  'total': instance.total,
};
