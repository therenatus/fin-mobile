import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/models/payroll.dart';

void main() {
  group('EmployeePayrollDetail', () {
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'totalPayout': 25000.0,
          'workLogs': [
            {
              'id': 'log-1',
              'employeeId': 'emp-1',
              'orderId': 'order-1',
              'step': 'Пошив',
              'quantity': 5,
              'hours': 10.0,
              'date': '2024-01-15T00:00:00.000Z',
              'createdAt': '2024-01-15T00:00:00.000Z',
              'updatedAt': '2024-01-15T00:00:00.000Z',
            },
          ],
          'employee': {
            'id': 'emp-1',
            'name': 'Мария Сидорова',
            'tenantId': 'tenant-1',
            'role': 'seamstress',
            'createdAt': '2024-01-01T00:00:00.000Z',
            'updatedAt': '2024-01-01T00:00:00.000Z',
          },
        };

        final detail = EmployeePayrollDetail.fromJson(json);

        expect(detail.totalPayout, equals(25000.0));
        expect(detail.workLogs, hasLength(1));
        expect(detail.employee, isNotNull);
        expect(detail.employee!.name, equals('Мария Сидорова'));
      });

      test('handles null values with defaults', () {
        final json = <String, dynamic>{};

        final detail = EmployeePayrollDetail.fromJson(json);

        expect(detail.totalPayout, equals(0));
        expect(detail.workLogs, isEmpty);
        expect(detail.employee, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final detail = EmployeePayrollDetail(
          totalPayout: 15000.0,
          workLogs: [],
        );

        final json = detail.toJson();

        expect(json['totalPayout'], equals(15000.0));
        expect(json['workLogs'], isEmpty);
        expect(json.containsKey('employee'), isFalse);
      });
    });
  });

  group('Payroll', () {
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'id': 'payroll-1',
          'tenantId': 'tenant-1',
          'periodStart': '2024-01-01T00:00:00.000Z',
          'periodEnd': '2024-01-31T23:59:59.000Z',
          'totalPayout': 150000.0,
          'details': {
            'emp-1': {
              'totalPayout': 50000.0,
              'workLogs': [],
            },
            'emp-2': {
              'totalPayout': 100000.0,
              'workLogs': [],
            },
          },
          'createdAt': '2024-02-01T00:00:00.000Z',
          'updatedAt': '2024-02-01T00:00:00.000Z',
        };

        final payroll = Payroll.fromJson(json);

        expect(payroll.id, equals('payroll-1'));
        expect(payroll.tenantId, equals('tenant-1'));
        expect(payroll.periodStart, isA<DateTime>());
        expect(payroll.periodEnd, isA<DateTime>());
        expect(payroll.totalPayout, equals(150000.0));
        expect(payroll.details, hasLength(2));
        expect(payroll.details['emp-1']!.totalPayout, equals(50000.0));
      });

      test('handles _id field for MongoDB', () {
        final json = <String, dynamic>{
          '_id': 'payroll-mongo-1',
          'tenantId': 'tenant-1',
          'periodStart': '2024-01-01T00:00:00.000Z',
          'periodEnd': '2024-01-31T23:59:59.000Z',
          'totalPayout': 100000.0,
          'details': <String, dynamic>{},
          'createdAt': '2024-02-01T00:00:00.000Z',
          'updatedAt': '2024-02-01T00:00:00.000Z',
        };

        final payroll = Payroll.fromJson(json);

        expect(payroll.id, equals('payroll-mongo-1'));
      });

      test('handles missing optional fields', () {
        final json = {
          'periodStart': '2024-01-01T00:00:00.000Z',
          'periodEnd': '2024-01-31T23:59:59.000Z',
        };

        final payroll = Payroll.fromJson(json);

        expect(payroll.id, equals(''));
        expect(payroll.tenantId, equals(''));
        expect(payroll.totalPayout, equals(0));
        expect(payroll.details, isEmpty);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final payroll = Payroll(
          id: 'payroll-1',
          tenantId: 'tenant-1',
          periodStart: DateTime(2024, 1, 1),
          periodEnd: DateTime(2024, 1, 31, 23, 59, 59),
          totalPayout: 150000.0,
          details: {
            'emp-1': EmployeePayrollDetail(
              totalPayout: 150000.0,
              workLogs: [],
            ),
          },
          createdAt: DateTime(2024, 2, 1),
          updatedAt: DateTime(2024, 2, 1),
        );

        final json = payroll.toJson();

        expect(json['id'], equals('payroll-1'));
        expect(json['tenantId'], equals('tenant-1'));
        expect(json['periodStart'], contains('2024-01-01'));
        expect(json['periodEnd'], contains('2024-01-31'));
        expect(json['totalPayout'], equals(150000.0));
        expect(json['details'], isA<Map>());
      });
    });

    group('formattedPeriod', () {
      test('returns month and year for same month', () {
        final payroll = Payroll(
          id: 'payroll-1',
          tenantId: 'tenant-1',
          periodStart: DateTime(2024, 1, 1),
          periodEnd: DateTime(2024, 1, 31),
          totalPayout: 100000.0,
          details: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(payroll.formattedPeriod, equals('янв 2024'));
      });

      test('returns date range for different months', () {
        final payroll = Payroll(
          id: 'payroll-1',
          tenantId: 'tenant-1',
          periodStart: DateTime(2024, 1, 15),
          periodEnd: DateTime(2024, 2, 14),
          totalPayout: 100000.0,
          details: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(payroll.formattedPeriod, equals('15 янв - 14 фев 2024'));
      });
    });

    group('formattedTotalPayout', () {
      test('formats millions correctly', () {
        final payroll = Payroll(
          id: 'payroll-1',
          tenantId: 'tenant-1',
          periodStart: DateTime(2024, 1, 1),
          periodEnd: DateTime(2024, 1, 31),
          totalPayout: 2500000.0,
          details: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(payroll.formattedTotalPayout, equals('2.5 млн сом'));
      });

      test('formats thousands correctly', () {
        final payroll = Payroll(
          id: 'payroll-1',
          tenantId: 'tenant-1',
          periodStart: DateTime(2024, 1, 1),
          periodEnd: DateTime(2024, 1, 31),
          totalPayout: 150000.0,
          details: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(payroll.formattedTotalPayout, equals('150 тыс сом'));
      });

      test('formats small amounts correctly', () {
        final payroll = Payroll(
          id: 'payroll-1',
          tenantId: 'tenant-1',
          periodStart: DateTime(2024, 1, 1),
          periodEnd: DateTime(2024, 1, 31),
          totalPayout: 500.0,
          details: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(payroll.formattedTotalPayout, equals('500 сом'));
      });
    });
  });
}
