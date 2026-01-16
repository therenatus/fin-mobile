import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/models/order.dart';

void main() {
  group('OrderStatus', () {
    test('values have correct value and label', () {
      expect(OrderStatus.pending.value, equals('pending'));
      expect(OrderStatus.pending.label, equals('Ожидает'));

      expect(OrderStatus.inProgress.value, equals('in_progress'));
      expect(OrderStatus.inProgress.label, equals('В работе'));

      expect(OrderStatus.completed.value, equals('completed'));
      expect(OrderStatus.completed.label, equals('Выполнен'));

      expect(OrderStatus.cancelled.value, equals('cancelled'));
      expect(OrderStatus.cancelled.label, equals('Отменён'));
    });

    test('fromString returns correct enum for valid values', () {
      expect(OrderStatus.fromString('pending'), equals(OrderStatus.pending));
      expect(OrderStatus.fromString('in_progress'), equals(OrderStatus.inProgress));
      expect(OrderStatus.fromString('completed'), equals(OrderStatus.completed));
      expect(OrderStatus.fromString('cancelled'), equals(OrderStatus.cancelled));
    });

    test('fromString returns pending for unknown values', () {
      expect(OrderStatus.fromString('unknown'), equals(OrderStatus.pending));
      expect(OrderStatus.fromString(''), equals(OrderStatus.pending));
    });
  });

  group('OrderModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'model-1',
        'name': 'Платье',
        'category': 'Женская одежда',
        'description': 'Красивое платье',
        'imageUrl': 'https://example.com/image.jpg',
        'basePrice': 5000,
        'processSteps': [
          {
            'id': 'step-1',
            'modelId': 'model-1',
            'stepOrder': 1,
            'name': 'Раскрой',
            'estimatedTime': 60,
            'executorRole': 'cutter',
            'rate': 500,
            'rateType': 'per_unit',
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z',
          },
        ],
      };

      final model = OrderModel.fromJson(json);

      expect(model.id, equals('model-1'));
      expect(model.name, equals('Платье'));
      expect(model.category, equals('Женская одежда'));
      expect(model.description, equals('Красивое платье'));
      expect(model.imageUrl, equals('https://example.com/image.jpg'));
      expect(model.basePrice, equals(5000.0));
      expect(model.processSteps, hasLength(1));
      expect(model.processSteps.first.name, equals('Раскрой'));
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'model-1',
        'name': 'Платье',
        'basePrice': 5000,
      };

      final model = OrderModel.fromJson(json);

      expect(model.category, isNull);
      expect(model.description, isNull);
      expect(model.imageUrl, isNull);
      expect(model.processSteps, isEmpty);
    });

    test('totalEstimatedTime sums all step times', () {
      final json = {
        'id': 'model-1',
        'name': 'Платье',
        'basePrice': 5000,
        'processSteps': [
          {
            'id': 'step-1',
            'modelId': 'model-1',
            'stepOrder': 1,
            'name': 'Раскрой',
            'estimatedTime': 60,
            'executorRole': 'cutter',
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z',
          },
          {
            'id': 'step-2',
            'modelId': 'model-1',
            'stepOrder': 2,
            'name': 'Пошив',
            'estimatedTime': 120,
            'executorRole': 'tailor',
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z',
          },
        ],
      };

      final model = OrderModel.fromJson(json);

      expect(model.totalEstimatedTime, equals(180));
    });

    test('totalLaborCost sums all step rates', () {
      final json = {
        'id': 'model-1',
        'name': 'Платье',
        'basePrice': 5000,
        'processSteps': [
          {
            'id': 'step-1',
            'modelId': 'model-1',
            'stepOrder': 1,
            'name': 'Раскрой',
            'estimatedTime': 60,
            'executorRole': 'cutter',
            'rate': 500,
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z',
          },
          {
            'id': 'step-2',
            'modelId': 'model-1',
            'stepOrder': 2,
            'name': 'Пошив',
            'estimatedTime': 120,
            'executorRole': 'tailor',
            'rate': 1000,
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z',
          },
        ],
      };

      final model = OrderModel.fromJson(json);

      expect(model.totalLaborCost, equals(1500.0));
    });
  });

  group('OrderStatusLog', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'log-1',
        'status': 'pending',
        'timestamp': '2024-01-01T12:00:00Z',
        'notes': 'Created order',
      };

      final log = OrderStatusLog.fromJson(json);

      expect(log.id, equals('log-1'));
      expect(log.status, equals('pending'));
      expect(log.timestamp, equals(DateTime.parse('2024-01-01T12:00:00Z')));
      expect(log.notes, equals('Created order'));
    });

    test('fromJson handles null notes', () {
      final json = {
        'id': 'log-1',
        'status': 'pending',
        'timestamp': '2024-01-01T12:00:00Z',
      };

      final log = OrderStatusLog.fromJson(json);

      expect(log.notes, isNull);
    });
  });

  group('Order', () {
    final baseOrderJson = {
      'id': 'order-1',
      'clientId': 'client-1',
      'modelId': 'model-1',
      'quantity': 2,
      'status': 'pending',
      'createdAt': '2024-01-01T00:00:00Z',
      'updatedAt': '2024-01-02T00:00:00Z',
    };

    test('fromJson parses complete JSON correctly', () {
      final json = {
        ...baseOrderJson,
        'dueDate': '2024-02-01T00:00:00Z',
        'client': {
          'id': 'client-1',
          'name': 'Test Client',
          'contacts': {'email': 'client@example.com'},
          'createdAt': '2024-01-01T00:00:00Z',
          'updatedAt': '2024-01-01T00:00:00Z',
        },
        'model': {
          'id': 'model-1',
          'name': 'Платье',
          'basePrice': 5000,
        },
        'statusLogs': [
          {
            'id': 'log-1',
            'status': 'pending',
            'timestamp': '2024-01-01T00:00:00Z',
          },
        ],
      };

      final order = Order.fromJson(json);

      expect(order.id, equals('order-1'));
      expect(order.clientId, equals('client-1'));
      expect(order.modelId, equals('model-1'));
      expect(order.quantity, equals(2));
      expect(order.status, equals(OrderStatus.pending));
      expect(order.dueDate, isNotNull);
      expect(order.client, isNotNull);
      expect(order.client!.name, equals('Test Client'));
      expect(order.model, isNotNull);
      expect(order.model!.name, equals('Платье'));
      expect(order.statusLogs, hasLength(1));
    });

    test('fromJson handles null optional fields', () {
      final order = Order.fromJson(baseOrderJson);

      expect(order.dueDate, isNull);
      expect(order.client, isNull);
      expect(order.model, isNull);
      expect(order.statusLogs, isEmpty);
    });

    test('totalPrice calculates correctly', () {
      final json = {
        ...baseOrderJson,
        'model': {
          'id': 'model-1',
          'name': 'Платье',
          'basePrice': 5000,
        },
      };

      final order = Order.fromJson(json);

      expect(order.totalPrice, equals(10000.0)); // 5000 * 2
    });

    test('totalPrice returns 0 when model is null', () {
      final order = Order.fromJson(baseOrderJson);

      expect(order.totalPrice, equals(0.0));
    });

    group('isOverdue', () {
      test('returns false when dueDate is null', () {
        final order = Order.fromJson(baseOrderJson);

        expect(order.isOverdue, isFalse);
      });

      test('returns false when status is completed', () {
        final json = {
          ...baseOrderJson,
          'status': 'completed',
          'dueDate': '2020-01-01T00:00:00Z', // Past date
        };

        final order = Order.fromJson(json);

        expect(order.isOverdue, isFalse);
      });

      test('returns false when status is cancelled', () {
        final json = {
          ...baseOrderJson,
          'status': 'cancelled',
          'dueDate': '2020-01-01T00:00:00Z', // Past date
        };

        final order = Order.fromJson(json);

        expect(order.isOverdue, isFalse);
      });

      test('returns true when dueDate is in the past and status is pending', () {
        final json = {
          ...baseOrderJson,
          'status': 'pending',
          'dueDate': '2020-01-01T00:00:00Z', // Past date
        };

        final order = Order.fromJson(json);

        expect(order.isOverdue, isTrue);
      });

      test('returns false when dueDate is in the future', () {
        final futureDate = DateTime.now().add(const Duration(days: 30));
        final json = {
          ...baseOrderJson,
          'status': 'pending',
          'dueDate': futureDate.toIso8601String(),
        };

        final order = Order.fromJson(json);

        expect(order.isOverdue, isFalse);
      });
    });

    test('daysUntilDue returns 0 when dueDate is null', () {
      final order = Order.fromJson(baseOrderJson);

      expect(order.daysUntilDue, equals(0));
    });

    test('daysUntilDue calculates days correctly', () {
      final futureDate = DateTime.now().add(const Duration(days: 10));
      final json = {
        ...baseOrderJson,
        'dueDate': futureDate.toIso8601String(),
      };

      final order = Order.fromJson(json);

      // Allow for slight timing differences
      expect(order.daysUntilDue, closeTo(10, 1));
    });
  });

  group('OrdersResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'orders': [
          {
            'id': 'order-1',
            'clientId': 'client-1',
            'modelId': 'model-1',
            'quantity': 1,
            'status': 'pending',
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z',
          },
        ],
        'meta': {
          'page': 1,
          'perPage': 20,
          'total': 1,
          'totalPages': 1,
        },
      };

      final response = OrdersResponse.fromJson(json);

      expect(response.orders, hasLength(1));
      expect(response.orders.first.id, equals('order-1'));
      expect(response.meta.page, equals(1));
      expect(response.meta.total, equals(1));
    });
  });

  group('OrdersMeta', () {
    test('fromJson parses correctly', () {
      final json = {
        'page': 2,
        'perPage': 10,
        'total': 50,
        'totalPages': 5,
      };

      final meta = OrdersMeta.fromJson(json);

      expect(meta.page, equals(2));
      expect(meta.perPage, equals(10));
      expect(meta.total, equals(50));
      expect(meta.totalPages, equals(5));
    });
  });
}
