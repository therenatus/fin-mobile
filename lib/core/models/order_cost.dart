import 'package:json_annotation/json_annotation.dart';
import 'json_converters.dart';

part 'order_cost.g.dart';

/// Себестоимость заказа
@JsonSerializable()
class OrderCost {
  final String id;
  final String orderId;
  final double plannedMaterialCost;
  final double plannedLaborCost;
  final double plannedOverheadCost;
  final double plannedTotalCost;
  final double actualMaterialCost;
  final double actualLaborCost;
  final double actualOverheadCost;
  final double actualTotalCost;
  final double variancePct;
  @JsonKey(fromJson: nullableDateTimeFromJson, toJson: nullableDateTimeToJson)
  final DateTime? createdAt;
  @JsonKey(fromJson: nullableDateTimeFromJson, toJson: nullableDateTimeToJson)
  final DateTime? updatedAt;

  OrderCost({
    required this.id,
    required this.orderId,
    required this.plannedMaterialCost,
    required this.plannedLaborCost,
    required this.plannedOverheadCost,
    required this.plannedTotalCost,
    required this.actualMaterialCost,
    required this.actualLaborCost,
    required this.actualOverheadCost,
    required this.actualTotalCost,
    required this.variancePct,
    this.createdAt,
    this.updatedAt,
  });

  /// Абсолютное отклонение
  @JsonKey(includeFromJson: false, includeToJson: false)
  double get variance => actualTotalCost - plannedTotalCost;

  /// Отклонение по материалам
  @JsonKey(includeFromJson: false, includeToJson: false)
  double get materialVariance => actualMaterialCost - plannedMaterialCost;

  /// Отклонение по работе
  @JsonKey(includeFromJson: false, includeToJson: false)
  double get laborVariance => actualLaborCost - plannedLaborCost;

  /// Отклонение по накладным
  @JsonKey(includeFromJson: false, includeToJson: false)
  double get overheadVariance => actualOverheadCost - plannedOverheadCost;

  /// Превышен ли бюджет
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isOverBudget => variancePct > 0;

  /// Форматированная плановая себестоимость
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedPlannedCost => '${plannedTotalCost.toStringAsFixed(0)} ₽';

  /// Форматированная фактическая себестоимость
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedActualCost => '${actualTotalCost.toStringAsFixed(0)} ₽';

  /// Форматированное отклонение
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedVariance {
    final sign = variance >= 0 ? '+' : '';
    return '$sign${variance.toStringAsFixed(0)} ₽';
  }

  /// Форматированный процент отклонения
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedVariancePct {
    final sign = variancePct >= 0 ? '+' : '';
    return '$sign${variancePct.toStringAsFixed(1)}%';
  }

  factory OrderCost.fromJson(Map<String, dynamic> json) => _$OrderCostFromJson(json);
  Map<String, dynamic> toJson() => _$OrderCostToJson(this);
}

/// Элемент отчёта по рентабельности
@JsonSerializable()
class ProfitabilityItem {
  final String modelId;
  final String modelName;
  final int ordersCount;
  final int totalQuantity;
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final double profitMarginPct;
  final double avgUnitCost;

  ProfitabilityItem({
    required this.modelId,
    required this.modelName,
    required this.ordersCount,
    required this.totalQuantity,
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.profitMarginPct,
    required this.avgUnitCost,
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isProfitable => profitMarginPct > 0;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedProfit {
    final sign = totalProfit >= 0 ? '+' : '';
    return '$sign${totalProfit.toStringAsFixed(0)} ₽';
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedMargin {
    final sign = profitMarginPct >= 0 ? '+' : '';
    return '$sign${profitMarginPct.toStringAsFixed(1)}%';
  }

  factory ProfitabilityItem.fromJson(Map<String, dynamic> json) => _$ProfitabilityItemFromJson(json);
  Map<String, dynamic> toJson() => _$ProfitabilityItemToJson(this);
}

/// Отчёт по рентабельности
@JsonSerializable()
class ProfitabilityReport {
  @JsonKey(readValue: _readStartDate, fromJson: dateTimeFromJson)
  final DateTime startDate;
  @JsonKey(readValue: _readEndDate, fromJson: dateTimeFromJson)
  final DateTime endDate;
  @JsonKey(readValue: _readTotalOrders, defaultValue: 0)
  final int totalOrders;
  @JsonKey(readValue: _readTotalRevenue, defaultValue: 0.0)
  final double totalRevenue;
  @JsonKey(readValue: _readTotalCost, defaultValue: 0.0)
  final double totalCost;
  @JsonKey(readValue: _readTotalProfit, defaultValue: 0.0)
  final double totalProfit;
  @JsonKey(readValue: _readOverallMargin, defaultValue: 0.0)
  final double overallMargin;
  final List<ProfitabilityItem> items;

  ProfitabilityReport({
    required this.startDate,
    required this.endDate,
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.overallMargin,
    required this.items,
  });

  factory ProfitabilityReport.fromJson(Map<String, dynamic> json) => _$ProfitabilityReportFromJson(json);
  Map<String, dynamic> toJson() => _$ProfitabilityReportToJson(this);
}

// Helper functions for reading nested fields
Object? _readStartDate(Map<dynamic, dynamic> json, String key) =>
    (json['period'] as Map<String, dynamic>?)?['startDate'];
Object? _readEndDate(Map<dynamic, dynamic> json, String key) =>
    (json['period'] as Map<String, dynamic>?)?['endDate'];
Object? _readTotalOrders(Map<dynamic, dynamic> json, String key) =>
    (json['summary'] as Map<String, dynamic>?)?['totalOrders'];
Object? _readTotalRevenue(Map<dynamic, dynamic> json, String key) =>
    (json['summary'] as Map<String, dynamic>?)?['totalRevenue'];
Object? _readTotalCost(Map<dynamic, dynamic> json, String key) =>
    (json['summary'] as Map<String, dynamic>?)?['totalCost'];
Object? _readTotalProfit(Map<dynamic, dynamic> json, String key) =>
    (json['summary'] as Map<String, dynamic>?)?['totalProfit'];
Object? _readOverallMargin(Map<dynamic, dynamic> json, String key) =>
    (json['summary'] as Map<String, dynamic>?)?['overallMargin'];

/// Элемент отчёта по отклонениям
@JsonSerializable()
class VarianceItem {
  final String orderId;
  final String orderInfo;
  final double plannedCost;
  final double actualCost;
  final double variance;
  final double variancePct;
  final double materialVariance;
  final double laborVariance;

  VarianceItem({
    required this.orderId,
    required this.orderInfo,
    required this.plannedCost,
    required this.actualCost,
    required this.variance,
    required this.variancePct,
    required this.materialVariance,
    required this.laborVariance,
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isOverBudget => variancePct > 0;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedVariance {
    final sign = variance >= 0 ? '+' : '';
    return '$sign${variance.toStringAsFixed(0)} ₽';
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedVariancePct {
    final sign = variancePct >= 0 ? '+' : '';
    return '$sign${variancePct.toStringAsFixed(1)}%';
  }

  factory VarianceItem.fromJson(Map<String, dynamic> json) => _$VarianceItemFromJson(json);
  Map<String, dynamic> toJson() => _$VarianceItemToJson(this);
}

/// Отчёт по отклонениям план/факт
@JsonSerializable()
class VarianceReport {
  @JsonKey(readValue: _readVarStartDate, fromJson: dateTimeFromJson)
  final DateTime startDate;
  @JsonKey(readValue: _readVarEndDate, fromJson: dateTimeFromJson)
  final DateTime endDate;
  @JsonKey(readValue: _readVarTotalOrders, defaultValue: 0)
  final int totalOrders;
  @JsonKey(readValue: _readVarTotalPlanned, defaultValue: 0.0)
  final double totalPlanned;
  @JsonKey(readValue: _readVarTotalActual, defaultValue: 0.0)
  final double totalActual;
  @JsonKey(readValue: _readVarTotalVariance, defaultValue: 0.0)
  final double totalVariance;
  @JsonKey(readValue: _readVarAvgVariancePct, defaultValue: 0.0)
  final double avgVariancePct;
  @JsonKey(readValue: _readVarOverBudgetCount, defaultValue: 0)
  final int overBudgetCount;
  @JsonKey(readValue: _readVarUnderBudgetCount, defaultValue: 0)
  final int underBudgetCount;
  final List<VarianceItem> items;

  VarianceReport({
    required this.startDate,
    required this.endDate,
    required this.totalOrders,
    required this.totalPlanned,
    required this.totalActual,
    required this.totalVariance,
    required this.avgVariancePct,
    required this.overBudgetCount,
    required this.underBudgetCount,
    required this.items,
  });

  factory VarianceReport.fromJson(Map<String, dynamic> json) => _$VarianceReportFromJson(json);
  Map<String, dynamic> toJson() => _$VarianceReportToJson(this);
}

// Helper functions for VarianceReport nested fields
Object? _readVarStartDate(Map<dynamic, dynamic> json, String key) =>
    (json['period'] as Map<String, dynamic>?)?['startDate'];
Object? _readVarEndDate(Map<dynamic, dynamic> json, String key) =>
    (json['period'] as Map<String, dynamic>?)?['endDate'];
Object? _readVarTotalOrders(Map<dynamic, dynamic> json, String key) =>
    (json['summary'] as Map<String, dynamic>?)?['totalOrders'];
Object? _readVarTotalPlanned(Map<dynamic, dynamic> json, String key) =>
    (json['summary'] as Map<String, dynamic>?)?['totalPlanned'];
Object? _readVarTotalActual(Map<dynamic, dynamic> json, String key) =>
    (json['summary'] as Map<String, dynamic>?)?['totalActual'];
Object? _readVarTotalVariance(Map<dynamic, dynamic> json, String key) =>
    (json['summary'] as Map<String, dynamic>?)?['totalVariance'];
Object? _readVarAvgVariancePct(Map<dynamic, dynamic> json, String key) =>
    (json['summary'] as Map<String, dynamic>?)?['avgVariancePct'];
Object? _readVarOverBudgetCount(Map<dynamic, dynamic> json, String key) =>
    (json['summary'] as Map<String, dynamic>?)?['overBudgetCount'];
Object? _readVarUnderBudgetCount(Map<dynamic, dynamic> json, String key) =>
    (json['summary'] as Map<String, dynamic>?)?['underBudgetCount'];
