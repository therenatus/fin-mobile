// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
    DashboardStats(
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      activeOrders: (json['activeOrders'] as num?)?.toInt() ?? 0,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
      pendingOrders: (json['pendingOrders'] as num?)?.toInt() ?? 0,
      cancelledOrders: (json['cancelledOrders'] as num?)?.toInt() ?? 0,
      overdueOrders: (json['overdueOrders'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      periodRevenue: (json['periodRevenue'] as num?)?.toDouble() ?? 0.0,
      avgOrderValue: (json['avgOrderValue'] as num?)?.toDouble() ?? 0.0,
      totalClients: (json['totalClients'] as num?)?.toInt() ?? 0,
      newClients: (json['newClients'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DashboardStatsToJson(DashboardStats instance) =>
    <String, dynamic>{
      'totalOrders': instance.totalOrders,
      'activeOrders': instance.activeOrders,
      'completedOrders': instance.completedOrders,
      'pendingOrders': instance.pendingOrders,
      'cancelledOrders': instance.cancelledOrders,
      'overdueOrders': instance.overdueOrders,
      'totalRevenue': instance.totalRevenue,
      'periodRevenue': instance.periodRevenue,
      'avgOrderValue': instance.avgOrderValue,
      'totalClients': instance.totalClients,
      'newClients': instance.newClients,
    };

AnalyticsDashboard _$AnalyticsDashboardFromJson(Map<String, dynamic> json) =>
    AnalyticsDashboard(
      summary: DashboardStats.fromJson(json['summary'] as Map<String, dynamic>),
      charts: AnalyticsCharts.fromJson(json['charts'] as Map<String, dynamic>),
      topClients:
          (json['topClients'] as List<dynamic>?)
              ?.map((e) => TopClient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$AnalyticsDashboardToJson(AnalyticsDashboard instance) =>
    <String, dynamic>{
      'summary': instance.summary.toJson(),
      'charts': instance.charts.toJson(),
      'topClients': instance.topClients.map((e) => e.toJson()).toList(),
    };

AnalyticsCharts _$AnalyticsChartsFromJson(Map<String, dynamic> json) =>
    AnalyticsCharts(
      revenueByDay:
          (json['revenueByDay'] as List<dynamic>?)
              ?.map((e) => RevenueDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ordersByStatus: AnalyticsCharts._ordersByStatusFromJson(
        json['ordersByStatus'] as Map<String, dynamic>?,
      ),
    );

Map<String, dynamic> _$AnalyticsChartsToJson(AnalyticsCharts instance) =>
    <String, dynamic>{
      'revenueByDay': instance.revenueByDay.map((e) => e.toJson()).toList(),
      'ordersByStatus': instance.ordersByStatus.toJson(),
    };

RevenueDataPoint _$RevenueDataPointFromJson(Map<String, dynamic> json) =>
    RevenueDataPoint(
      date: json['date'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$RevenueDataPointToJson(RevenueDataPoint instance) =>
    <String, dynamic>{'date': instance.date, 'amount': instance.amount};

OrdersByStatus _$OrdersByStatusFromJson(Map<String, dynamic> json) =>
    OrdersByStatus(
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      inProgress: (json['in_progress'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      cancelled: (json['cancelled'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$OrdersByStatusToJson(OrdersByStatus instance) =>
    <String, dynamic>{
      'pending': instance.pending,
      'in_progress': instance.inProgress,
      'completed': instance.completed,
      'cancelled': instance.cancelled,
    };

TopClient _$TopClientFromJson(Map<String, dynamic> json) => TopClient(
  id: json['id'] as String,
  name: json['name'] as String,
  ordersCount: (json['ordersCount'] as num?)?.toInt() ?? 0,
  totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$TopClientToJson(TopClient instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'ordersCount': instance.ordersCount,
  'totalSpent': instance.totalSpent,
};

ChartDataPoint _$ChartDataPointFromJson(Map<String, dynamic> json) =>
    ChartDataPoint(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      date: json['date'] == null
          ? null
          : DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$ChartDataPointToJson(ChartDataPoint instance) =>
    <String, dynamic>{
      'label': instance.label,
      'value': instance.value,
      if (instance.date?.toIso8601String() case final value?) 'date': value,
    };

RevenueData _$RevenueDataFromJson(Map<String, dynamic> json) => RevenueData(
  daily:
      (json['daily'] as List<dynamic>?)
          ?.map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  weekly:
      (json['weekly'] as List<dynamic>?)
          ?.map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  monthly:
      (json['monthly'] as List<dynamic>?)
          ?.map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$RevenueDataToJson(RevenueData instance) =>
    <String, dynamic>{
      'daily': instance.daily.map((e) => e.toJson()).toList(),
      'weekly': instance.weekly.map((e) => e.toJson()).toList(),
      'monthly': instance.monthly.map((e) => e.toJson()).toList(),
    };
