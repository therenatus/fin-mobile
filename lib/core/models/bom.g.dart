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
  model: json['model'] == null
      ? null
      : BomModel.fromJson(json['model'] as Map<String, dynamic>),
  createdAt: dateTimeFromJson(json['createdAt']),
  updatedAt: dateTimeFromJson(json['updatedAt']),
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
  if (instance.model?.toJson() case final value?) 'model': value,
  'createdAt': dateTimeToJson(instance.createdAt),
  'updatedAt': dateTimeToJson(instance.updatedAt),
};

BomVersion _$BomVersionFromJson(Map<String, dynamic> json) => BomVersion(
  id: json['id'] as String,
  version: (json['version'] as num).toInt(),
  isActive: json['isActive'] as bool? ?? false,
  totalMaterialCost: (json['totalMaterialCost'] as num?)?.toDouble() ?? 0.0,
  totalLaborCost: (json['totalLaborCost'] as num?)?.toDouble() ?? 0.0,
  totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
  notes: json['notes'] as String?,
  createdAt: dateTimeFromJson(json['createdAt']),
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
      'createdAt': dateTimeToJson(instance.createdAt),
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
