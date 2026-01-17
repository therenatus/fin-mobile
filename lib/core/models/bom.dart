import 'material.dart' as mat;

/// BOM Item - материал в спецификации
class BomItem {
  final String id;
  final String bomId;
  final String materialId;
  final double quantity;
  final double wastePct;
  final double? effectiveQty;
  final double? unitCost;
  final String? notes;
  final BomMaterial? material;

  BomItem({
    required this.id,
    required this.bomId,
    required this.materialId,
    required this.quantity,
    required this.wastePct,
    this.effectiveQty,
    this.unitCost,
    this.notes,
    this.material,
  });

  /// Расчётное количество с учётом отходов
  double get calculatedEffectiveQty => effectiveQty ?? quantity * (1 + wastePct / 100);

  /// Стоимость материала
  double get calculatedUnitCost => unitCost ?? (material?.costPrice ?? 0) * calculatedEffectiveQty;

  factory BomItem.fromJson(Map<String, dynamic> json) {
    return BomItem(
      id: json['id'] as String,
      bomId: json['bomId'] as String,
      materialId: json['materialId'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      wastePct: (json['wastePct'] as num?)?.toDouble() ?? 5,
      effectiveQty: (json['effectiveQty'] as num?)?.toDouble(),
      unitCost: (json['unitCost'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      material: json['material'] != null
          ? BomMaterial.fromJson(json['material'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'materialId': materialId,
        'quantity': quantity,
        'wastePct': wastePct,
        if (notes != null) 'notes': notes,
      };
}

/// Материал в BOM (упрощённая версия)
class BomMaterial {
  final String id;
  final String name;
  final String sku;
  final String unit;
  final double? costPrice;

  BomMaterial({
    required this.id,
    required this.name,
    required this.sku,
    required this.unit,
    this.costPrice,
  });

  mat.MaterialUnit get materialUnit => mat.MaterialUnit.fromString(unit);

  factory BomMaterial.fromJson(Map<String, dynamic> json) {
    return BomMaterial(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      unit: json['unit'] as String? ?? 'METER',
      costPrice: (json['costPrice'] as num?)?.toDouble(),
    );
  }
}

/// BOM Operation - операция в спецификации
class BomOperation {
  final String id;
  final String bomId;
  final String name;
  final int sequence;
  final int setupTime;
  final int unitTime;
  final double? hourlyRate;
  final String? requiredRole;
  final double? laborCost;

  BomOperation({
    required this.id,
    required this.bomId,
    required this.name,
    required this.sequence,
    required this.setupTime,
    required this.unitTime,
    this.hourlyRate,
    this.requiredRole,
    this.laborCost,
  });

  /// Общее время операции (наладка + работа) в минутах
  int get totalTime => setupTime + unitTime;

  /// Форматированное время
  String get formattedTime {
    if (totalTime < 60) return '$totalTime мин';
    final hours = totalTime ~/ 60;
    final mins = totalTime % 60;
    if (mins == 0) return '$hours ч';
    return '$hours ч $mins мин';
  }

  /// Расчётная стоимость работы
  double get calculatedLaborCost => laborCost ?? 0;

  factory BomOperation.fromJson(Map<String, dynamic> json) {
    return BomOperation(
      id: json['id'] as String,
      bomId: json['bomId'] as String,
      name: json['name'] as String,
      sequence: json['sequence'] as int,
      setupTime: json['setupTime'] as int? ?? 0,
      unitTime: json['unitTime'] as int,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      requiredRole: json['requiredRole'] as String?,
      laborCost: (json['laborCost'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'name': name,
        'sequence': sequence,
        'setupTime': setupTime,
        'unitTime': unitTime,
        if (hourlyRate != null) 'hourlyRate': hourlyRate,
        if (requiredRole != null) 'requiredRole': requiredRole,
      };
}

/// BOM Model (упрощённая версия)
class BomModel {
  final String id;
  final String name;

  BomModel({
    required this.id,
    required this.name,
  });

  factory BomModel.fromJson(Map<String, dynamic> json) {
    return BomModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

/// BOM - Bill of Materials (Технологическая карта)
class Bom {
  final String id;
  final String tenantId;
  final String modelId;
  final int version;
  final bool isActive;
  final String? notes;
  final String? createdBy;
  final double totalMaterialCost;
  final double totalLaborCost;
  final double totalCost;
  final List<BomItem> items;
  final List<BomOperation> operations;
  final BomModel? model;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bom({
    required this.id,
    required this.tenantId,
    required this.modelId,
    required this.version,
    required this.isActive,
    this.notes,
    this.createdBy,
    required this.totalMaterialCost,
    required this.totalLaborCost,
    required this.totalCost,
    required this.items,
    required this.operations,
    this.model,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Форматированная стоимость материалов
  String get formattedMaterialCost => '${totalMaterialCost.toStringAsFixed(0)} ₽';

  /// Форматированная стоимость работы
  String get formattedLaborCost => '${totalLaborCost.toStringAsFixed(0)} ₽';

  /// Форматированная общая себестоимость
  String get formattedTotalCost => '${totalCost.toStringAsFixed(0)} ₽';

  factory Bom.fromJson(Map<String, dynamic> json) {
    return Bom(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      modelId: json['modelId'] as String,
      version: json['version'] as int,
      isActive: json['isActive'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String?,
      totalMaterialCost: (json['totalMaterialCost'] as num?)?.toDouble() ?? 0,
      totalLaborCost: (json['totalLaborCost'] as num?)?.toDouble() ?? 0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => BomItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      operations: (json['operations'] as List<dynamic>?)
              ?.map((e) => BomOperation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      model: json['model'] != null
          ? BomModel.fromJson(json['model'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Версия BOM (для списка версий)
class BomVersion {
  final String id;
  final int version;
  final bool isActive;
  final double totalMaterialCost;
  final double totalLaborCost;
  final double totalCost;
  final String? notes;
  final DateTime createdAt;

  BomVersion({
    required this.id,
    required this.version,
    required this.isActive,
    required this.totalMaterialCost,
    required this.totalLaborCost,
    required this.totalCost,
    this.notes,
    required this.createdAt,
  });

  String get formattedTotalCost => '${totalCost.toStringAsFixed(0)} ₽';

  factory BomVersion.fromJson(Map<String, dynamic> json) {
    return BomVersion(
      id: json['id'] as String,
      version: json['version'] as int,
      isActive: json['isActive'] as bool? ?? false,
      totalMaterialCost: (json['totalMaterialCost'] as num?)?.toDouble() ?? 0,
      totalLaborCost: (json['totalLaborCost'] as num?)?.toDouble() ?? 0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Ответ со списком версий BOM
class BomVersionsResponse {
  final List<BomVersion> versions;
  final int total;

  BomVersionsResponse({
    required this.versions,
    required this.total,
  });

  factory BomVersionsResponse.fromJson(Map<String, dynamic> json) {
    return BomVersionsResponse(
      versions: (json['versions'] as List<dynamic>)
          .map((e) => BomVersion.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }
}
