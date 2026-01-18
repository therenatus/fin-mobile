// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaterialCategory _$MaterialCategoryFromJson(Map<String, dynamic> json) =>
    MaterialCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      parentId: json['parentId'] as String?,
      parent: json['parent'] == null
          ? null
          : MaterialCategory.fromJson(json['parent'] as Map<String, dynamic>),
      children:
          (json['children'] as List<dynamic>?)
              ?.map((e) => MaterialCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      materialsCount:
          (_readMaterialsCount(json, 'materialsCount') as num?)?.toInt() ?? 0,
      childrenCount:
          (_readChildrenCount(json, 'childrenCount') as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MaterialCategoryToJson(MaterialCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      if (instance.description case final value?) 'description': value,
      if (instance.parentId case final value?) 'parentId': value,
      if (instance.parent?.toJson() case final value?) 'parent': value,
      'children': instance.children.map((e) => e.toJson()).toList(),
      'materialsCount': instance.materialsCount,
      'childrenCount': instance.childrenCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

MaterialCategoriesResponse _$MaterialCategoriesResponseFromJson(
  Map<String, dynamic> json,
) => MaterialCategoriesResponse(
  categories: (json['categories'] as List<dynamic>)
      .map((e) => MaterialCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
  flat:
      (json['flat'] as List<dynamic>?)
          ?.map((e) => MaterialCategory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$MaterialCategoriesResponseToJson(
  MaterialCategoriesResponse instance,
) => <String, dynamic>{
  'categories': instance.categories.map((e) => e.toJson()).toList(),
  'flat': instance.flat.map((e) => e.toJson()).toList(),
};

Material _$MaterialFromJson(Map<String, dynamic> json) => Material(
  id: json['id'] as String,
  sku: json['sku'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  barcode: json['barcode'] as String?,
  unit: _materialUnitFromJson(json['unit'] as String?),
  quantity: (json['quantity'] as num).toDouble(),
  reservedQty: (json['reservedQty'] as num?)?.toDouble() ?? 0.0,
  minStockLevel: (json['minStockLevel'] as num?)?.toDouble(),
  costPrice: (json['costPrice'] as num?)?.toDouble(),
  sellPrice: (json['sellPrice'] as num?)?.toDouble(),
  color: json['color'] as String?,
  width: (json['width'] as num?)?.toDouble(),
  composition: json['composition'] as String?,
  imageUrl: json['imageUrl'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  category: json['category'] == null
      ? null
      : MaterialCategory.fromJson(json['category'] as Map<String, dynamic>),
  supplier: json['supplier'] == null
      ? null
      : MaterialSupplier.fromJson(json['supplier'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  availableQty: (json['availableQty'] as num?)?.toDouble(),
  isLowStock: json['isLowStock'] as bool?,
);

Map<String, dynamic> _$MaterialToJson(Material instance) => <String, dynamic>{
  'id': instance.id,
  'sku': instance.sku,
  'name': instance.name,
  if (instance.description case final value?) 'description': value,
  if (instance.barcode case final value?) 'barcode': value,
  'unit': _materialUnitToJson(instance.unit),
  'quantity': instance.quantity,
  'reservedQty': instance.reservedQty,
  if (instance.minStockLevel case final value?) 'minStockLevel': value,
  if (instance.costPrice case final value?) 'costPrice': value,
  if (instance.sellPrice case final value?) 'sellPrice': value,
  if (instance.color case final value?) 'color': value,
  if (instance.width case final value?) 'width': value,
  if (instance.composition case final value?) 'composition': value,
  if (instance.imageUrl case final value?) 'imageUrl': value,
  'isActive': instance.isActive,
  if (instance.category?.toJson() case final value?) 'category': value,
  if (instance.supplier?.toJson() case final value?) 'supplier': value,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  if (instance.availableQty case final value?) 'availableQty': value,
  if (instance.isLowStock case final value?) 'isLowStock': value,
};

MaterialSupplier _$MaterialSupplierFromJson(Map<String, dynamic> json) =>
    MaterialSupplier(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$MaterialSupplierToJson(MaterialSupplier instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

MaterialsResponse _$MaterialsResponseFromJson(Map<String, dynamic> json) =>
    MaterialsResponse(
      materials: (json['materials'] as List<dynamic>)
          .map((e) => Material.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (_readPage(json, 'page') as num?)?.toInt() ?? 1,
      perPage: (_readPerPage(json, 'perPage') as num?)?.toInt() ?? 20,
      total: (_readTotal(json, 'total') as num?)?.toInt() ?? 0,
      totalPages: (_readTotalPages(json, 'totalPages') as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$MaterialsResponseToJson(MaterialsResponse instance) =>
    <String, dynamic>{
      'materials': instance.materials.map((e) => e.toJson()).toList(),
      'page': instance.page,
      'perPage': instance.perPage,
      'total': instance.total,
      'totalPages': instance.totalPages,
    };

LowStockResponse _$LowStockResponseFromJson(Map<String, dynamic> json) =>
    LowStockResponse(
      materials: (json['materials'] as List<dynamic>)
          .map((e) => Material.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$LowStockResponseToJson(LowStockResponse instance) =>
    <String, dynamic>{
      'materials': instance.materials.map((e) => e.toJson()).toList(),
      'total': instance.total,
    };
