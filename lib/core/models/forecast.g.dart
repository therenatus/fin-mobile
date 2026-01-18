// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfidenceInterval _$ConfidenceIntervalFromJson(Map<String, dynamic> json) =>
    ConfidenceInterval(
      low: (json['low'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
    );

Map<String, dynamic> _$ConfidenceIntervalToJson(ConfidenceInterval instance) =>
    <String, dynamic>{'low': instance.low, 'high': instance.high};

Forecast _$ForecastFromJson(Map<String, dynamic> json) => Forecast(
  type: json['type'] as String,
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  predictedValue: (json['predictedValue'] as num).toDouble(),
  confidenceInterval: ConfidenceInterval.fromJson(
    json['confidenceInterval'] as Map<String, dynamic>,
  ),
  trend: json['trend'] as String,
  trendPercentage: (json['trendPercentage'] as num).toDouble(),
  insights:
      (json['insights'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
);

Map<String, dynamic> _$ForecastToJson(Forecast instance) => <String, dynamic>{
  'type': instance.type,
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'predictedValue': instance.predictedValue,
  'confidenceInterval': instance.confidenceInterval.toJson(),
  'trend': instance.trend,
  'trendPercentage': instance.trendPercentage,
  'insights': instance.insights,
};

MlReport _$MlReportFromJson(Map<String, dynamic> json) => MlReport(
  id: json['id'] as String,
  type: json['type'] as String,
  content: json['content'] as String,
  periodStart: json['periodStart'] == null
      ? null
      : DateTime.parse(json['periodStart'] as String),
  periodEnd: json['periodEnd'] == null
      ? null
      : DateTime.parse(json['periodEnd'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MlReportToJson(MlReport instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'content': instance.content,
  if (instance.periodStart?.toIso8601String() case final value?)
    'periodStart': value,
  if (instance.periodEnd?.toIso8601String() case final value?)
    'periodEnd': value,
  'createdAt': instance.createdAt.toIso8601String(),
};

BusinessInsights _$BusinessInsightsFromJson(Map<String, dynamic> json) =>
    BusinessInsights(
      insights: (json['insights'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metrics: InsightMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BusinessInsightsToJson(BusinessInsights instance) =>
    <String, dynamic>{
      'insights': instance.insights,
      'metrics': instance.metrics.toJson(),
    };

InsightMetrics _$InsightMetricsFromJson(Map<String, dynamic> json) =>
    InsightMetrics(
      recentOrders: (json['recentOrders'] as num).toInt(),
      overdueOrders: (json['overdueOrders'] as num).toInt(),
      revenueChange: (json['revenueChange'] as num).toDouble(),
      topCategory: json['topCategory'] as String? ?? '',
    );

Map<String, dynamic> _$InsightMetricsToJson(InsightMetrics instance) =>
    <String, dynamic>{
      'recentOrders': instance.recentOrders,
      'overdueOrders': instance.overdueOrders,
      'revenueChange': instance.revenueChange,
      'topCategory': instance.topCategory,
    };

MlLimits _$MlLimitsFromJson(Map<String, dynamic> json) => MlLimits(
  forecastLimit: (json['forecastLimit'] as num).toInt(),
  reportLimit: (json['reportLimit'] as num).toInt(),
  insightLimit: (json['insightLimit'] as num).toInt(),
);

Map<String, dynamic> _$MlLimitsToJson(MlLimits instance) => <String, dynamic>{
  'forecastLimit': instance.forecastLimit,
  'reportLimit': instance.reportLimit,
  'insightLimit': instance.insightLimit,
};

MlUsageInfo _$MlUsageInfoFromJson(Map<String, dynamic> json) => MlUsageInfo(
  forecastCount: (json['forecastCount'] as num).toInt(),
  reportCount: (json['reportCount'] as num).toInt(),
  insightCount: (json['insightCount'] as num).toInt(),
  limits: MlLimits.fromJson(json['limits'] as Map<String, dynamic>),
  forecastRemaining: (json['forecastRemaining'] as num).toInt(),
  reportRemaining: (json['reportRemaining'] as num).toInt(),
  insightRemaining: (json['insightRemaining'] as num).toInt(),
);

Map<String, dynamic> _$MlUsageInfoToJson(MlUsageInfo instance) =>
    <String, dynamic>{
      'forecastCount': instance.forecastCount,
      'reportCount': instance.reportCount,
      'insightCount': instance.insightCount,
      'limits': instance.limits.toJson(),
      'forecastRemaining': instance.forecastRemaining,
      'reportRemaining': instance.reportRemaining,
      'insightRemaining': instance.insightRemaining,
    };
