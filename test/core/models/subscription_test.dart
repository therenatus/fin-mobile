import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/models/subscription.dart';

void main() {
  group('SubscriptionPlan', () {
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'id': 'plan-1',
          'name': 'Pro',
          'description': 'Профессиональный план',
          'price': 990.0,
          'billingCycle': 'monthly',
          'clientLimit': 100,
          'employeeLimit': 20,
          'googlePlayProductId': 'com.app.pro',
          'appStoreProductId': 'pro_monthly',
          'features': ['Аналитика', 'ML-прогнозы', 'API'],
        };

        final plan = SubscriptionPlan.fromJson(json);

        expect(plan.id, equals('plan-1'));
        expect(plan.name, equals('Pro'));
        expect(plan.description, equals('Профессиональный план'));
        expect(plan.price, equals(990.0));
        expect(plan.billingCycle, equals('monthly'));
        expect(plan.clientLimit, equals(100));
        expect(plan.employeeLimit, equals(20));
        expect(plan.googlePlayProductId, equals('com.app.pro'));
        expect(plan.appStoreProductId, equals('pro_monthly'));
        expect(plan.features, hasLength(3));
      });

      test('handles null values with defaults', () {
        final json = <String, dynamic>{};

        final plan = SubscriptionPlan.fromJson(json);

        expect(plan.id, equals(''));
        expect(plan.name, equals(''));
        expect(plan.description, isNull);
        expect(plan.price, equals(0.0));
        expect(plan.billingCycle, equals('monthly'));
        expect(plan.clientLimit, equals(1));
        expect(plan.employeeLimit, equals(10));
        expect(plan.features, isEmpty);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final plan = SubscriptionPlan(
          id: 'plan-1',
          name: 'Pro',
          description: 'Description',
          price: 990.0,
          billingCycle: 'monthly',
          clientLimit: 100,
          employeeLimit: 20,
          googlePlayProductId: 'gp_id',
          appStoreProductId: 'as_id',
          features: ['Feature 1'],
        );

        final json = plan.toJson();

        expect(json['id'], equals('plan-1'));
        expect(json['name'], equals('Pro'));
        expect(json['price'], equals(990.0));
        expect(json['features'], hasLength(1));
      });
    });

    group('computed properties', () {
      test('isUnlimitedClients returns true when limit is 0', () {
        final plan = SubscriptionPlan(
          id: 'p1',
          name: 'Unlimited',
          price: 0,
          billingCycle: 'monthly',
          clientLimit: 0,
          employeeLimit: 10,
          features: [],
        );

        expect(plan.isUnlimitedClients, isTrue);
        expect(plan.isUnlimitedEmployees, isFalse);
      });

      test('isUnlimitedEmployees returns true when limit is 0', () {
        final plan = SubscriptionPlan(
          id: 'p1',
          name: 'Unlimited',
          price: 0,
          billingCycle: 'monthly',
          clientLimit: 10,
          employeeLimit: 0,
          features: [],
        );

        expect(plan.isUnlimitedClients, isFalse);
        expect(plan.isUnlimitedEmployees, isTrue);
      });

      test('clientLimitText returns Неограничено when unlimited', () {
        final plan = SubscriptionPlan(
          id: 'p1',
          name: 'Test',
          price: 0,
          billingCycle: 'monthly',
          clientLimit: 0,
          employeeLimit: 0,
          features: [],
        );

        expect(plan.clientLimitText, equals('Неограничено'));
        expect(plan.employeeLimitText, equals('Неограничено'));
      });

      test('limitText returns number when limited', () {
        final plan = SubscriptionPlan(
          id: 'p1',
          name: 'Test',
          price: 0,
          billingCycle: 'monthly',
          clientLimit: 50,
          employeeLimit: 10,
          features: [],
        );

        expect(plan.clientLimitText, equals('50'));
        expect(plan.employeeLimitText, equals('10'));
      });
    });
  });

  group('SubscriptionLimits', () {
    test('parses JSON correctly', () {
      final json = {
        'clientLimit': 100,
        'employeeLimit': 20,
        'mlForecastLimit': 10,
        'mlReportLimit': 5,
        'mlInsightLimit': 20,
      };

      final limits = SubscriptionLimits.fromJson(json);

      expect(limits.clientLimit, equals(100));
      expect(limits.employeeLimit, equals(20));
      expect(limits.mlForecastLimit, equals(10));
      expect(limits.mlReportLimit, equals(5));
      expect(limits.mlInsightLimit, equals(20));
    });

    test('handles null values with defaults', () {
      final json = <String, dynamic>{};

      final limits = SubscriptionLimits.fromJson(json);

      expect(limits.clientLimit, equals(1));
      expect(limits.employeeLimit, equals(10));
      expect(limits.mlForecastLimit, equals(0));
      expect(limits.mlReportLimit, equals(0));
      expect(limits.mlInsightLimit, equals(0));
    });
  });

  group('ResourceUsage', () {
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'currentClients': 50,
          'currentEmployees': 10,
          'limits': {
            'clientLimit': 100,
            'employeeLimit': 20,
            'mlForecastLimit': 10,
            'mlReportLimit': 5,
            'mlInsightLimit': 20,
          },
          'clientsRemaining': 50,
          'employeesRemaining': 10,
          'planName': 'Pro',
          'planId': 'plan-pro',
          'status': 'active',
          'expiresAt': '2024-12-31T23:59:59.000Z',
        };

        final usage = ResourceUsage.fromJson(json);

        expect(usage.currentClients, equals(50));
        expect(usage.currentEmployees, equals(10));
        expect(usage.clientsRemaining, equals(50));
        expect(usage.employeesRemaining, equals(10));
        expect(usage.planName, equals('Pro'));
        expect(usage.planId, equals('plan-pro'));
        expect(usage.status, equals('active'));
        expect(usage.expiresAt, isNotNull);
      });

      test('handles null values with defaults', () {
        final json = <String, dynamic>{};

        final usage = ResourceUsage.fromJson(json);

        expect(usage.currentClients, equals(0));
        expect(usage.currentEmployees, equals(0));
        expect(usage.clientsRemaining, equals(-1));
        expect(usage.employeesRemaining, equals(-1));
        expect(usage.planName, equals('Free'));
        expect(usage.status, equals('free'));
        expect(usage.expiresAt, isNull);
      });
    });

    group('computed properties', () {
      test('isClientLimitReached returns true when at limit', () {
        final usage = ResourceUsage(
          currentClients: 100,
          currentEmployees: 5,
          limits: SubscriptionLimits(
            clientLimit: 100,
            employeeLimit: 20,
            mlForecastLimit: 0,
            mlReportLimit: 0,
            mlInsightLimit: 0,
          ),
          clientsRemaining: 0,
          employeesRemaining: 15,
          planName: 'Pro',
          status: 'active',
        );

        expect(usage.isClientLimitReached, isTrue);
        expect(usage.isEmployeeLimitReached, isFalse);
      });

      test('isNearClientLimit returns true when 2 or less remaining', () {
        final usage = ResourceUsage(
          currentClients: 98,
          currentEmployees: 5,
          limits: SubscriptionLimits(
            clientLimit: 100,
            employeeLimit: 20,
            mlForecastLimit: 0,
            mlReportLimit: 0,
            mlInsightLimit: 0,
          ),
          clientsRemaining: 2,
          employeesRemaining: 15,
          planName: 'Pro',
          status: 'active',
        );

        expect(usage.isNearClientLimit, isTrue);
      });

      test('isNearEmployeeLimit returns true when 5 or less remaining', () {
        final usage = ResourceUsage(
          currentClients: 50,
          currentEmployees: 15,
          limits: SubscriptionLimits(
            clientLimit: 100,
            employeeLimit: 20,
            mlForecastLimit: 0,
            mlReportLimit: 0,
            mlInsightLimit: 0,
          ),
          clientsRemaining: 50,
          employeesRemaining: 5,
          planName: 'Pro',
          status: 'active',
        );

        expect(usage.isNearEmployeeLimit, isTrue);
      });

      test('isActive returns true for active status', () {
        final usage = ResourceUsage(
          currentClients: 0,
          currentEmployees: 0,
          limits: SubscriptionLimits(
            clientLimit: 10,
            employeeLimit: 10,
            mlForecastLimit: 0,
            mlReportLimit: 0,
            mlInsightLimit: 0,
          ),
          clientsRemaining: 10,
          employeesRemaining: 10,
          planName: 'Pro',
          status: 'active',
        );

        expect(usage.isActive, isTrue);
        expect(usage.isTrial, isFalse);
      });

      test('isTrial returns true for trial status', () {
        final usage = ResourceUsage(
          currentClients: 0,
          currentEmployees: 0,
          limits: SubscriptionLimits(
            clientLimit: 10,
            employeeLimit: 10,
            mlForecastLimit: 0,
            mlReportLimit: 0,
            mlInsightLimit: 0,
          ),
          clientsRemaining: 10,
          employeesRemaining: 10,
          planName: 'Trial',
          status: 'trial',
        );

        expect(usage.isActive, isTrue);
        expect(usage.isTrial, isTrue);
      });

      test('isExpired returns true for past expiration', () {
        final usage = ResourceUsage(
          currentClients: 0,
          currentEmployees: 0,
          limits: SubscriptionLimits(
            clientLimit: 10,
            employeeLimit: 10,
            mlForecastLimit: 0,
            mlReportLimit: 0,
            mlInsightLimit: 0,
          ),
          clientsRemaining: 10,
          employeesRemaining: 10,
          planName: 'Expired',
          status: 'expired',
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        expect(usage.isExpired, isTrue);
      });

      test('statusText returns correct text', () {
        expect(
          ResourceUsage(
            currentClients: 0,
            currentEmployees: 0,
            limits: SubscriptionLimits(
              clientLimit: 10,
              employeeLimit: 10,
              mlForecastLimit: 0,
              mlReportLimit: 0,
              mlInsightLimit: 0,
            ),
            clientsRemaining: 10,
            employeesRemaining: 10,
            planName: 'Pro',
            status: 'active',
          ).statusText,
          equals('Активна'),
        );

        expect(
          ResourceUsage(
            currentClients: 0,
            currentEmployees: 0,
            limits: SubscriptionLimits(
              clientLimit: 10,
              employeeLimit: 10,
              mlForecastLimit: 0,
              mlReportLimit: 0,
              mlInsightLimit: 0,
            ),
            clientsRemaining: 10,
            employeesRemaining: 10,
            planName: 'Trial',
            status: 'trial',
          ).statusText,
          equals('Пробный период'),
        );

        expect(
          ResourceUsage(
            currentClients: 0,
            currentEmployees: 0,
            limits: SubscriptionLimits(
              clientLimit: 10,
              employeeLimit: 10,
              mlForecastLimit: 0,
              mlReportLimit: 0,
              mlInsightLimit: 0,
            ),
            clientsRemaining: 10,
            employeesRemaining: 10,
            planName: 'Cancelled',
            status: 'cancelled',
          ).statusText,
          equals('Отменена'),
        );

        expect(
          ResourceUsage(
            currentClients: 0,
            currentEmployees: 0,
            limits: SubscriptionLimits(
              clientLimit: 10,
              employeeLimit: 10,
              mlForecastLimit: 0,
              mlReportLimit: 0,
              mlInsightLimit: 0,
            ),
            clientsRemaining: 10,
            employeesRemaining: 10,
            planName: 'Past Due',
            status: 'past_due',
          ).statusText,
          equals('Просрочена'),
        );

        expect(
          ResourceUsage(
            currentClients: 0,
            currentEmployees: 0,
            limits: SubscriptionLimits(
              clientLimit: 10,
              employeeLimit: 10,
              mlForecastLimit: 0,
              mlReportLimit: 0,
              mlInsightLimit: 0,
            ),
            clientsRemaining: 10,
            employeesRemaining: 10,
            planName: 'Expired',
            status: 'expired',
          ).statusText,
          equals('Истекла'),
        );

        expect(
          ResourceUsage(
            currentClients: 0,
            currentEmployees: 0,
            limits: SubscriptionLimits(
              clientLimit: 10,
              employeeLimit: 10,
              mlForecastLimit: 0,
              mlReportLimit: 0,
              mlInsightLimit: 0,
            ),
            clientsRemaining: 10,
            employeesRemaining: 10,
            planName: 'Free',
            status: 'free',
          ).statusText,
          equals('Бесплатный план'),
        );
      });

      test('usagePercent calculates correctly', () {
        final usage = ResourceUsage(
          currentClients: 50,
          currentEmployees: 10,
          limits: SubscriptionLimits(
            clientLimit: 100,
            employeeLimit: 20,
            mlForecastLimit: 0,
            mlReportLimit: 0,
            mlInsightLimit: 0,
          ),
          clientsRemaining: 50,
          employeesRemaining: 10,
          planName: 'Pro',
          status: 'active',
        );

        expect(usage.clientUsagePercent, equals(0.5));
        expect(usage.employeeUsagePercent, equals(0.5));
      });

      test('usagePercent returns 0 when limit is 0', () {
        final usage = ResourceUsage(
          currentClients: 50,
          currentEmployees: 10,
          limits: SubscriptionLimits(
            clientLimit: 0,
            employeeLimit: 0,
            mlForecastLimit: 0,
            mlReportLimit: 0,
            mlInsightLimit: 0,
          ),
          clientsRemaining: -1,
          employeesRemaining: -1,
          planName: 'Unlimited',
          status: 'active',
        );

        expect(usage.clientUsagePercent, equals(0.0));
        expect(usage.employeeUsagePercent, equals(0.0));
      });
    });
  });

  group('Subscription', () {
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'id': 'sub-1',
          'tenantId': 'tenant-1',
          'planId': 'plan-pro',
          'plan': {
            'id': 'plan-pro',
            'name': 'Pro',
            'price': 990.0,
            'billingCycle': 'monthly',
            'clientLimit': 100,
            'employeeLimit': 20,
            'features': [],
          },
          'status': 'active',
          'startDate': '2024-01-01T00:00:00.000Z',
          'nextBillingDate': '2024-02-01T00:00:00.000Z',
          'trialEndDate': null,
          'expiresAt': null,
          'platform': 'google_play',
        };

        final subscription = Subscription.fromJson(json);

        expect(subscription.id, equals('sub-1'));
        expect(subscription.tenantId, equals('tenant-1'));
        expect(subscription.planId, equals('plan-pro'));
        expect(subscription.plan, isNotNull);
        expect(subscription.plan!.name, equals('Pro'));
        expect(subscription.status, equals('active'));
        expect(subscription.platform, equals('google_play'));
      });

      test('handles null values with defaults', () {
        final json = <String, dynamic>{};

        final subscription = Subscription.fromJson(json);

        expect(subscription.id, equals(''));
        expect(subscription.tenantId, equals(''));
        expect(subscription.planId, equals(''));
        expect(subscription.plan, isNull);
        expect(subscription.status, equals('free'));
        expect(subscription.startDate, isA<DateTime>());
        expect(subscription.nextBillingDate, isNull);
        expect(subscription.trialEndDate, isNull);
        expect(subscription.expiresAt, isNull);
        expect(subscription.platform, isNull);
      });
    });

    test('isActive returns true for active or trial status', () {
      expect(
        Subscription(
          id: 's1',
          tenantId: 't1',
          planId: 'p1',
          status: 'active',
          startDate: DateTime.now(),
        ).isActive,
        isTrue,
      );

      expect(
        Subscription(
          id: 's1',
          tenantId: 't1',
          planId: 'p1',
          status: 'trial',
          startDate: DateTime.now(),
        ).isActive,
        isTrue,
      );

      expect(
        Subscription(
          id: 's1',
          tenantId: 't1',
          planId: 'p1',
          status: 'cancelled',
          startDate: DateTime.now(),
        ).isActive,
        isFalse,
      );
    });
  });
}
