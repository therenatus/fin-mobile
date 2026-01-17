import 'package:json_annotation/json_annotation.dart';

part 'forecast.g.dart';

@JsonSerializable()
class ConfidenceInterval {
  final double low;
  final double high;

  ConfidenceInterval({
    required this.low,
    required this.high,
  });

  factory ConfidenceInterval.fromJson(Map<String, dynamic> json) =>
      _$ConfidenceIntervalFromJson(json);

  Map<String, dynamic> toJson() => _$ConfidenceIntervalToJson(this);
}

@JsonSerializable()
class Forecast {
  final String type;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double predictedValue;
  final ConfidenceInterval confidenceInterval;
  final String trend;
  final double trendPercentage;
  @JsonKey(defaultValue: [])
  final List<String> insights;

  Forecast({
    required this.type,
    required this.periodStart,
    required this.periodEnd,
    required this.predictedValue,
    required this.confidenceInterval,
    required this.trend,
    required this.trendPercentage,
    required this.insights,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) =>
      _$ForecastFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastToJson(this);

  bool get isUpTrend => trend == 'up';
  bool get isDownTrend => trend == 'down';
  bool get isStable => trend == 'stable';
}

@JsonSerializable()
class MlReport {
  final String id;
  final String type;
  final String content;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime createdAt;

  MlReport({
    required this.id,
    required this.type,
    required this.content,
    this.periodStart,
    this.periodEnd,
    required this.createdAt,
  });

  factory MlReport.fromJson(Map<String, dynamic> json) =>
      _$MlReportFromJson(json);

  Map<String, dynamic> toJson() => _$MlReportToJson(this);

  String get typeLabel {
    switch (type) {
      case 'monthly_summary':
        return 'Месячный обзор';
      case 'order_analysis':
        return 'Анализ заказов';
      case 'client_insights':
        return 'Заказчикская аналитика';
      case 'revenue_forecast':
        return 'Прогноз выручки';
      case 'efficiency_report':
        return 'Отчёт эффективности';
      default:
        return type;
    }
  }
}

@JsonSerializable()
class BusinessInsights {
  final List<String> insights;
  final InsightMetrics metrics;

  BusinessInsights({
    required this.insights,
    required this.metrics,
  });

  factory BusinessInsights.fromJson(Map<String, dynamic> json) =>
      _$BusinessInsightsFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessInsightsToJson(this);
}

@JsonSerializable()
class InsightMetrics {
  final int recentOrders;
  final int overdueOrders;
  final double revenueChange;
  @JsonKey(defaultValue: '')
  final String topCategory;

  InsightMetrics({
    required this.recentOrders,
    required this.overdueOrders,
    required this.revenueChange,
    required this.topCategory,
  });

  factory InsightMetrics.fromJson(Map<String, dynamic> json) =>
      _$InsightMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$InsightMetricsToJson(this);
}

@JsonSerializable()
class MlLimits {
  final int forecastLimit;
  final int reportLimit;
  final int insightLimit;

  MlLimits({
    required this.forecastLimit,
    required this.reportLimit,
    required this.insightLimit,
  });

  factory MlLimits.fromJson(Map<String, dynamic> json) =>
      _$MlLimitsFromJson(json);

  Map<String, dynamic> toJson() => _$MlLimitsToJson(this);

  bool get forecastDisabled => forecastLimit == -1;
  bool get reportDisabled => reportLimit == -1;
  bool get insightDisabled => insightLimit == -1;

  bool get forecastUnlimited => forecastLimit == 0;
  bool get reportUnlimited => reportLimit == 0;
  bool get insightUnlimited => insightLimit == 0;
}

@JsonSerializable()
class MlUsageInfo {
  final int forecastCount;
  final int reportCount;
  final int insightCount;
  final MlLimits limits;
  final int forecastRemaining;
  final int reportRemaining;
  final int insightRemaining;

  MlUsageInfo({
    required this.forecastCount,
    required this.reportCount,
    required this.insightCount,
    required this.limits,
    required this.forecastRemaining,
    required this.reportRemaining,
    required this.insightRemaining,
  });

  factory MlUsageInfo.fromJson(Map<String, dynamic> json) =>
      _$MlUsageInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MlUsageInfoToJson(this);

  String get forecastUsageText {
    if (limits.forecastDisabled) return 'Недоступно';
    if (limits.forecastUnlimited) return '$forecastCount (безлимит)';
    return '$forecastCount / ${limits.forecastLimit}';
  }

  String get reportUsageText {
    if (limits.reportDisabled) return 'Недоступно';
    if (limits.reportUnlimited) return '$reportCount (безлимит)';
    return '$reportCount / ${limits.reportLimit}';
  }

  String get insightUsageText {
    if (limits.insightDisabled) return 'Недоступно';
    if (limits.insightUnlimited) return '$insightCount (безлимит)';
    return '$insightCount / ${limits.insightLimit}';
  }
}
