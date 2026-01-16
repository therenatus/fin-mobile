import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/models/analytics.dart';

void main() {
  group('DashboardStats', () {
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'totalOrders': 100,
          'activeOrders': 25,
          'completedOrders': 60,
          'pendingOrders': 10,
          'cancelledOrders': 5,
          'overdueOrders': 3,
          'totalRevenue': 500000.0,
          'periodRevenue': 120000.0,
          'avgOrderValue': 5000.0,
          'totalClients': 50,
          'newClients': 8,
        };

        final stats = DashboardStats.fromJson(json);

        expect(stats.totalOrders, equals(100));
        expect(stats.activeOrders, equals(25));
        expect(stats.completedOrders, equals(60));
        expect(stats.pendingOrders, equals(10));
        expect(stats.cancelledOrders, equals(5));
        expect(stats.overdueOrders, equals(3));
        expect(stats.totalRevenue, equals(500000.0));
        expect(stats.periodRevenue, equals(120000.0));
        expect(stats.avgOrderValue, equals(5000.0));
        expect(stats.totalClients, equals(50));
        expect(stats.newClients, equals(8));
      });

      test('handles null values with defaults', () {
        final json = <String, dynamic>{};

        final stats = DashboardStats.fromJson(json);

        expect(stats.totalOrders, equals(0));
        expect(stats.activeOrders, equals(0));
        expect(stats.completedOrders, equals(0));
        expect(stats.pendingOrders, equals(0));
        expect(stats.cancelledOrders, equals(0));
        expect(stats.overdueOrders, equals(0));
        expect(stats.totalRevenue, equals(0));
        expect(stats.periodRevenue, equals(0));
        expect(stats.avgOrderValue, equals(0));
        expect(stats.totalClients, equals(0));
        expect(stats.newClients, equals(0));
      });
    });

    group('backward compatibility getters', () {
      test('monthlyRevenue returns periodRevenue', () {
        final stats = DashboardStats(
          totalOrders: 10,
          activeOrders: 2,
          completedOrders: 5,
          pendingOrders: 2,
          overdueOrders: 1,
          totalRevenue: 100000,
          periodRevenue: 25000,
          avgOrderValue: 10000,
          totalClients: 20,
          newClients: 3,
        );

        expect(stats.monthlyRevenue, equals(25000));
      });

      test('newClientsThisMonth returns newClients', () {
        final stats = DashboardStats(
          totalOrders: 10,
          activeOrders: 2,
          completedOrders: 5,
          pendingOrders: 2,
          overdueOrders: 1,
          totalRevenue: 100000,
          periodRevenue: 25000,
          avgOrderValue: 10000,
          totalClients: 20,
          newClients: 5,
        );

        expect(stats.newClientsThisMonth, equals(5));
      });

      test('revenueChange returns 0', () {
        final stats = DashboardStats(
          totalOrders: 10,
          activeOrders: 2,
          completedOrders: 5,
          pendingOrders: 2,
          overdueOrders: 1,
          totalRevenue: 100000,
          periodRevenue: 25000,
          avgOrderValue: 10000,
          totalClients: 20,
          newClients: 3,
        );

        expect(stats.revenueChange, equals(0));
      });

      test('inProgressOrders returns activeOrders', () {
        final stats = DashboardStats(
          totalOrders: 10,
          activeOrders: 4,
          completedOrders: 5,
          pendingOrders: 0,
          overdueOrders: 1,
          totalRevenue: 100000,
          periodRevenue: 25000,
          avgOrderValue: 10000,
          totalClients: 20,
          newClients: 3,
        );

        expect(stats.inProgressOrders, equals(4));
      });

      test('completionRate calculates correctly', () {
        final stats = DashboardStats(
          totalOrders: 100,
          activeOrders: 20,
          completedOrders: 50,
          pendingOrders: 20,
          overdueOrders: 10,
          totalRevenue: 100000,
          periodRevenue: 25000,
          avgOrderValue: 10000,
          totalClients: 20,
          newClients: 3,
        );

        expect(stats.completionRate, equals(50.0));
      });

      test('completionRate returns 0 when totalOrders is 0', () {
        final stats = DashboardStats(
          totalOrders: 0,
          activeOrders: 0,
          completedOrders: 0,
          pendingOrders: 0,
          overdueOrders: 0,
          totalRevenue: 0,
          periodRevenue: 0,
          avgOrderValue: 0,
          totalClients: 0,
          newClients: 0,
        );

        expect(stats.completionRate, equals(0));
      });
    });
  });

  group('AnalyticsDashboard', () {
    test('parses complete JSON correctly', () {
      final json = {
        'summary': {
          'totalOrders': 100,
          'activeOrders': 20,
          'completedOrders': 70,
          'pendingOrders': 5,
          'overdueOrders': 5,
          'totalRevenue': 500000.0,
          'periodRevenue': 100000.0,
          'avgOrderValue': 5000.0,
          'totalClients': 50,
          'newClients': 10,
        },
        'charts': {
          'revenueByDay': [
            {'date': '2024-01-15', 'amount': 10000.0},
          ],
          'ordersByStatus': {
            'pending': 5,
            'in_progress': 20,
            'completed': 70,
            'cancelled': 5,
          },
        },
        'topClients': [
          {'id': 'c1', 'name': 'Клиент 1', 'ordersCount': 10, 'totalSpent': 50000.0},
        ],
      };

      final dashboard = AnalyticsDashboard.fromJson(json);

      expect(dashboard.summary.totalOrders, equals(100));
      expect(dashboard.charts.revenueByDay, hasLength(1));
      expect(dashboard.topClients, hasLength(1));
    });

    test('handles empty topClients', () {
      final json = <String, dynamic>{
        'summary': <String, dynamic>{
          'totalOrders': 0,
          'activeOrders': 0,
          'completedOrders': 0,
          'pendingOrders': 0,
          'overdueOrders': 0,
          'totalRevenue': 0,
          'periodRevenue': 0,
          'avgOrderValue': 0,
          'totalClients': 0,
          'newClients': 0,
        },
        'charts': <String, dynamic>{
          'revenueByDay': <dynamic>[],
          'ordersByStatus': <String, dynamic>{},
        },
      };

      final dashboard = AnalyticsDashboard.fromJson(json);

      expect(dashboard.topClients, isEmpty);
    });
  });

  group('AnalyticsCharts', () {
    test('parses complete JSON correctly', () {
      final json = {
        'revenueByDay': [
          {'date': '2024-01-15', 'amount': 10000.0},
          {'date': '2024-01-16', 'amount': 15000.0},
        ],
        'ordersByStatus': {
          'pending': 5,
          'in_progress': 10,
          'completed': 80,
          'cancelled': 5,
        },
      };

      final charts = AnalyticsCharts.fromJson(json);

      expect(charts.revenueByDay, hasLength(2));
      expect(charts.ordersByStatus.pending, equals(5));
    });

    test('handles null values', () {
      final json = <String, dynamic>{};

      final charts = AnalyticsCharts.fromJson(json);

      expect(charts.revenueByDay, isEmpty);
    });
  });

  group('RevenueDataPoint', () {
    test('parses JSON correctly', () {
      final json = {
        'date': '2024-01-15',
        'amount': 25000.0,
      };

      final dataPoint = RevenueDataPoint.fromJson(json);

      expect(dataPoint.date, equals('2024-01-15'));
      expect(dataPoint.amount, equals(25000.0));
    });

    test('handles null amount with default', () {
      final json = {
        'date': '2024-01-15',
      };

      final dataPoint = RevenueDataPoint.fromJson(json);

      expect(dataPoint.amount, equals(0));
    });
  });

  group('OrdersByStatus', () {
    test('parses JSON correctly', () {
      final json = {
        'pending': 10,
        'in_progress': 20,
        'completed': 60,
        'cancelled': 10,
      };

      final ordersByStatus = OrdersByStatus.fromJson(json);

      expect(ordersByStatus.pending, equals(10));
      expect(ordersByStatus.inProgress, equals(20));
      expect(ordersByStatus.completed, equals(60));
      expect(ordersByStatus.cancelled, equals(10));
    });

    test('handles null values with defaults', () {
      final json = <String, dynamic>{};

      final ordersByStatus = OrdersByStatus.fromJson(json);

      expect(ordersByStatus.pending, equals(0));
      expect(ordersByStatus.inProgress, equals(0));
      expect(ordersByStatus.completed, equals(0));
      expect(ordersByStatus.cancelled, equals(0));
    });

    test('total calculates sum of all statuses', () {
      final ordersByStatus = OrdersByStatus(
        pending: 10,
        inProgress: 20,
        completed: 60,
        cancelled: 10,
      );

      expect(ordersByStatus.total, equals(100));
    });

    group('getPercentage', () {
      final ordersByStatus = OrdersByStatus(
        pending: 10,
        inProgress: 20,
        completed: 60,
        cancelled: 10,
      );

      test('returns correct percentage for pending', () {
        expect(ordersByStatus.getPercentage('pending'), equals(10.0));
      });

      test('returns correct percentage for in_progress', () {
        expect(ordersByStatus.getPercentage('in_progress'), equals(20.0));
      });

      test('returns correct percentage for completed', () {
        expect(ordersByStatus.getPercentage('completed'), equals(60.0));
      });

      test('returns correct percentage for cancelled', () {
        expect(ordersByStatus.getPercentage('cancelled'), equals(10.0));
      });

      test('returns 0 for unknown status', () {
        expect(ordersByStatus.getPercentage('unknown'), equals(0));
      });

      test('returns 0 when total is 0', () {
        final emptyStatus = OrdersByStatus(
          pending: 0,
          inProgress: 0,
          completed: 0,
          cancelled: 0,
        );

        expect(emptyStatus.getPercentage('pending'), equals(0));
      });
    });
  });

  group('TopClient', () {
    test('parses JSON correctly', () {
      final json = {
        'id': 'client-1',
        'name': 'Анна Иванова',
        'ordersCount': 15,
        'totalSpent': 75000.0,
      };

      final topClient = TopClient.fromJson(json);

      expect(topClient.id, equals('client-1'));
      expect(topClient.name, equals('Анна Иванова'));
      expect(topClient.ordersCount, equals(15));
      expect(topClient.totalSpent, equals(75000.0));
    });

    test('handles null values with defaults', () {
      final json = {
        'id': 'client-1',
        'name': 'Тест',
      };

      final topClient = TopClient.fromJson(json);

      expect(topClient.ordersCount, equals(0));
      expect(topClient.totalSpent, equals(0));
    });
  });

  group('ChartDataPoint', () {
    test('parses JSON correctly', () {
      final json = {
        'label': 'Январь',
        'value': 50000.0,
        'date': '2024-01-01T00:00:00.000Z',
      };

      final dataPoint = ChartDataPoint.fromJson(json);

      expect(dataPoint.label, equals('Январь'));
      expect(dataPoint.value, equals(50000.0));
      expect(dataPoint.date, isA<DateTime>());
    });

    test('handles null date', () {
      final json = {
        'label': 'Февраль',
        'value': 60000.0,
      };

      final dataPoint = ChartDataPoint.fromJson(json);

      expect(dataPoint.date, isNull);
    });
  });

  group('RevenueData', () {
    test('parses complete JSON correctly', () {
      final json = {
        'daily': [
          {'label': 'Пн', 'value': 10000.0},
          {'label': 'Вт', 'value': 15000.0},
        ],
        'weekly': [
          {'label': 'Неделя 1', 'value': 70000.0},
        ],
        'monthly': [
          {'label': 'Янв', 'value': 300000.0},
        ],
      };

      final revenueData = RevenueData.fromJson(json);

      expect(revenueData.daily, hasLength(2));
      expect(revenueData.weekly, hasLength(1));
      expect(revenueData.monthly, hasLength(1));
    });

    test('handles null values', () {
      final json = <String, dynamic>{};

      final revenueData = RevenueData.fromJson(json);

      expect(revenueData.daily, isEmpty);
      expect(revenueData.weekly, isEmpty);
      expect(revenueData.monthly, isEmpty);
    });
  });
}
