import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/models/work_log.dart';

void main() {
  group('WorkLog', () {
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'id': 'log-1',
          'employeeId': 'emp-1',
          'orderId': 'order-1',
          'step': 'Пошив',
          'quantity': 5,
          'hours': 2.5,
          'date': '2024-01-15T00:00:00.000Z',
          'createdAt': '2024-01-15T10:00:00.000Z',
          'updatedAt': '2024-01-15T10:00:00.000Z',
        };

        final workLog = WorkLog.fromJson(json);

        expect(workLog.id, equals('log-1'));
        expect(workLog.employeeId, equals('emp-1'));
        expect(workLog.orderId, equals('order-1'));
        expect(workLog.step, equals('Пошив'));
        expect(workLog.quantity, equals(5));
        expect(workLog.hours, equals(2.5));
        expect(workLog.date, isA<DateTime>());
        expect(workLog.createdAt, isA<DateTime>());
        expect(workLog.updatedAt, isA<DateTime>());
      });

      test('parses JSON with payroll fields', () {
        final json = {
          'id': 'log-1',
          'employeeId': 'emp-1',
          'orderId': 'order-1',
          'step': 'Раскрой',
          'quantity': 10,
          'hours': 3.0,
          'date': '2024-01-15T00:00:00.000Z',
          'createdAt': '2024-01-15T10:00:00.000Z',
          'updatedAt': '2024-01-15T10:00:00.000Z',
          'modelName': 'Платье вечернее',
          'rate': 500.0,
          'rateType': 'per_item',
          'payout': 5000.0,
        };

        final workLog = WorkLog.fromJson(json);

        expect(workLog.modelName, equals('Платье вечернее'));
        expect(workLog.rate, equals(500.0));
        expect(workLog.rateType, equals('per_item'));
        expect(workLog.payout, equals(5000.0));
      });

      test('handles null optional fields with defaults', () {
        final json = {
          'step': 'Отделка',
          'quantity': 1,
        };

        final workLog = WorkLog.fromJson(json);

        expect(workLog.id, equals(''));
        expect(workLog.employeeId, equals(''));
        expect(workLog.orderId, equals(''));
        expect(workLog.hours, equals(0));
        expect(workLog.date, isA<DateTime>());
        expect(workLog.modelName, isNull);
        expect(workLog.rate, isNull);
        expect(workLog.payout, isNull);
      });

      test('parses nested employee', () {
        final json = {
          'id': 'log-1',
          'employeeId': 'emp-1',
          'orderId': 'order-1',
          'step': 'Пошив',
          'quantity': 2,
          'hours': 1.0,
          'date': '2024-01-15T00:00:00.000Z',
          'createdAt': '2024-01-15T10:00:00.000Z',
          'updatedAt': '2024-01-15T10:00:00.000Z',
          'employee': {
            'id': 'emp-1',
            'name': 'Мария',
            'tenantId': 'tenant-1',
            'role': 'seamstress',
            'createdAt': '2024-01-01T00:00:00.000Z',
            'updatedAt': '2024-01-01T00:00:00.000Z',
          },
        };

        final workLog = WorkLog.fromJson(json);

        expect(workLog.employee, isNotNull);
        expect(workLog.employee!.name, equals('Мария'));
      });

      test('parses nested order', () {
        final json = {
          'id': 'log-1',
          'employeeId': 'emp-1',
          'orderId': 'order-1',
          'step': 'Упаковка',
          'quantity': 1,
          'hours': 0.5,
          'date': '2024-01-15T00:00:00.000Z',
          'createdAt': '2024-01-15T10:00:00.000Z',
          'updatedAt': '2024-01-15T10:00:00.000Z',
          'order': {
            'id': 'order-1',
            'clientId': 'client-1',
            'modelId': 'model-1',
            'quantity': 1,
            'status': 'completed',
            'createdAt': '2024-01-01T00:00:00.000Z',
            'updatedAt': '2024-01-15T00:00:00.000Z',
          },
        };

        final workLog = WorkLog.fromJson(json);

        expect(workLog.order, isNotNull);
        expect(workLog.order!.id, equals('order-1'));
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final workLog = WorkLog(
          id: 'log-1',
          employeeId: 'emp-1',
          orderId: 'order-1',
          step: 'Пошив',
          quantity: 5,
          hours: 2.5,
          date: DateTime(2024, 1, 15),
          createdAt: DateTime(2024, 1, 15, 10, 0),
          updatedAt: DateTime(2024, 1, 15, 10, 0),
        );

        final json = workLog.toJson();

        expect(json['id'], equals('log-1'));
        expect(json['employeeId'], equals('emp-1'));
        expect(json['orderId'], equals('order-1'));
        expect(json['step'], equals('Пошив'));
        expect(json['quantity'], equals(5));
        expect(json['hours'], equals(2.5));
        expect(json['date'], contains('2024-01-15'));
      });
    });
  });
}
