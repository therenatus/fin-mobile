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

class MaterialCategory {
  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final MaterialCategory? parent;
  final List<MaterialCategory> children;
  final int materialsCount;
  final int childrenCount;
  final DateTime createdAt;
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

  factory MaterialCategory.fromJson(Map<String, dynamic> json) {
    return MaterialCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      parentId: json['parentId'] as String?,
      parent: json['parent'] != null
          ? MaterialCategory.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => MaterialCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      materialsCount: (json['_count']?['materials'] as int?) ?? 0,
      childrenCount: (json['_count']?['children'] as int?) ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'parentId': parentId,
      };
}

class MaterialCategoriesResponse {
  final List<MaterialCategory> categories;
  final List<MaterialCategory> flat;

  MaterialCategoriesResponse({
    required this.categories,
    required this.flat,
  });

  factory MaterialCategoriesResponse.fromJson(Map<String, dynamic> json) {
    return MaterialCategoriesResponse(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => MaterialCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      flat: (json['flat'] as List<dynamic>?)
              ?.map((e) => MaterialCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Material {
  final String id;
  final String sku;
  final String name;
  final String? description;
  final String? barcode;
  final MaterialUnit unit;
  final double quantity;
  final double reservedQty;
  final double? minStockLevel;
  final double? costPrice;
  final double? sellPrice;
  final String? color;
  final double? width;
  final String? composition;
  final String? imageUrl;
  final bool isActive;
  final MaterialCategory? category;
  final MaterialSupplier? supplier;
  final DateTime createdAt;
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

  double get computedAvailableQty => availableQty ?? (quantity - reservedQty);

  bool get computedIsLowStock =>
      isLowStock ?? (minStockLevel != null && quantity <= minStockLevel!);

  String get formattedQuantity => '${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 2)} ${unit.label}';

  String get formattedAvailableQty => '${computedAvailableQty.toStringAsFixed(computedAvailableQty.truncateToDouble() == computedAvailableQty ? 0 : 2)} ${unit.label}';

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      barcode: json['barcode'] as String?,
      unit: MaterialUnit.fromString(json['unit'] as String? ?? 'METER'),
      quantity: (json['quantity'] as num).toDouble(),
      reservedQty: (json['reservedQty'] as num?)?.toDouble() ?? 0,
      minStockLevel: (json['minStockLevel'] as num?)?.toDouble(),
      costPrice: (json['costPrice'] as num?)?.toDouble(),
      sellPrice: (json['sellPrice'] as num?)?.toDouble(),
      color: json['color'] as String?,
      width: (json['width'] as num?)?.toDouble(),
      composition: json['composition'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      category: json['category'] != null
          ? MaterialCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      supplier: json['supplier'] != null
          ? MaterialSupplier.fromJson(json['supplier'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      availableQty: (json['availableQty'] as num?)?.toDouble(),
      isLowStock: json['isLowStock'] as bool?,
    );
  }

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

class MaterialSupplier {
  final String id;
  final String name;

  MaterialSupplier({
    required this.id,
    required this.name,
  });

  factory MaterialSupplier.fromJson(Map<String, dynamic> json) {
    return MaterialSupplier(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class MaterialsResponse {
  final List<Material> materials;
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  MaterialsResponse({
    required this.materials,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory MaterialsResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>?;
    return MaterialsResponse(
      materials: (json['materials'] as List<dynamic>)
          .map((e) => Material.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: meta?['page'] as int? ?? 1,
      perPage: meta?['per_page'] as int? ?? 20,
      total: meta?['total'] as int? ?? 0,
      totalPages: meta?['total_pages'] as int? ?? 1,
    );
  }
}

class LowStockResponse {
  final List<Material> materials;
  final int total;

  LowStockResponse({
    required this.materials,
    required this.total,
  });

  factory LowStockResponse.fromJson(Map<String, dynamic> json) {
    return LowStockResponse(
      materials: (json['materials'] as List<dynamic>)
          .map((e) => Material.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }
}
