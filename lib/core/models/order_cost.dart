/// Себестоимость заказа
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
  final DateTime? createdAt;
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
  double get variance => actualTotalCost - plannedTotalCost;

  /// Отклонение по материалам
  double get materialVariance => actualMaterialCost - plannedMaterialCost;

  /// Отклонение по работе
  double get laborVariance => actualLaborCost - plannedLaborCost;

  /// Отклонение по накладным
  double get overheadVariance => actualOverheadCost - plannedOverheadCost;

  /// Превышен ли бюджет
  bool get isOverBudget => variancePct > 0;

  /// Форматированная плановая себестоимость
  String get formattedPlannedCost => '${plannedTotalCost.toStringAsFixed(0)} ₽';

  /// Форматированная фактическая себестоимость
  String get formattedActualCost => '${actualTotalCost.toStringAsFixed(0)} ₽';

  /// Форматированное отклонение
  String get formattedVariance {
    final sign = variance >= 0 ? '+' : '';
    return '$sign${variance.toStringAsFixed(0)} ₽';
  }

  /// Форматированный процент отклонения
  String get formattedVariancePct {
    final sign = variancePct >= 0 ? '+' : '';
    return '$sign${variancePct.toStringAsFixed(1)}%';
  }

  factory OrderCost.fromJson(Map<String, dynamic> json) {
    return OrderCost(
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
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

/// Элемент отчёта по рентабельности
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

  bool get isProfitable => profitMarginPct > 0;

  String get formattedProfit {
    final sign = totalProfit >= 0 ? '+' : '';
    return '$sign${totalProfit.toStringAsFixed(0)} ₽';
  }

  String get formattedMargin {
    final sign = profitMarginPct >= 0 ? '+' : '';
    return '$sign${profitMarginPct.toStringAsFixed(1)}%';
  }

  factory ProfitabilityItem.fromJson(Map<String, dynamic> json) {
    return ProfitabilityItem(
      modelId: json['modelId'] as String,
      modelName: json['modelName'] as String,
      ordersCount: json['ordersCount'] as int,
      totalQuantity: json['totalQuantity'] as int,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      totalProfit: (json['totalProfit'] as num).toDouble(),
      profitMarginPct: (json['profitMarginPct'] as num).toDouble(),
      avgUnitCost: (json['avgUnitCost'] as num).toDouble(),
    );
  }
}

/// Отчёт по рентабельности
class ProfitabilityReport {
  final DateTime startDate;
  final DateTime endDate;
  final int totalOrders;
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
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

  factory ProfitabilityReport.fromJson(Map<String, dynamic> json) {
    final period = json['period'] as Map<String, dynamic>;
    final summary = json['summary'] as Map<String, dynamic>;
    return ProfitabilityReport(
      startDate: DateTime.parse(period['startDate'] as String),
      endDate: DateTime.parse(period['endDate'] as String),
      totalOrders: summary['totalOrders'] as int,
      totalRevenue: (summary['totalRevenue'] as num).toDouble(),
      totalCost: (summary['totalCost'] as num).toDouble(),
      totalProfit: (summary['totalProfit'] as num).toDouble(),
      overallMargin: (summary['overallMargin'] as num).toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((e) => ProfitabilityItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Элемент отчёта по отклонениям
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

  bool get isOverBudget => variancePct > 0;

  String get formattedVariance {
    final sign = variance >= 0 ? '+' : '';
    return '$sign${variance.toStringAsFixed(0)} ₽';
  }

  String get formattedVariancePct {
    final sign = variancePct >= 0 ? '+' : '';
    return '$sign${variancePct.toStringAsFixed(1)}%';
  }

  factory VarianceItem.fromJson(Map<String, dynamic> json) {
    return VarianceItem(
      orderId: json['orderId'] as String,
      orderInfo: json['orderInfo'] as String,
      plannedCost: (json['plannedCost'] as num).toDouble(),
      actualCost: (json['actualCost'] as num).toDouble(),
      variance: (json['variance'] as num).toDouble(),
      variancePct: (json['variancePct'] as num).toDouble(),
      materialVariance: (json['materialVariance'] as num).toDouble(),
      laborVariance: (json['laborVariance'] as num).toDouble(),
    );
  }
}

/// Отчёт по отклонениям план/факт
class VarianceReport {
  final DateTime startDate;
  final DateTime endDate;
  final int totalOrders;
  final double totalPlanned;
  final double totalActual;
  final double totalVariance;
  final double avgVariancePct;
  final int overBudgetCount;
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

  factory VarianceReport.fromJson(Map<String, dynamic> json) {
    final period = json['period'] as Map<String, dynamic>;
    final summary = json['summary'] as Map<String, dynamic>;
    return VarianceReport(
      startDate: DateTime.parse(period['startDate'] as String),
      endDate: DateTime.parse(period['endDate'] as String),
      totalOrders: summary['totalOrders'] as int,
      totalPlanned: (summary['totalPlanned'] as num).toDouble(),
      totalActual: (summary['totalActual'] as num).toDouble(),
      totalVariance: (summary['totalVariance'] as num).toDouble(),
      avgVariancePct: (summary['avgVariancePct'] as num).toDouble(),
      overBudgetCount: summary['overBudgetCount'] as int,
      underBudgetCount: summary['underBudgetCount'] as int,
      items: (json['items'] as List<dynamic>)
          .map((e) => VarianceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
