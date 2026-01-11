class ConfidenceInterval {
  final double low;
  final double high;

  ConfidenceInterval({
    required this.low,
    required this.high,
  });

  factory ConfidenceInterval.fromJson(Map<String, dynamic> json) {
    return ConfidenceInterval(
      low: (json['low'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'low': low,
        'high': high,
      };
}

class Forecast {
  final String type;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double predictedValue;
  final ConfidenceInterval confidenceInterval;
  final String trend;
  final double trendPercentage;
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

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      type: json['type'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      predictedValue: (json['predictedValue'] as num).toDouble(),
      confidenceInterval: ConfidenceInterval.fromJson(
        json['confidenceInterval'] as Map<String, dynamic>,
      ),
      trend: json['trend'] as String,
      trendPercentage: (json['trendPercentage'] as num).toDouble(),
      insights: (json['insights'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'periodStart': periodStart.toIso8601String(),
        'periodEnd': periodEnd.toIso8601String(),
        'predictedValue': predictedValue,
        'confidenceInterval': confidenceInterval.toJson(),
        'trend': trend,
        'trendPercentage': trendPercentage,
        'insights': insights,
      };

  bool get isUpTrend => trend == 'up';
  bool get isDownTrend => trend == 'down';
  bool get isStable => trend == 'stable';
}

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

  factory MlReport.fromJson(Map<String, dynamic> json) {
    return MlReport(
      id: json['id'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      periodStart: json['periodStart'] != null
          ? DateTime.parse(json['periodStart'] as String)
          : null,
      periodEnd: json['periodEnd'] != null
          ? DateTime.parse(json['periodEnd'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'content': content,
        'periodStart': periodStart?.toIso8601String(),
        'periodEnd': periodEnd?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

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

class BusinessInsights {
  final List<String> insights;
  final InsightMetrics metrics;

  BusinessInsights({
    required this.insights,
    required this.metrics,
  });

  factory BusinessInsights.fromJson(Map<String, dynamic> json) {
    return BusinessInsights(
      insights: (json['insights'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metrics: InsightMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
    );
  }
}

class InsightMetrics {
  final int recentOrders;
  final int overdueOrders;
  final double revenueChange;
  final String topCategory;

  InsightMetrics({
    required this.recentOrders,
    required this.overdueOrders,
    required this.revenueChange,
    required this.topCategory,
  });

  factory InsightMetrics.fromJson(Map<String, dynamic> json) {
    return InsightMetrics(
      recentOrders: json['recentOrders'] as int,
      overdueOrders: json['overdueOrders'] as int,
      revenueChange: (json['revenueChange'] as num).toDouble(),
      topCategory: json['topCategory'] as String? ?? '',
    );
  }
}

class MlLimits {
  final int forecastLimit;
  final int reportLimit;
  final int insightLimit;

  MlLimits({
    required this.forecastLimit,
    required this.reportLimit,
    required this.insightLimit,
  });

  factory MlLimits.fromJson(Map<String, dynamic> json) {
    return MlLimits(
      forecastLimit: json['forecastLimit'] as int,
      reportLimit: json['reportLimit'] as int,
      insightLimit: json['insightLimit'] as int,
    );
  }

  bool get forecastDisabled => forecastLimit == -1;
  bool get reportDisabled => reportLimit == -1;
  bool get insightDisabled => insightLimit == -1;

  bool get forecastUnlimited => forecastLimit == 0;
  bool get reportUnlimited => reportLimit == 0;
  bool get insightUnlimited => insightLimit == 0;
}

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

  factory MlUsageInfo.fromJson(Map<String, dynamic> json) {
    return MlUsageInfo(
      forecastCount: json['forecastCount'] as int,
      reportCount: json['reportCount'] as int,
      insightCount: json['insightCount'] as int,
      limits: MlLimits.fromJson(json['limits'] as Map<String, dynamic>),
      forecastRemaining: json['forecastRemaining'] as int,
      reportRemaining: json['reportRemaining'] as int,
      insightRemaining: json['insightRemaining'] as int,
    );
  }

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
