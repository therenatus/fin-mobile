// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_cost.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderCost _$OrderCostFromJson(Map<String, dynamic> json) => OrderCost(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  plannedMaterialCost: (json['plannedMaterialCost'] as num).toDouble(),
  plannedLaborCost: (json['plannedLaborCost'] as num).toDouble(),
  plannedOverheadCost: (json['plannedOverheadCost'] as num).toDouble(),
  plannedTotalCost: (json['plannedTotalCost'] as num).toDouble(),
  actualMaterialCost: (json['actualMaterialCost'] as num).toDouble(),
  actualLaborCost: (json['actualLaborCost'] as num).toDouble(),
  actualOverheadCost: (json['actualOverheadCost'] as num).toDouble(),
  actualTotalCost: (json['actualTotalCost'] as num).toDouble(),
  variancePct: (json['variancePct'] as num).toDouble(),
  createdAt: nullableDateTimeFromJson(json['createdAt']),
  updatedAt: nullableDateTimeFromJson(json['updatedAt']),
);

Map<String, dynamic> _$OrderCostToJson(OrderCost instance) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'plannedMaterialCost': instance.plannedMaterialCost,
  'plannedLaborCost': instance.plannedLaborCost,
  'plannedOverheadCost': instance.plannedOverheadCost,
  'plannedTotalCost': instance.plannedTotalCost,
  'actualMaterialCost': instance.actualMaterialCost,
  'actualLaborCost': instance.actualLaborCost,
  'actualOverheadCost': instance.actualOverheadCost,
  'actualTotalCost': instance.actualTotalCost,
  'variancePct': instance.variancePct,
  if (nullableDateTimeToJson(instance.createdAt) case final value?)
    'createdAt': value,
  if (nullableDateTimeToJson(instance.updatedAt) case final value?)
    'updatedAt': value,
};

ProfitabilityItem _$ProfitabilityItemFromJson(Map<String, dynamic> json) =>
    ProfitabilityItem(
      modelId: json['modelId'] as String,
      modelName: json['modelName'] as String,
      ordersCount: (json['ordersCount'] as num).toInt(),
      totalQuantity: (json['totalQuantity'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      totalProfit: (json['totalProfit'] as num).toDouble(),
      profitMarginPct: (json['profitMarginPct'] as num).toDouble(),
      avgUnitCost: (json['avgUnitCost'] as num).toDouble(),
    );

Map<String, dynamic> _$ProfitabilityItemToJson(ProfitabilityItem instance) =>
    <String, dynamic>{
      'modelId': instance.modelId,
      'modelName': instance.modelName,
      'ordersCount': instance.ordersCount,
      'totalQuantity': instance.totalQuantity,
      'totalRevenue': instance.totalRevenue,
      'totalCost': instance.totalCost,
      'totalProfit': instance.totalProfit,
      'profitMarginPct': instance.profitMarginPct,
      'avgUnitCost': instance.avgUnitCost,
    };

ProfitabilityReport _$ProfitabilityReportFromJson(
  Map<String, dynamic> json,
) => ProfitabilityReport(
  startDate: dateTimeFromJson(_readStartDate(json, 'startDate')),
  endDate: dateTimeFromJson(_readEndDate(json, 'endDate')),
  totalOrders: (_readTotalOrders(json, 'totalOrders') as num?)?.toInt() ?? 0,
  totalRevenue:
      (_readTotalRevenue(json, 'totalRevenue') as num?)?.toDouble() ?? 0.0,
  totalCost: (_readTotalCost(json, 'totalCost') as num?)?.toDouble() ?? 0.0,
  totalProfit:
      (_readTotalProfit(json, 'totalProfit') as num?)?.toDouble() ?? 0.0,
  overallMargin:
      (_readOverallMargin(json, 'overallMargin') as num?)?.toDouble() ?? 0.0,
  items: (json['items'] as List<dynamic>)
      .map((e) => ProfitabilityItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProfitabilityReportToJson(
  ProfitabilityReport instance,
) => <String, dynamic>{
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'totalOrders': instance.totalOrders,
  'totalRevenue': instance.totalRevenue,
  'totalCost': instance.totalCost,
  'totalProfit': instance.totalProfit,
  'overallMargin': instance.overallMargin,
  'items': instance.items.map((e) => e.toJson()).toList(),
};

VarianceItem _$VarianceItemFromJson(Map<String, dynamic> json) => VarianceItem(
  orderId: json['orderId'] as String,
  orderInfo: json['orderInfo'] as String,
  plannedCost: (json['plannedCost'] as num).toDouble(),
  actualCost: (json['actualCost'] as num).toDouble(),
  variance: (json['variance'] as num).toDouble(),
  variancePct: (json['variancePct'] as num).toDouble(),
  materialVariance: (json['materialVariance'] as num).toDouble(),
  laborVariance: (json['laborVariance'] as num).toDouble(),
);

Map<String, dynamic> _$VarianceItemToJson(VarianceItem instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'orderInfo': instance.orderInfo,
      'plannedCost': instance.plannedCost,
      'actualCost': instance.actualCost,
      'variance': instance.variance,
      'variancePct': instance.variancePct,
      'materialVariance': instance.materialVariance,
      'laborVariance': instance.laborVariance,
    };

VarianceReport _$VarianceReportFromJson(
  Map<String, dynamic> json,
) => VarianceReport(
  startDate: dateTimeFromJson(_readVarStartDate(json, 'startDate')),
  endDate: dateTimeFromJson(_readVarEndDate(json, 'endDate')),
  totalOrders: (_readVarTotalOrders(json, 'totalOrders') as num?)?.toInt() ?? 0,
  totalPlanned:
      (_readVarTotalPlanned(json, 'totalPlanned') as num?)?.toDouble() ?? 0.0,
  totalActual:
      (_readVarTotalActual(json, 'totalActual') as num?)?.toDouble() ?? 0.0,
  totalVariance:
      (_readVarTotalVariance(json, 'totalVariance') as num?)?.toDouble() ?? 0.0,
  avgVariancePct:
      (_readVarAvgVariancePct(json, 'avgVariancePct') as num?)?.toDouble() ??
      0.0,
  overBudgetCount:
      (_readVarOverBudgetCount(json, 'overBudgetCount') as num?)?.toInt() ?? 0,
  underBudgetCount:
      (_readVarUnderBudgetCount(json, 'underBudgetCount') as num?)?.toInt() ??
      0,
  items: (json['items'] as List<dynamic>)
      .map((e) => VarianceItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$VarianceReportToJson(VarianceReport instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'totalOrders': instance.totalOrders,
      'totalPlanned': instance.totalPlanned,
      'totalActual': instance.totalActual,
      'totalVariance': instance.totalVariance,
      'avgVariancePct': instance.avgVariancePct,
      'overBudgetCount': instance.overBudgetCount,
      'underBudgetCount': instance.underBudgetCount,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
