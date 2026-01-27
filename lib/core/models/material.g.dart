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
      createdAt: dateTimeFromJson(json['createdAt']),
      updatedAt: dateTimeFromJson(json['updatedAt']),
    );

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
  createdAt: dateTimeFromJson(json['createdAt']),
  updatedAt: dateTimeFromJson(json['updatedAt']),
  availableQty: (json['availableQty'] as num?)?.toDouble(),
  isLowStock: json['isLowStock'] as bool?,
);

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
