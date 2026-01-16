import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/models/forecast.dart';

void main() {
  group('ConfidenceInterval', () {
    test('parses JSON correctly', () {
      final json = {'low': 10000.0, 'high': 15000.0};

      final interval = ConfidenceInterval.fromJson(json);

      expect(interval.low, equals(10000.0));
      expect(interval.high, equals(15000.0));
    });

    test('serializes to JSON correctly', () {
      final interval = ConfidenceInterval(low: 5000.0, high: 8000.0);

      final json = interval.toJson();

      expect(json['low'], equals(5000.0));
      expect(json['high'], equals(8000.0));
    });
  });

  group('Forecast', () {
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'type': 'revenue',
          'periodStart': '2024-01-01T00:00:00.000Z',
          'periodEnd': '2024-01-31T23:59:59.000Z',
          'predictedValue': 150000.0,
          'confidenceInterval': {'low': 120000.0, 'high': 180000.0},
          'trend': 'up',
          'trendPercentage': 15.5,
          'insights': ['Рост продаж', 'Новые клиенты'],
        };

        final forecast = Forecast.fromJson(json);

        expect(forecast.type, equals('revenue'));
        expect(forecast.periodStart, isA<DateTime>());
        expect(forecast.periodEnd, isA<DateTime>());
        expect(forecast.predictedValue, equals(150000.0));
        expect(forecast.confidenceInterval.low, equals(120000.0));
        expect(forecast.confidenceInterval.high, equals(180000.0));
        expect(forecast.trend, equals('up'));
        expect(forecast.trendPercentage, equals(15.5));
        expect(forecast.insights, hasLength(2));
      });

      test('handles null insights', () {
        final json = {
          'type': 'orders',
          'periodStart': '2024-01-01T00:00:00.000Z',
          'periodEnd': '2024-01-31T23:59:59.000Z',
          'predictedValue': 50.0,
          'confidenceInterval': {'low': 40.0, 'high': 60.0},
          'trend': 'stable',
          'trendPercentage': 0.0,
        };

        final forecast = Forecast.fromJson(json);

        expect(forecast.insights, isEmpty);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final forecast = Forecast(
          type: 'revenue',
          periodStart: DateTime(2024, 1, 1),
          periodEnd: DateTime(2024, 1, 31),
          predictedValue: 100000.0,
          confidenceInterval: ConfidenceInterval(low: 80000.0, high: 120000.0),
          trend: 'up',
          trendPercentage: 10.0,
          insights: ['Insight 1'],
        );

        final json = forecast.toJson();

        expect(json['type'], equals('revenue'));
        expect(json['predictedValue'], equals(100000.0));
        expect(json['trend'], equals('up'));
        expect(json['trendPercentage'], equals(10.0));
        expect(json['confidenceInterval'], isA<Map>());
        expect(json['insights'], hasLength(1));
      });
    });

    group('trend properties', () {
      test('isUpTrend returns true for up trend', () {
        final forecast = Forecast(
          type: 'revenue',
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          predictedValue: 100.0,
          confidenceInterval: ConfidenceInterval(low: 80.0, high: 120.0),
          trend: 'up',
          trendPercentage: 10.0,
          insights: [],
        );

        expect(forecast.isUpTrend, isTrue);
        expect(forecast.isDownTrend, isFalse);
        expect(forecast.isStable, isFalse);
      });

      test('isDownTrend returns true for down trend', () {
        final forecast = Forecast(
          type: 'revenue',
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          predictedValue: 100.0,
          confidenceInterval: ConfidenceInterval(low: 80.0, high: 120.0),
          trend: 'down',
          trendPercentage: -10.0,
          insights: [],
        );

        expect(forecast.isUpTrend, isFalse);
        expect(forecast.isDownTrend, isTrue);
        expect(forecast.isStable, isFalse);
      });

      test('isStable returns true for stable trend', () {
        final forecast = Forecast(
          type: 'revenue',
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          predictedValue: 100.0,
          confidenceInterval: ConfidenceInterval(low: 80.0, high: 120.0),
          trend: 'stable',
          trendPercentage: 0.0,
          insights: [],
        );

        expect(forecast.isUpTrend, isFalse);
        expect(forecast.isDownTrend, isFalse);
        expect(forecast.isStable, isTrue);
      });
    });
  });

  group('MlReport', () {
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'id': 'report-1',
          'type': 'monthly_summary',
          'content': 'Отчёт за январь...',
          'periodStart': '2024-01-01T00:00:00.000Z',
          'periodEnd': '2024-01-31T23:59:59.000Z',
          'createdAt': '2024-02-01T10:00:00.000Z',
        };

        final report = MlReport.fromJson(json);

        expect(report.id, equals('report-1'));
        expect(report.type, equals('monthly_summary'));
        expect(report.content, equals('Отчёт за январь...'));
        expect(report.periodStart, isNotNull);
        expect(report.periodEnd, isNotNull);
        expect(report.createdAt, isA<DateTime>());
      });

      test('handles null period dates', () {
        final json = {
          'id': 'report-1',
          'type': 'client_insights',
          'content': 'Аналитика клиентов...',
          'createdAt': '2024-02-01T10:00:00.000Z',
        };

        final report = MlReport.fromJson(json);

        expect(report.periodStart, isNull);
        expect(report.periodEnd, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final report = MlReport(
          id: 'report-1',
          type: 'monthly_summary',
          content: 'Content',
          periodStart: DateTime(2024, 1, 1),
          periodEnd: DateTime(2024, 1, 31),
          createdAt: DateTime(2024, 2, 1),
        );

        final json = report.toJson();

        expect(json['id'], equals('report-1'));
        expect(json['type'], equals('monthly_summary'));
        expect(json['content'], equals('Content'));
        expect(json['periodStart'], contains('2024-01-01'));
        expect(json['periodEnd'], contains('2024-01-31'));
      });
    });

    group('typeLabel', () {
      test('returns correct label for each type', () {
        expect(
          MlReport(
            id: 'r1',
            type: 'monthly_summary',
            content: '',
            createdAt: DateTime.now(),
          ).typeLabel,
          equals('Месячный обзор'),
        );

        expect(
          MlReport(
            id: 'r1',
            type: 'order_analysis',
            content: '',
            createdAt: DateTime.now(),
          ).typeLabel,
          equals('Анализ заказов'),
        );

        expect(
          MlReport(
            id: 'r1',
            type: 'client_insights',
            content: '',
            createdAt: DateTime.now(),
          ).typeLabel,
          equals('Заказчикская аналитика'),
        );

        expect(
          MlReport(
            id: 'r1',
            type: 'revenue_forecast',
            content: '',
            createdAt: DateTime.now(),
          ).typeLabel,
          equals('Прогноз выручки'),
        );

        expect(
          MlReport(
            id: 'r1',
            type: 'efficiency_report',
            content: '',
            createdAt: DateTime.now(),
          ).typeLabel,
          equals('Отчёт эффективности'),
        );

        expect(
          MlReport(
            id: 'r1',
            type: 'unknown_type',
            content: '',
            createdAt: DateTime.now(),
          ).typeLabel,
          equals('unknown_type'),
        );
      });
    });
  });

  group('BusinessInsights', () {
    test('parses JSON correctly', () {
      final json = {
        'insights': ['Insight 1', 'Insight 2'],
        'metrics': {
          'recentOrders': 10,
          'overdueOrders': 2,
          'revenueChange': 15.5,
          'topCategory': 'Пошив',
        },
      };

      final insights = BusinessInsights.fromJson(json);

      expect(insights.insights, hasLength(2));
      expect(insights.metrics.recentOrders, equals(10));
      expect(insights.metrics.overdueOrders, equals(2));
      expect(insights.metrics.revenueChange, equals(15.5));
      expect(insights.metrics.topCategory, equals('Пошив'));
    });
  });

  group('InsightMetrics', () {
    test('parses JSON correctly', () {
      final json = {
        'recentOrders': 25,
        'overdueOrders': 3,
        'revenueChange': -5.0,
        'topCategory': 'Ремонт',
      };

      final metrics = InsightMetrics.fromJson(json);

      expect(metrics.recentOrders, equals(25));
      expect(metrics.overdueOrders, equals(3));
      expect(metrics.revenueChange, equals(-5.0));
      expect(metrics.topCategory, equals('Ремонт'));
    });

    test('handles null topCategory', () {
      final json = {
        'recentOrders': 10,
        'overdueOrders': 0,
        'revenueChange': 0.0,
      };

      final metrics = InsightMetrics.fromJson(json);

      expect(metrics.topCategory, equals(''));
    });
  });

  group('MlLimits', () {
    test('parses JSON correctly', () {
      final json = {
        'forecastLimit': 10,
        'reportLimit': 5,
        'insightLimit': 20,
      };

      final limits = MlLimits.fromJson(json);

      expect(limits.forecastLimit, equals(10));
      expect(limits.reportLimit, equals(5));
      expect(limits.insightLimit, equals(20));
    });

    group('disabled checks', () {
      test('returns true when limit is -1', () {
        final limits = MlLimits(
          forecastLimit: -1,
          reportLimit: -1,
          insightLimit: -1,
        );

        expect(limits.forecastDisabled, isTrue);
        expect(limits.reportDisabled, isTrue);
        expect(limits.insightDisabled, isTrue);
      });

      test('returns false when limit is positive', () {
        final limits = MlLimits(
          forecastLimit: 10,
          reportLimit: 5,
          insightLimit: 20,
        );

        expect(limits.forecastDisabled, isFalse);
        expect(limits.reportDisabled, isFalse);
        expect(limits.insightDisabled, isFalse);
      });
    });

    group('unlimited checks', () {
      test('returns true when limit is 0', () {
        final limits = MlLimits(
          forecastLimit: 0,
          reportLimit: 0,
          insightLimit: 0,
        );

        expect(limits.forecastUnlimited, isTrue);
        expect(limits.reportUnlimited, isTrue);
        expect(limits.insightUnlimited, isTrue);
      });

      test('returns false when limit is positive', () {
        final limits = MlLimits(
          forecastLimit: 10,
          reportLimit: 5,
          insightLimit: 20,
        );

        expect(limits.forecastUnlimited, isFalse);
        expect(limits.reportUnlimited, isFalse);
        expect(limits.insightUnlimited, isFalse);
      });
    });
  });

  group('MlUsageInfo', () {
    test('parses JSON correctly', () {
      final json = {
        'forecastCount': 5,
        'reportCount': 2,
        'insightCount': 10,
        'limits': {
          'forecastLimit': 10,
          'reportLimit': 5,
          'insightLimit': 20,
        },
        'forecastRemaining': 5,
        'reportRemaining': 3,
        'insightRemaining': 10,
      };

      final usage = MlUsageInfo.fromJson(json);

      expect(usage.forecastCount, equals(5));
      expect(usage.reportCount, equals(2));
      expect(usage.insightCount, equals(10));
      expect(usage.forecastRemaining, equals(5));
      expect(usage.reportRemaining, equals(3));
      expect(usage.insightRemaining, equals(10));
    });

    group('usageText', () {
      test('returns Недоступно when disabled', () {
        final usage = MlUsageInfo(
          forecastCount: 0,
          reportCount: 0,
          insightCount: 0,
          limits: MlLimits(
            forecastLimit: -1,
            reportLimit: -1,
            insightLimit: -1,
          ),
          forecastRemaining: 0,
          reportRemaining: 0,
          insightRemaining: 0,
        );

        expect(usage.forecastUsageText, equals('Недоступно'));
        expect(usage.reportUsageText, equals('Недоступно'));
        expect(usage.insightUsageText, equals('Недоступно'));
      });

      test('returns count with безлимит when unlimited', () {
        final usage = MlUsageInfo(
          forecastCount: 5,
          reportCount: 3,
          insightCount: 10,
          limits: MlLimits(
            forecastLimit: 0,
            reportLimit: 0,
            insightLimit: 0,
          ),
          forecastRemaining: -1,
          reportRemaining: -1,
          insightRemaining: -1,
        );

        expect(usage.forecastUsageText, equals('5 (безлимит)'));
        expect(usage.reportUsageText, equals('3 (безлимит)'));
        expect(usage.insightUsageText, equals('10 (безлимит)'));
      });

      test('returns count / limit when limited', () {
        final usage = MlUsageInfo(
          forecastCount: 5,
          reportCount: 2,
          insightCount: 10,
          limits: MlLimits(
            forecastLimit: 10,
            reportLimit: 5,
            insightLimit: 20,
          ),
          forecastRemaining: 5,
          reportRemaining: 3,
          insightRemaining: 10,
        );

        expect(usage.forecastUsageText, equals('5 / 10'));
        expect(usage.reportUsageText, equals('2 / 5'));
        expect(usage.insightUsageText, equals('10 / 20'));
      });
    });
  });
}
