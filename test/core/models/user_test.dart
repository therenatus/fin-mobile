import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/models/user.dart';

void main() {
  group('Plan', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'plan-1',
        'name': 'Pro',
        'price': 99.99,
      };

      final plan = Plan.fromJson(json);

      expect(plan.id, equals('plan-1'));
      expect(plan.name, equals('Pro'));
      expect(plan.price, equals(99.99));
    });

    test('fromJson handles null price as 0', () {
      final json = {
        'id': 'plan-1',
        'name': 'Free',
        'price': null,
      };

      final plan = Plan.fromJson(json);

      expect(plan.price, equals(0));
    });

    test('fromJson handles int price', () {
      final json = {
        'id': 'plan-1',
        'name': 'Basic',
        'price': 50,
      };

      final plan = Plan.fromJson(json);

      expect(plan.price, equals(50.0));
    });
  });

  group('Tenant', () {
    test('fromJson parses correctly with plan', () {
      final json = {
        'id': 'tenant-1',
        'name': 'Test Atelier',
        'plan': {
          'id': 'plan-1',
          'name': 'Pro',
          'price': 99.99,
        },
      };

      final tenant = Tenant.fromJson(json);

      expect(tenant.id, equals('tenant-1'));
      expect(tenant.name, equals('Test Atelier'));
      expect(tenant.plan, isNotNull);
      expect(tenant.plan!.name, equals('Pro'));
    });

    test('fromJson handles null plan', () {
      final json = {
        'id': 'tenant-1',
        'name': 'Test Atelier',
        'plan': null,
      };

      final tenant = Tenant.fromJson(json);

      expect(tenant.plan, isNull);
    });

    test('fromJson handles missing plan field', () {
      final json = {
        'id': 'tenant-1',
        'name': 'Test Atelier',
      };

      final tenant = Tenant.fromJson(json);

      expect(tenant.plan, isNull);
    });
  });

  group('User', () {
    test('fromJson parses complete JSON correctly', () {
      final json = {
        'id': 'user-1',
        'email': 'test@example.com',
        'name': 'Test User',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'tenantId': 'tenant-1',
        'tenant': {
          'id': 'tenant-1',
          'name': 'Test Atelier',
        },
        'roles': ['manager', 'admin'],
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-02T00:00:00Z',
      };

      final user = User.fromJson(json);

      expect(user.id, equals('user-1'));
      expect(user.email, equals('test@example.com'));
      expect(user.name, equals('Test User'));
      expect(user.avatarUrl, equals('https://example.com/avatar.jpg'));
      expect(user.tenantId, equals('tenant-1'));
      expect(user.tenant, isNotNull);
      expect(user.tenant!.name, equals('Test Atelier'));
      expect(user.roles, equals(['manager', 'admin']));
      expect(user.createdAt, isNotNull);
      expect(user.updatedAt, isNotNull);
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'user-1',
        'email': 'test@example.com',
        'tenantId': 'tenant-1',
        'roles': ['manager'],
      };

      final user = User.fromJson(json);

      expect(user.name, isNull);
      expect(user.avatarUrl, isNull);
      expect(user.tenant, isNull);
      expect(user.createdAt, isNull);
      expect(user.updatedAt, isNull);
    });

    test('fromJson handles empty roles', () {
      final json = {
        'id': 'user-1',
        'email': 'test@example.com',
        'tenantId': 'tenant-1',
        'roles': null,
      };

      final user = User.fromJson(json);

      expect(user.roles, isEmpty);
    });

    group('toJson', () {
      test('serializes all fields', () {
        final user = User(
          id: 'user-1',
          email: 'test@example.com',
          name: 'Test User',
          avatarUrl: 'https://example.com/avatar.jpg',
          tenantId: 'tenant-1',
          roles: ['manager'],
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
          updatedAt: DateTime.parse('2024-01-02T00:00:00Z'),
        );

        final json = user.toJson();

        expect(json['id'], equals('user-1'));
        expect(json['email'], equals('test@example.com'));
        expect(json['name'], equals('Test User'));
        expect(json['avatarUrl'], equals('https://example.com/avatar.jpg'));
        expect(json['tenantId'], equals('tenant-1'));
        expect(json['roles'], equals(['manager']));
        expect(json['createdAt'], isNotNull);
        expect(json['updatedAt'], isNotNull);
      });

      test('handles null dates', () {
        final user = User(
          id: 'user-1',
          email: 'test@example.com',
          tenantId: 'tenant-1',
          roles: [],
        );

        final json = user.toJson();

        expect(json['createdAt'], isNull);
        expect(json['updatedAt'], isNull);
      });
    });

    group('role checks', () {
      test('isAdmin returns true for tenant-admin', () {
        final user = User(
          id: 'user-1',
          email: 'test@example.com',
          tenantId: 'tenant-1',
          roles: ['tenant-admin'],
        );

        expect(user.isAdmin, isTrue);
        expect(user.isManager, isFalse);
      });

      test('isAdmin returns true for admin', () {
        final user = User(
          id: 'user-1',
          email: 'test@example.com',
          tenantId: 'tenant-1',
          roles: ['admin'],
        );

        expect(user.isAdmin, isTrue);
      });

      test('isManager returns true for manager role', () {
        final user = User(
          id: 'user-1',
          email: 'test@example.com',
          tenantId: 'tenant-1',
          roles: ['manager'],
        );

        expect(user.isManager, isTrue);
        expect(user.isAdmin, isFalse);
      });

      test('canEditClients returns true only for admin', () {
        final admin = User(
          id: 'user-1',
          email: 'admin@example.com',
          tenantId: 'tenant-1',
          roles: ['tenant-admin'],
        );
        final manager = User(
          id: 'user-2',
          email: 'manager@example.com',
          tenantId: 'tenant-1',
          roles: ['manager'],
        );

        expect(admin.canEditClients, isTrue);
        expect(manager.canEditClients, isFalse);
      });
    });
  });

  group('AuthResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'accessToken': 'test-access-token',
        'refreshToken': 'test-refresh-token',
        'user': {
          'id': 'user-1',
          'email': 'test@example.com',
          'tenantId': 'tenant-1',
          'roles': ['manager'],
        },
      };

      final response = AuthResponse.fromJson(json);

      expect(response.accessToken, equals('test-access-token'));
      expect(response.refreshToken, equals('test-refresh-token'));
      expect(response.user.id, equals('user-1'));
      expect(response.user.email, equals('test@example.com'));
    });
  });
}
