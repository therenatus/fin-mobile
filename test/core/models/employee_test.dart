import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/models/employee.dart';

void main() {
  group('Employee', () {
    final baseEmployeeJson = {
      'id': 'emp-1',
      'name': 'Иван Петров',
      'role': 'tailor',
      'createdAt': '2024-01-01T00:00:00Z',
    };

    test('fromJson parses complete JSON correctly', () {
      final json = {
        ...baseEmployeeJson,
        'phone': '+79001234567',
        'email': 'ivan@example.com',
        'isActive': true,
      };

      final employee = Employee.fromJson(json);

      expect(employee.id, equals('emp-1'));
      expect(employee.name, equals('Иван Петров'));
      expect(employee.role, equals('tailor'));
      expect(employee.phone, equals('+79001234567'));
      expect(employee.email, equals('ivan@example.com'));
      expect(employee.isActive, isTrue);
      expect(employee.createdAt, equals(DateTime.parse('2024-01-01T00:00:00Z')));
    });

    test('fromJson handles null optional fields', () {
      final employee = Employee.fromJson(baseEmployeeJson);

      expect(employee.phone, isNull);
      expect(employee.email, isNull);
      expect(employee.isActive, isTrue); // defaults to true
    });

    test('fromJson handles null isActive as true', () {
      final json = {
        ...baseEmployeeJson,
        'isActive': null,
      };

      final employee = Employee.fromJson(json);

      expect(employee.isActive, isTrue);
    });

    test('fromJson handles isActive false', () {
      final json = {
        ...baseEmployeeJson,
        'isActive': false,
      };

      final employee = Employee.fromJson(json);

      expect(employee.isActive, isFalse);
    });

    group('toJson', () {
      test('serializes required fields', () {
        final employee = Employee(
          id: 'emp-1',
          name: 'Иван Петров',
          role: 'tailor',
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        );

        final json = employee.toJson();

        expect(json['name'], equals('Иван Петров'));
        expect(json['role'], equals('tailor'));
        expect(json.containsKey('phone'), isFalse);
        expect(json.containsKey('email'), isFalse);
      });

      test('includes phone when present', () {
        final employee = Employee(
          id: 'emp-1',
          name: 'Иван Петров',
          role: 'tailor',
          phone: '+79001234567',
          createdAt: DateTime.now(),
        );

        final json = employee.toJson();

        expect(json['phone'], equals('+79001234567'));
      });

      test('includes email when present', () {
        final employee = Employee(
          id: 'emp-1',
          name: 'Иван Петров',
          role: 'tailor',
          email: 'ivan@example.com',
          createdAt: DateTime.now(),
        );

        final json = employee.toJson();

        expect(json['email'], equals('ivan@example.com'));
      });

      test('does not include id and createdAt', () {
        final employee = Employee(
          id: 'emp-1',
          name: 'Иван Петров',
          role: 'tailor',
          createdAt: DateTime.now(),
        );

        final json = employee.toJson();

        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('createdAt'), isFalse);
      });
    });
  });

  group('EmployeeRole', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'role-1',
        'code': 'tailor',
        'label': 'Портной',
        'sortOrder': 1,
      };

      final role = EmployeeRole.fromJson(json);

      expect(role.id, equals('role-1'));
      expect(role.code, equals('tailor'));
      expect(role.label, equals('Портной'));
      expect(role.sortOrder, equals(1));
    });

    test('fromJson handles null sortOrder as 0', () {
      final json = {
        'id': 'role-1',
        'code': 'tailor',
        'label': 'Портной',
      };

      final role = EmployeeRole.fromJson(json);

      expect(role.sortOrder, equals(0));
    });

    test('toString returns label', () {
      final role = EmployeeRole(
        id: 'role-1',
        code: 'tailor',
        label: 'Портной',
        sortOrder: 1,
      );

      expect(role.toString(), equals('Портной'));
    });
  });
}
