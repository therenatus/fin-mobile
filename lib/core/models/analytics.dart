class DashboardStats {
  final int totalOrders;
  final int activeOrders;
  final int completedOrders;
  final int pendingOrders;
  final int cancelledOrders;
  final int overdueOrders;
  final double totalRevenue;
  final double periodRevenue;
  final double avgOrderValue;
  final int totalClients;
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

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalOrders: json['totalOrders'] as int? ?? 0,
      activeOrders: json['activeOrders'] as int? ?? 0,
      completedOrders: json['completedOrders'] as int? ?? 0,
      pendingOrders: json['pendingOrders'] as int? ?? 0,
      cancelledOrders: json['cancelledOrders'] as int? ?? 0,
      overdueOrders: json['overdueOrders'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      periodRevenue: (json['periodRevenue'] as num?)?.toDouble() ?? 0,
      avgOrderValue: (json['avgOrderValue'] as num?)?.toDouble() ?? 0,
      totalClients: json['totalClients'] as int? ?? 0,
      newClients: json['newClients'] as int? ?? 0,
    );
  }

  // Backward compatibility
  double get monthlyRevenue => periodRevenue;
  int get newClientsThisMonth => newClients;
  double get revenueChange => 0; // TODO: calculate from API
  int get inProgressOrders => activeOrders;
  double get completionRate => totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0;
}

class AnalyticsDashboard {
  final DashboardStats summary;
  final AnalyticsCharts charts;
  final List<TopClient> topClients;

  AnalyticsDashboard({
    required this.summary,
    required this.charts,
    required this.topClients,
  });

  factory AnalyticsDashboard.fromJson(Map<String, dynamic> json) {
    return AnalyticsDashboard(
      summary: DashboardStats.fromJson(json['summary'] as Map<String, dynamic>),
      charts: AnalyticsCharts.fromJson(json['charts'] as Map<String, dynamic>),
      topClients: (json['topClients'] as List<dynamic>?)
          ?.map((e) => TopClient.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class AnalyticsCharts {
  final List<RevenueDataPoint> revenueByDay;
  final OrdersByStatus ordersByStatus;

  AnalyticsCharts({
    required this.revenueByDay,
    required this.ordersByStatus,
  });

  factory AnalyticsCharts.fromJson(Map<String, dynamic> json) {
    return AnalyticsCharts(
      revenueByDay: (json['revenueByDay'] as List<dynamic>?)
          ?.map((e) => RevenueDataPoint.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      ordersByStatus: OrdersByStatus.fromJson(
        json['ordersByStatus'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class RevenueDataPoint {
  final String date;
  final double amount;

  RevenueDataPoint({required this.date, required this.amount});

  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) {
    return RevenueDataPoint(
      date: json['date'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
    );
  }
}

class OrdersByStatus {
  final int pending;
  final int inProgress;
  final int completed;
  final int cancelled;

  OrdersByStatus({
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.cancelled,
  });

  factory OrdersByStatus.fromJson(Map<String, dynamic> json) {
    return OrdersByStatus(
      pending: json['pending'] as int? ?? 0,
      inProgress: json['in_progress'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      cancelled: json['cancelled'] as int? ?? 0,
    );
  }

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

class TopClient {
  final String id;
  final String name;
  final int ordersCount;
  final double totalSpent;

  TopClient({
    required this.id,
    required this.name,
    required this.ordersCount,
    required this.totalSpent,
  });

  factory TopClient.fromJson(Map<String, dynamic> json) {
    return TopClient(
      id: json['id'] as String,
      name: json['name'] as String,
      ordersCount: json['ordersCount'] as int? ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0,
    );
  }
}

// Legacy classes for backward compatibility
class ChartDataPoint {
  final String label;
  final double value;
  final DateTime? date;

  ChartDataPoint({
    required this.label,
    required this.value,
    this.date,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
    );
  }
}

class RevenueData {
  final List<ChartDataPoint> daily;
  final List<ChartDataPoint> weekly;
  final List<ChartDataPoint> monthly;

  RevenueData({
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      daily: (json['daily'] as List<dynamic>?)
          ?.map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      weekly: (json['weekly'] as List<dynamic>?)
          ?.map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      monthly: (json['monthly'] as List<dynamic>?)
          ?.map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}
