import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/models/employee_user.dart';

void main() {
  group('EmployeeUser', () {
    final baseUserJson = {
      'id': 'emp-1',
      'name': 'Иван Петров',
      'email': 'ivan@example.com',
      'role': 'tailor',
      'tenantId': 'tenant-1',
      'tenantName': 'Test Atelier',
    };

    test('fromJson parses complete JSON correctly', () {
      final json = {
        ...baseUserJson,
        'phone': '+79001234567',
        'isActive': true,
        'lastLoginAt': '2024-01-15T10:00:00Z',
      };

      final user = EmployeeUser.fromJson(json);

      expect(user.id, equals('emp-1'));
      expect(user.name, equals('Иван Петров'));
      expect(user.email, equals('ivan@example.com'));
      expect(user.role, equals('tailor'));
      expect(user.phone, equals('+79001234567'));
      expect(user.tenantId, equals('tenant-1'));
      expect(user.tenantName, equals('Test Atelier'));
      expect(user.isActive, isTrue);
      expect(user.lastLoginAt, equals(DateTime.parse('2024-01-15T10:00:00Z')));
    });

    test('fromJson handles null optional fields', () {
      final user = EmployeeUser.fromJson(baseUserJson);

      expect(user.phone, isNull);
      expect(user.isActive, isTrue); // defaults to true
      expect(user.lastLoginAt, isNull);
    });

    test('fromJson handles null isActive as true', () {
      final json = {
        ...baseUserJson,
        'isActive': null,
      };

      final user = EmployeeUser.fromJson(json);

      expect(user.isActive, isTrue);
    });

    test('fromJson handles isActive false', () {
      final json = {
        ...baseUserJson,
        'isActive': false,
      };

      final user = EmployeeUser.fromJson(json);

      expect(user.isActive, isFalse);
    });

    test('toJson serializes all fields', () {
      final user = EmployeeUser(
        id: 'emp-1',
        name: 'Иван Петров',
        email: 'ivan@example.com',
        role: 'tailor',
        phone: '+79001234567',
        tenantId: 'tenant-1',
        tenantName: 'Test Atelier',
        isActive: true,
        lastLoginAt: DateTime.parse('2024-01-15T10:00:00Z'),
      );

      final json = user.toJson();

      expect(json['id'], equals('emp-1'));
      expect(json['name'], equals('Иван Петров'));
      expect(json['email'], equals('ivan@example.com'));
      expect(json['role'], equals('tailor'));
      expect(json['phone'], equals('+79001234567'));
      expect(json['tenantId'], equals('tenant-1'));
      expect(json['tenantName'], equals('Test Atelier'));
      expect(json['isActive'], isTrue);
      expect(json['lastLoginAt'], isNotNull);
    });

    test('toJson handles null lastLoginAt', () {
      final user = EmployeeUser(
        id: 'emp-1',
        name: 'Иван Петров',
        email: 'ivan@example.com',
        role: 'tailor',
        tenantId: 'tenant-1',
        tenantName: 'Test Atelier',
      );

      final json = user.toJson();

      expect(json['lastLoginAt'], isNull);
    });
  });

  group('EmployeeAuthResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'accessToken': 'access-token',
        'refreshToken': 'refresh-token',
        'user': {
          'id': 'emp-1',
          'name': 'Иван Петров',
          'email': 'ivan@example.com',
          'role': 'tailor',
          'tenantId': 'tenant-1',
          'tenantName': 'Test Atelier',
        },
      };

      final response = EmployeeAuthResponse.fromJson(json);

      expect(response.accessToken, equals('access-token'));
      expect(response.refreshToken, equals('refresh-token'));
      expect(response.user.id, equals('emp-1'));
      expect(response.user.name, equals('Иван Петров'));
    });
  });

  group('EmployeeAssignmentOrder', () {
    final baseOrderJson = {
      'id': 'order-1',
      'status': 'in_progress',
      'quantity': 10,
      'modelName': 'Платье',
      'clientName': 'Анна Иванова',
    };

    test('fromJson parses complete JSON correctly', () {
      final json = {
        ...baseOrderJson,
        'dueDate': '2024-02-01T00:00:00Z',
        'modelCategory': 'Женская одежда',
        'completedQuantity': 3,
        'totalCompletedQuantity': 5,
        'loggedHours': 4.5,
      };

      final order = EmployeeAssignmentOrder.fromJson(json);

      expect(order.id, equals('order-1'));
      expect(order.status, equals('in_progress'));
      expect(order.quantity, equals(10));
      expect(order.dueDate, equals(DateTime.parse('2024-02-01T00:00:00Z')));
      expect(order.modelName, equals('Платье'));
      expect(order.modelCategory, equals('Женская одежда'));
      expect(order.clientName, equals('Анна Иванова'));
      expect(order.completedQuantity, equals(3));
      expect(order.totalCompletedQuantity, equals(5));
      expect(order.loggedHours, equals(4.5));
    });

    test('fromJson handles null optional fields', () {
      final order = EmployeeAssignmentOrder.fromJson(baseOrderJson);

      expect(order.dueDate, isNull);
      expect(order.modelCategory, isNull);
      expect(order.completedQuantity, equals(0));
      expect(order.totalCompletedQuantity, equals(0));
      expect(order.loggedHours, equals(0.0));
    });

    test('totalCompletedQuantity falls back to completedQuantity', () {
      final json = {
        ...baseOrderJson,
        'completedQuantity': 5,
      };

      final order = EmployeeAssignmentOrder.fromJson(json);

      expect(order.completedQuantity, equals(5));
      expect(order.totalCompletedQuantity, equals(5));
    });

    group('computed properties', () {
      test('remaining calculates correctly', () {
        final json = {
          ...baseOrderJson,
          'completedQuantity': 3,
        };

        final order = EmployeeAssignmentOrder.fromJson(json);

        expect(order.remaining, equals(7)); // 10 - 3
      });

      test('totalRemaining calculates correctly', () {
        final json = {
          ...baseOrderJson,
          'completedQuantity': 3,
          'totalCompletedQuantity': 6,
        };

        final order = EmployeeAssignmentOrder.fromJson(json);

        expect(order.totalRemaining, equals(4)); // 10 - 6
      });

      test('isStepCompleted returns true when total >= quantity', () {
        final json = {
          ...baseOrderJson,
          'totalCompletedQuantity': 10,
        };

        final order = EmployeeAssignmentOrder.fromJson(json);

        expect(order.isStepCompleted, isTrue);
      });

      test('isStepCompleted returns false when total < quantity', () {
        final json = {
          ...baseOrderJson,
          'totalCompletedQuantity': 9,
        };

        final order = EmployeeAssignmentOrder.fromJson(json);

        expect(order.isStepCompleted, isFalse);
      });

      test('progressPercent calculates correctly', () {
        final json = {
          ...baseOrderJson,
          'completedQuantity': 3,
        };

        final order = EmployeeAssignmentOrder.fromJson(json);

        expect(order.progressPercent, equals(0.3)); // 3 / 10
      });

      test('progressPercent returns 0 when quantity is 0', () {
        final json = {
          ...baseOrderJson,
          'quantity': 0,
        };

        final order = EmployeeAssignmentOrder.fromJson(json);

        expect(order.progressPercent, equals(0.0));
      });

      test('totalProgressPercent calculates correctly', () {
        final json = {
          ...baseOrderJson,
          'totalCompletedQuantity': 5,
        };

        final order = EmployeeAssignmentOrder.fromJson(json);

        expect(order.totalProgressPercent, equals(0.5)); // 5 / 10
      });
    });
  });

  group('EmployeeAssignment', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'assign-1',
        'stepName': 'Раскрой',
        'assignedAt': '2024-01-10T09:00:00Z',
        'order': {
          'id': 'order-1',
          'status': 'in_progress',
          'quantity': 10,
          'modelName': 'Платье',
          'clientName': 'Анна Иванова',
        },
      };

      final assignment = EmployeeAssignment.fromJson(json);

      expect(assignment.id, equals('assign-1'));
      expect(assignment.stepName, equals('Раскрой'));
      expect(assignment.assignedAt, equals(DateTime.parse('2024-01-10T09:00:00Z')));
      expect(assignment.order.id, equals('order-1'));
      expect(assignment.order.modelName, equals('Платье'));
    });
  });

  group('EmployeeWorkLog', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'log-1',
        'step': 'Раскрой',
        'quantity': 5,
        'hours': 2.5,
        'date': '2024-01-15T00:00:00Z',
        'order': {
          'id': 'order-1',
          'modelName': 'Платье',
          'clientName': 'Анна Иванова',
        },
      };

      final workLog = EmployeeWorkLog.fromJson(json);

      expect(workLog.id, equals('log-1'));
      expect(workLog.step, equals('Раскрой'));
      expect(workLog.quantity, equals(5));
      expect(workLog.hours, equals(2.5));
      expect(workLog.date, equals(DateTime.parse('2024-01-15T00:00:00Z')));
      expect(workLog.order.modelName, equals('Платье'));
    });
  });

  group('EmployeeWorkLogOrder', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'order-1',
        'modelName': 'Платье',
        'clientName': 'Анна Иванова',
      };

      final order = EmployeeWorkLogOrder.fromJson(json);

      expect(order.id, equals('order-1'));
      expect(order.modelName, equals('Платье'));
      expect(order.clientName, equals('Анна Иванова'));
    });
  });

  group('EmployeePayroll', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'payroll-1',
        'periodStart': '2024-01-01T00:00:00Z',
        'periodEnd': '2024-01-31T23:59:59Z',
        'totalPayout': 50000,
        'workLogs': [
          {
            'step': 'Раскрой',
            'quantity': 10,
            'hours': 5,
            'date': '2024-01-15T00:00:00Z',
            'modelName': 'Платье',
          },
        ],
        'createdAt': '2024-02-01T10:00:00Z',
      };

      final payroll = EmployeePayroll.fromJson(json);

      expect(payroll.id, equals('payroll-1'));
      expect(payroll.periodStart, equals(DateTime.parse('2024-01-01T00:00:00Z')));
      expect(payroll.periodEnd, equals(DateTime.parse('2024-01-31T23:59:59Z')));
      expect(payroll.totalPayout, equals(50000.0));
      expect(payroll.workLogs, hasLength(1));
      expect(payroll.createdAt, equals(DateTime.parse('2024-02-01T10:00:00Z')));
    });
  });

  group('EmployeePayrollWorkLog', () {
    test('fromJson parses correctly', () {
      final json = {
        'step': 'Раскрой',
        'quantity': 10,
        'hours': 5,
        'date': '2024-01-15T00:00:00Z',
        'modelName': 'Платье',
      };

      final workLog = EmployeePayrollWorkLog.fromJson(json);

      expect(workLog.step, equals('Раскрой'));
      expect(workLog.quantity, equals(10));
      expect(workLog.hours, equals(5.0));
      expect(workLog.date, equals(DateTime.parse('2024-01-15T00:00:00Z')));
      expect(workLog.modelName, equals('Платье'));
    });

    test('fromJson handles null modelName', () {
      final json = {
        'step': 'Раскрой',
        'quantity': 10,
        'hours': 5,
        'date': '2024-01-15T00:00:00Z',
      };

      final workLog = EmployeePayrollWorkLog.fromJson(json);

      expect(workLog.modelName, isNull);
    });
  });

  group('CreateWorkLogRequest', () {
    test('toJson serializes required fields', () {
      final request = CreateWorkLogRequest(
        assignmentId: 'assign-1',
        quantity: 5,
        date: '2024-01-15',
      );

      final json = request.toJson();

      expect(json['assignmentId'], equals('assign-1'));
      expect(json['quantity'], equals(5));
      expect(json['date'], equals('2024-01-15'));
      expect(json.containsKey('hours'), isFalse);
    });

    test('toJson includes hours when present', () {
      final request = CreateWorkLogRequest(
        assignmentId: 'assign-1',
        quantity: 5,
        hours: 2.5,
        date: '2024-01-15',
      );

      final json = request.toJson();

      expect(json['hours'], equals(2.5));
    });
  });

  group('EmployeeAssignmentsResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'assignments': [
          {
            'id': 'assign-1',
            'stepName': 'Раскрой',
            'assignedAt': '2024-01-10T09:00:00Z',
            'order': {
              'id': 'order-1',
              'status': 'in_progress',
              'quantity': 10,
              'modelName': 'Платье',
              'clientName': 'Анна Иванова',
            },
          },
        ],
        'meta': {
          'page': 1,
          'perPage': 20,
          'total': 1,
          'totalPages': 1,
        },
      };

      final response = EmployeeAssignmentsResponse.fromJson(json);

      expect(response.assignments, hasLength(1));
      expect(response.assignments.first.stepName, equals('Раскрой'));
      expect(response.meta.page, equals(1));
      expect(response.meta.total, equals(1));
    });
  });
}
