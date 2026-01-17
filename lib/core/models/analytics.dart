import 'package:json_annotation/json_annotation.dart';

part 'analytics.g.dart';

@JsonSerializable()
class DashboardStats {
  @JsonKey(defaultValue: 0)
  final int totalOrders;
  @JsonKey(defaultValue: 0)
  final int activeOrders;
  @JsonKey(defaultValue: 0)
  final int completedOrders;
  @JsonKey(defaultValue: 0)
  final int pendingOrders;
  @JsonKey(defaultValue: 0)
  final int cancelledOrders;
  @JsonKey(defaultValue: 0)
  final int overdueOrders;
  @JsonKey(defaultValue: 0.0)
  final double totalRevenue;
  @JsonKey(defaultValue: 0.0)
  final double periodRevenue;
  @JsonKey(defaultValue: 0.0)
  final double avgOrderValue;
  @JsonKey(defaultValue: 0)
  final int totalClients;
  @JsonKey(defaultValue: 0)
  final int newClients;

  DashboardStats({
    required this.totalOrders,
    required this.activeOrders,
    required this.completedOrders,
    required this.pendingOrders,
    this.cancelledOrders = 0,
    required this.overdueOrders,
    required this.totalRevenue,
    required this.periodRevenue,
    required this.avgOrderValue,
    required this.totalClients,
    required this.newClients,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardStatsToJson(this);

  // Backward compatibility
  double get monthlyRevenue => periodRevenue;
  int get newClientsThisMonth => newClients;
  double get revenueChange => 0; // TODO: calculate from API
  int get inProgressOrders => activeOrders;
  double get completionRate => totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0;
}

@JsonSerializable()
class AnalyticsDashboard {
  final DashboardStats summary;
  final AnalyticsCharts charts;
  @JsonKey(defaultValue: [])
  final List<TopClient> topClients;

  AnalyticsDashboard({
    required this.summary,
    required this.charts,
    required this.topClients,
  });

  factory AnalyticsDashboard.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsDashboardFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsDashboardToJson(this);
}

@JsonSerializable()
class AnalyticsCharts {
  @JsonKey(defaultValue: [])
  final List<RevenueDataPoint> revenueByDay;
  @JsonKey(fromJson: _ordersByStatusFromJson)
  final OrdersByStatus ordersByStatus;

  AnalyticsCharts({
    required this.revenueByDay,
    required this.ordersByStatus,
  });

  factory AnalyticsCharts.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsChartsFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsChartsToJson(this);

  static OrdersByStatus _ordersByStatusFromJson(Map<String, dynamic>? json) =>
      OrdersByStatus.fromJson(json ?? {});
}

@JsonSerializable()
class RevenueDataPoint {
  final String date;
  @JsonKey(defaultValue: 0.0)
  final double amount;

  RevenueDataPoint({required this.date, required this.amount});

  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) =>
      _$RevenueDataPointFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueDataPointToJson(this);
}

@JsonSerializable()
class OrdersByStatus {
  @JsonKey(defaultValue: 0)
  final int pending;
  @JsonKey(name: 'in_progress', defaultValue: 0)
  final int inProgress;
  @JsonKey(defaultValue: 0)
  final int completed;
  @JsonKey(defaultValue: 0)
  final int cancelled;

  OrdersByStatus({
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.cancelled,
  });

  factory OrdersByStatus.fromJson(Map<String, dynamic> json) =>
      _$OrdersByStatusFromJson(json);

  Map<String, dynamic> toJson() => _$OrdersByStatusToJson(this);

  int get total => pending + inProgress + completed + cancelled;

  double getPercentage(String status) {
    if (total == 0) return 0;
    switch (status) {
      case 'pending':
        return (pending / total) * 100;
      case 'in_progress':
        return (inProgress / total) * 100;
      case 'completed':
        return (completed / total) * 100;
      case 'cancelled':
        return (cancelled / total) * 100;
      default:
        return 0;
    }
  }
}

@JsonSerializable()
class TopClient {
  final String id;
  final String name;
  @JsonKey(defaultValue: 0)
  final int ordersCount;
  @JsonKey(defaultValue: 0.0)
  final double totalSpent;

  TopClient({
    required this.id,
    required this.name,
    required this.ordersCount,
    required this.totalSpent,
  });

  factory TopClient.fromJson(Map<String, dynamic> json) =>
      _$TopClientFromJson(json);

  Map<String, dynamic> toJson() => _$TopClientToJson(this);
}

// Legacy classes for backward compatibility
@JsonSerializable()
class ChartDataPoint {
  final String label;
  final double value;
  final DateTime? date;

  ChartDataPoint({
    required this.label,
    required this.value,
    this.date,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) =>
      _$ChartDataPointFromJson(json);

  Map<String, dynamic> toJson() => _$ChartDataPointToJson(this);
}

@JsonSerializable()
class RevenueData {
  @JsonKey(defaultValue: [])
  final List<ChartDataPoint> daily;
  @JsonKey(defaultValue: [])
  final List<ChartDataPoint> weekly;
  @JsonKey(defaultValue: [])
  final List<ChartDataPoint> monthly;

  RevenueData({
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) =>
      _$RevenueDataFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueDataToJson(this);
}
