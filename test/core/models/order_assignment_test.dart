import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/models/order_assignment.dart';
import 'package:clothing_dashboard/core/models/employee.dart';

void main() {
  group('OrderAssignment', () {
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'id': 'assignment-1',
          'orderId': 'order-1',
          'stepName': 'Раскрой',
          'employeeId': 'emp-1',
          'assignedAt': '2024-01-15T10:00:00.000Z',
        };

        final assignment = OrderAssignment.fromJson(json);

        expect(assignment.id, equals('assignment-1'));
        expect(assignment.orderId, equals('order-1'));
        expect(assignment.stepName, equals('Раскрой'));
        expect(assignment.employeeId, equals('emp-1'));
        expect(assignment.assignedAt, isA<DateTime>());
        expect(assignment.employee, isNull);
      });

      test('parses JSON with employee', () {
        final json = {
          'id': 'assignment-1',
          'orderId': 'order-1',
          'stepName': 'Пошив',
          'employeeId': 'emp-1',
          'assignedAt': '2024-01-15T10:00:00.000Z',
          'employee': {
            'id': 'emp-1',
            'name': 'Иван Петров',
            'tenantId': 'tenant-1',
            'role': 'seamstress',
            'phone': '+79001234567',
            'createdAt': '2024-01-01T00:00:00.000Z',
            'updatedAt': '2024-01-01T00:00:00.000Z',
          },
        };

        final assignment = OrderAssignment.fromJson(json);

        expect(assignment.employee, isNotNull);
        expect(assignment.employee!.name, equals('Иван Петров'));
      });
    });

    group('toJson', () {
      test('serializes required fields only', () {
        final assignment = OrderAssignment(
          id: 'assignment-1',
          orderId: 'order-1',
          stepName: 'Раскрой',
          employeeId: 'emp-1',
          assignedAt: DateTime(2024, 1, 15, 10, 0, 0),
        );

        final json = assignment.toJson();

        expect(json['stepName'], equals('Раскрой'));
        expect(json['employeeId'], equals('emp-1'));
        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('orderId'), isFalse);
      });
    });

    test('creates instance with all parameters', () {
      final employee = Employee(
        id: 'emp-1',
        name: 'Анна',
        role: 'seamstress',
        createdAt: DateTime.now(),
      );

      final assignment = OrderAssignment(
        id: 'assignment-1',
        orderId: 'order-1',
        stepName: 'Отделка',
        employeeId: 'emp-1',
        employee: employee,
        assignedAt: DateTime.now(),
      );

      expect(assignment.employee, equals(employee));
    });
  });
}
