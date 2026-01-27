import 'package:json_annotation/json_annotation.dart';
import 'json_converters.dart';

part 'material.g.dart';

enum MaterialUnit {
  meter,
  kilogram,
  piece,
  roll,
  pack;

  String get label {
    switch (this) {
      case MaterialUnit.meter:
        return 'м';
      case MaterialUnit.kilogram:
        return 'кг';
      case MaterialUnit.piece:
        return 'шт';
      case MaterialUnit.roll:
        return 'рул';
      case MaterialUnit.pack:
        return 'уп';
    }
  }

  String get fullLabel {
    switch (this) {
      case MaterialUnit.meter:
        return 'Метры';
      case MaterialUnit.kilogram:
        return 'Килограммы';
      case MaterialUnit.piece:
        return 'Штуки';
      case MaterialUnit.roll:
        return 'Рулоны';
      case MaterialUnit.pack:
        return 'Упаковки';
    }
  }

  static MaterialUnit fromString(String value) {
    switch (value.toUpperCase()) {
      case 'METER':
        return MaterialUnit.meter;
      case 'KILOGRAM':
        return MaterialUnit.kilogram;
      case 'PIECE':
        return MaterialUnit.piece;
      case 'ROLL':
        return MaterialUnit.roll;
      case 'PACK':
        return MaterialUnit.pack;
      default:
        return MaterialUnit.meter;
    }
  }

  String toJson() => name.toUpperCase();
}

@JsonSerializable(createToJson: false)
class MaterialCategory {
  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final MaterialCategory? parent;
  @JsonKey(defaultValue: [])
  final List<MaterialCategory> children;
  @JsonKey(readValue: _readMaterialsCount, defaultValue: 0)
  final int materialsCount;
  @JsonKey(readValue: _readChildrenCount, defaultValue: 0)
  final int childrenCount;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime updatedAt;

  MaterialCategory({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.parent,
    this.children = const [],
    this.materialsCount = 0,
    this.childrenCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaterialCategory.fromJson(Map<String, dynamic> json) => _$MaterialCategoryFromJson(json);

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'parentId': parentId,
      };
}

// Helper functions for reading _count fields
Object? _readMaterialsCount(Map<dynamic, dynamic> json, String key) {
  return (json['_count'] as Map<String, dynamic>?)?['materials'];
}

Object? _readChildrenCount(Map<dynamic, dynamic> json, String key) {
  return (json['_count'] as Map<String, dynamic>?)?['children'];
}

@JsonSerializable()
class MaterialCategoriesResponse {
  final List<MaterialCategory> categories;
  @JsonKey(defaultValue: [])
  final List<MaterialCategory> flat;

  MaterialCategoriesResponse({
    required this.categories,
    required this.flat,
  });

  factory MaterialCategoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$MaterialCategoriesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MaterialCategoriesResponseToJson(this);
}

@JsonSerializable(createToJson: false)
class Material {
  final String id;
  final String sku;
  final String name;
  final String? description;
  final String? barcode;
  @JsonKey(fromJson: _materialUnitFromJson, toJson: _materialUnitToJson)
  final MaterialUnit unit;
  final double quantity;
  @JsonKey(defaultValue: 0.0)
  final double reservedQty;
  final double? minStockLevel;
  final double? costPrice;
  final double? sellPrice;
  final String? color;
  final double? width;
  final String? composition;
  final String? imageUrl;
  @JsonKey(defaultValue: true)
  final bool isActive;
  final MaterialCategory? category;
  final MaterialSupplier? supplier;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime updatedAt;

  // Computed fields from backend
  final double? availableQty;
  final bool? isLowStock;

  Material({
    required this.id,
    required this.sku,
    required this.name,
    this.description,
    this.barcode,
    required this.unit,
    required this.quantity,
    required this.reservedQty,
    this.minStockLevel,
    this.costPrice,
    this.sellPrice,
    this.color,
    this.width,
    this.composition,
    this.imageUrl,
    this.isActive = true,
    this.category,
    this.supplier,
    required this.createdAt,
    required this.updatedAt,
    this.availableQty,
    this.isLowStock,
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  double get computedAvailableQty => availableQty ?? (quantity - reservedQty);

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get computedIsLowStock =>
      isLowStock ?? (minStockLevel != null && quantity <= minStockLevel!);

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedQuantity =>
      '${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 2)} ${unit.label}';

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedAvailableQty =>
      '${computedAvailableQty.toStringAsFixed(computedAvailableQty.truncateToDouble() == computedAvailableQty ? 0 : 2)} ${unit.label}';

  factory Material.fromJson(Map<String, dynamic> json) => _$MaterialFromJson(json);

  Map<String, dynamic> toJson() => {
        'sku': sku,
        'name': name,
        'description': description,
        'barcode': barcode,
        'unit': unit.toJson(),
        'quantity': quantity,
        'minStockLevel': minStockLevel,
        'costPrice': costPrice,
        'sellPrice': sellPrice,
        'color': color,
        'width': width,
        'composition': composition,
        'imageUrl': imageUrl,
        'categoryId': category?.id,
        'supplierId': supplier?.id,
      };
}

MaterialUnit _materialUnitFromJson(String? value) =>
    MaterialUnit.fromString(value ?? 'METER');

String _materialUnitToJson(MaterialUnit unit) => unit.toJson();

@JsonSerializable()
class MaterialSupplier {
  final String id;
  final String name;

  MaterialSupplier({
    required this.id,
    required this.name,
  });

  factory MaterialSupplier.fromJson(Map<String, dynamic> json) =>
      _$MaterialSupplierFromJson(json);
  Map<String, dynamic> toJson() => _$MaterialSupplierToJson(this);
}

@JsonSerializable()
class MaterialsResponse {
  final List<Material> materials;
  @JsonKey(readValue: _readPage, defaultValue: 1)
  final int page;
  @JsonKey(readValue: _readPerPage, defaultValue: 20)
  final int perPage;
  @JsonKey(readValue: _readTotal, defaultValue: 0)
  final int total;
  @JsonKey(readValue: _readTotalPages, defaultValue: 1)
  final int totalPages;

  MaterialsResponse({
    required this.materials,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory MaterialsResponse.fromJson(Map<String, dynamic> json) =>
      _$MaterialsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MaterialsResponseToJson(this);
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

@JsonSerializable()
class LowStockResponse {
  final List<Material> materials;
  @JsonKey(defaultValue: 0)
  final int total;

  LowStockResponse({
    required this.materials,
    required this.total,
  });

  factory LowStockResponse.fromJson(Map<String, dynamic> json) =>
      _$LowStockResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LowStockResponseToJson(this);
}
