import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/models/client_user.dart';

void main() {
  group('TenantLink', () {
    test('fromJson parses correctly', () {
      final json = {
        'clientId': 'client-1',
        'tenantId': 'tenant-1',
        'tenantName': 'Test Atelier',
        'tenantDomain': 'test.example.com',
      };

      final link = TenantLink.fromJson(json);

      expect(link.clientId, equals('client-1'));
      expect(link.tenantId, equals('tenant-1'));
      expect(link.tenantName, equals('Test Atelier'));
      expect(link.tenantDomain, equals('test.example.com'));
    });

    test('fromJson handles null tenantDomain', () {
      final json = {
        'clientId': 'client-1',
        'tenantId': 'tenant-1',
        'tenantName': 'Test Atelier',
      };

      final link = TenantLink.fromJson(json);

      expect(link.tenantDomain, isNull);
    });
  });

  group('ClientUser', () {
    test('fromJson parses complete JSON correctly', () {
      final json = {
        'id': 'user-1',
        'email': 'client@example.com',
        'phone': '+79001234567',
        'name': 'Анна Иванова',
        'isVerified': true,
        'tenants': [
          {
            'clientId': 'client-1',
            'tenantId': 'tenant-1',
            'tenantName': 'Test Atelier',
          },
        ],
      };

      final user = ClientUser.fromJson(json);

      expect(user.id, equals('user-1'));
      expect(user.email, equals('client@example.com'));
      expect(user.phone, equals('+79001234567'));
      expect(user.name, equals('Анна Иванова'));
      expect(user.isVerified, isTrue);
      expect(user.tenants, hasLength(1));
      expect(user.tenants.first.tenantName, equals('Test Atelier'));
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'user-1',
        'name': 'Анна Иванова',
      };

      final user = ClientUser.fromJson(json);

      expect(user.email, isNull);
      expect(user.phone, isNull);
      expect(user.isVerified, isFalse);
      expect(user.tenants, isEmpty);
    });

    test('fromJson handles null isVerified as false', () {
      final json = {
        'id': 'user-1',
        'name': 'Анна Иванова',
        'isVerified': null,
      };

      final user = ClientUser.fromJson(json);

      expect(user.isVerified, isFalse);
    });

    test('toJson serializes all fields', () {
      final user = ClientUser(
        id: 'user-1',
        email: 'client@example.com',
        phone: '+79001234567',
        name: 'Анна Иванова',
        isVerified: true,
      );

      final json = user.toJson();

      expect(json['id'], equals('user-1'));
      expect(json['email'], equals('client@example.com'));
      expect(json['phone'], equals('+79001234567'));
      expect(json['name'], equals('Анна Иванова'));
      expect(json['isVerified'], isTrue);
    });
  });

  group('ClientAuthResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'accessToken': 'access-token',
        'refreshToken': 'refresh-token',
        'user': {
          'id': 'user-1',
          'name': 'Анна Иванова',
        },
      };

      final response = ClientAuthResponse.fromJson(json);

      expect(response.accessToken, equals('access-token'));
      expect(response.refreshToken, equals('refresh-token'));
      expect(response.user.id, equals('user-1'));
      expect(response.user.name, equals('Анна Иванова'));
    });
  });

  group('ClientOrderModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'model-1',
        'name': 'Платье',
        'category': 'Женская одежда',
        'imageUrl': 'https://example.com/image.jpg',
        'basePrice': 5000,
      };

      final model = ClientOrderModel.fromJson(json);

      expect(model.id, equals('model-1'));
      expect(model.name, equals('Платье'));
      expect(model.category, equals('Женская одежда'));
      expect(model.imageUrl, equals('https://example.com/image.jpg'));
      expect(model.basePrice, equals(5000.0));
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'model-1',
        'name': 'Платье',
      };

      final model = ClientOrderModel.fromJson(json);

      expect(model.category, isNull);
      expect(model.imageUrl, isNull);
      expect(model.basePrice, isNull);
    });
  });

  group('ClientOrder', () {
    final baseOrderJson = {
      'id': 'order-1',
      'tenantId': 'tenant-1',
      'tenantName': 'Test Atelier',
      'model': {
        'id': 'model-1',
        'name': 'Платье',
        'basePrice': 5000,
      },
      'quantity': 2,
      'status': 'pending',
      'createdAt': '2024-01-01T00:00:00Z',
    };

    test('fromJson parses complete JSON correctly', () {
      final json = {
        ...baseOrderJson,
        'dueDate': '2024-02-01T00:00:00Z',
      };

      final order = ClientOrder.fromJson(json);

      expect(order.id, equals('order-1'));
      expect(order.tenantId, equals('tenant-1'));
      expect(order.tenantName, equals('Test Atelier'));
      expect(order.model.name, equals('Платье'));
      expect(order.quantity, equals(2));
      expect(order.status, equals('pending'));
      expect(order.dueDate, isNotNull);
      expect(order.createdAt, equals(DateTime.parse('2024-01-01T00:00:00Z')));
    });

    test('fromJson handles null dueDate', () {
      final order = ClientOrder.fromJson(baseOrderJson);

      expect(order.dueDate, isNull);
    });

    group('statusLabel', () {
      test('returns Russian label for pending', () {
        final order = ClientOrder.fromJson({...baseOrderJson, 'status': 'pending'});
        expect(order.statusLabel, equals('Ожидает'));
      });

      test('returns Russian label for in_progress', () {
        final order = ClientOrder.fromJson({...baseOrderJson, 'status': 'in_progress'});
        expect(order.statusLabel, equals('В работе'));
      });

      test('returns Russian label for completed', () {
        final order = ClientOrder.fromJson({...baseOrderJson, 'status': 'completed'});
        expect(order.statusLabel, equals('Готово'));
      });

      test('returns Russian label for cancelled', () {
        final order = ClientOrder.fromJson({...baseOrderJson, 'status': 'cancelled'});
        expect(order.statusLabel, equals('Отменён'));
      });

      test('returns raw status for unknown values', () {
        final order = ClientOrder.fromJson({...baseOrderJson, 'status': 'custom_status'});
        expect(order.statusLabel, equals('custom_status'));
      });
    });

    test('totalCost calculates correctly', () {
      final order = ClientOrder.fromJson(baseOrderJson);
      expect(order.totalCost, equals(10000.0)); // 5000 * 2
    });

    test('totalCost handles null basePrice', () {
      final json = {
        ...baseOrderJson,
        'model': {
          'id': 'model-1',
          'name': 'Платье',
        },
      };

      final order = ClientOrder.fromJson(json);
      expect(order.totalCost, equals(0.0));
    });
  });

  group('ClientOrdersResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'orders': [
          {
            'id': 'order-1',
            'tenantId': 'tenant-1',
            'tenantName': 'Test Atelier',
            'model': {'id': 'model-1', 'name': 'Платье'},
            'quantity': 1,
            'status': 'pending',
            'createdAt': '2024-01-01T00:00:00Z',
          },
        ],
        'meta': {
          'page': 1,
          'perPage': 20,
          'total': 1,
          'totalPages': 1,
        },
      };

      final response = ClientOrdersResponse.fromJson(json);

      expect(response.orders, hasLength(1));
      expect(response.orders.first.id, equals('order-1'));
      expect(response.meta.page, equals(1));
      expect(response.meta.total, equals(1));
    });
  });
}
