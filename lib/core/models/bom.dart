import 'package:json_annotation/json_annotation.dart';
import 'material.dart' as mat;
import 'json_converters.dart';

part 'bom.g.dart';

/// BOM Item - материал в спецификации
@JsonSerializable(createToJson: false)
class BomItem {
  final String id;
  final String bomId;
  final String materialId;
  final double quantity;
  @JsonKey(name: 'wastePct', defaultValue: 5.0)
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
  @JsonKey(includeFromJson: false, includeToJson: false)
  double get calculatedEffectiveQty => effectiveQty ?? quantity * (1 + wastePct / 100);

  /// Стоимость материала
  @JsonKey(includeFromJson: false, includeToJson: false)
  double get calculatedUnitCost => unitCost ?? (material?.costPrice ?? 0) * calculatedEffectiveQty;

  factory BomItem.fromJson(Map<String, dynamic> json) => _$BomItemFromJson(json);

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'materialId': materialId,
        'quantity': quantity,
        'wastePct': wastePct,
        if (notes != null) 'notes': notes,
      };
}

/// Материал в BOM (упрощённая версия)
@JsonSerializable()
class BomMaterial {
  final String id;
  final String name;
  final String sku;
  @JsonKey(defaultValue: 'METER')
  final String unit;
  final double? costPrice;

  BomMaterial({
    required this.id,
    required this.name,
    required this.sku,
    required this.unit,
    this.costPrice,
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  mat.MaterialUnit get materialUnit => mat.MaterialUnit.fromString(unit);

  factory BomMaterial.fromJson(Map<String, dynamic> json) => _$BomMaterialFromJson(json);
  Map<String, dynamic> toJson() => _$BomMaterialToJson(this);
}

/// BOM Model (упрощённая версия)
@JsonSerializable()
class BomModel {
  final String id;
  final String name;

  BomModel({
    required this.id,
    required this.name,
  });

  factory BomModel.fromJson(Map<String, dynamic> json) => _$BomModelFromJson(json);
  Map<String, dynamic> toJson() => _$BomModelToJson(this);
}

/// BOM - Bill of Materials (Технологическая карта)
@JsonSerializable()
class Bom {
  final String id;
  final String tenantId;
  final String modelId;
  final int version;
  @JsonKey(defaultValue: false)
  final bool isActive;
  final String? notes;
  final String? createdBy;
  @JsonKey(defaultValue: 0.0)
  final double totalMaterialCost;
  @JsonKey(defaultValue: 0.0)
  final double totalLaborCost;
  @JsonKey(defaultValue: 0.0)
  final double totalCost;
  @JsonKey(defaultValue: [])
  final List<BomItem> items;
  final BomModel? model;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
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
    this.model,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Форматированная стоимость материалов
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedMaterialCost => '${totalMaterialCost.toStringAsFixed(0)} сом';

  /// Форматированная стоимость работы
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedLaborCost => '${totalLaborCost.toStringAsFixed(0)} сом';

  /// Форматированная общая себестоимость
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedTotalCost => '${totalCost.toStringAsFixed(0)} сом';

  factory Bom.fromJson(Map<String, dynamic> json) => _$BomFromJson(json);
  Map<String, dynamic> toJson() => _$BomToJson(this);
}

/// Версия BOM (для списка версий)
@JsonSerializable()
class BomVersion {
  final String id;
  final int version;
  @JsonKey(defaultValue: false)
  final bool isActive;
  @JsonKey(defaultValue: 0.0)
  final double totalMaterialCost;
  @JsonKey(defaultValue: 0.0)
  final double totalLaborCost;
  @JsonKey(defaultValue: 0.0)
  final double totalCost;
  final String? notes;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedTotalCost => '${totalCost.toStringAsFixed(0)} сом';

  factory BomVersion.fromJson(Map<String, dynamic> json) => _$BomVersionFromJson(json);
  Map<String, dynamic> toJson() => _$BomVersionToJson(this);
}

/// Ответ со списком версий BOM
@JsonSerializable()
class BomVersionsResponse {
  final List<BomVersion> versions;
  @JsonKey(defaultValue: 0)
  final int total;

  BomVersionsResponse({
    required this.versions,
    required this.total,
  });

  factory BomVersionsResponse.fromJson(Map<String, dynamic> json) => _$BomVersionsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BomVersionsResponseToJson(this);
}
