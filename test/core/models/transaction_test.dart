import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/models/transaction.dart';

void main() {
  group('TransactionType', () {
    test('has correct values', () {
      expect(TransactionType.income.value, equals('income'));
      expect(TransactionType.expense.value, equals('expense'));
    });

    test('has correct labels', () {
      expect(TransactionType.income.label, equals('Доход'));
      expect(TransactionType.expense.label, equals('Расход'));
    });

    group('fromString', () {
      test('parses income correctly', () {
        expect(TransactionType.fromString('income'), equals(TransactionType.income));
      });

      test('parses expense correctly', () {
        expect(TransactionType.fromString('expense'), equals(TransactionType.expense));
      });

      test('defaults to income for unknown value', () {
        expect(TransactionType.fromString('unknown'), equals(TransactionType.income));
      });
    });
  });

  group('Transaction', () {
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'id': 'txn-1',
          'date': '2024-01-15T00:00:00.000Z',
          'type': 'income',
          'category': 'Пошив',
          'amount': 15000.0,
          'description': 'Оплата заказа #123',
          'orderId': 'order-123',
          'createdAt': '2024-01-15T10:00:00.000Z',
        };

        final transaction = Transaction.fromJson(json);

        expect(transaction.id, equals('txn-1'));
        expect(transaction.date, isA<DateTime>());
        expect(transaction.type, equals(TransactionType.income));
        expect(transaction.category, equals('Пошив'));
        expect(transaction.amount, equals(15000.0));
        expect(transaction.description, equals('Оплата заказа #123'));
        expect(transaction.orderId, equals('order-123'));
        expect(transaction.createdAt, isA<DateTime>());
      });

      test('parses expense transaction', () {
        final json = {
          'id': 'txn-2',
          'date': '2024-01-15T00:00:00.000Z',
          'type': 'expense',
          'category': 'Материалы',
          'amount': 5000.0,
          'createdAt': '2024-01-15T10:00:00.000Z',
        };

        final transaction = Transaction.fromJson(json);

        expect(transaction.type, equals(TransactionType.expense));
        expect(transaction.description, isNull);
        expect(transaction.orderId, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final transaction = Transaction(
          id: 'txn-1',
          date: DateTime(2024, 1, 15),
          type: TransactionType.income,
          category: 'Пошив',
          amount: 15000.0,
          description: 'Оплата заказа',
          orderId: 'order-123',
          createdAt: DateTime(2024, 1, 15, 10, 0),
        );

        final json = transaction.toJson();

        expect(json['date'], contains('2024-01-15'));
        expect(json['type'], equals('income'));
        expect(json['category'], equals('Пошив'));
        expect(json['amount'], equals(15000.0));
        expect(json['description'], equals('Оплата заказа'));
        expect(json['orderId'], equals('order-123'));
      });

      test('excludes null optional fields', () {
        final transaction = Transaction(
          id: 'txn-1',
          date: DateTime(2024, 1, 15),
          type: TransactionType.expense,
          category: 'Материалы',
          amount: 5000.0,
          createdAt: DateTime(2024, 1, 15, 10, 0),
        );

        final json = transaction.toJson();

        expect(json.containsKey('description'), isFalse);
        expect(json.containsKey('orderId'), isFalse);
      });
    });
  });

  group('FinanceReport', () {
    test('parses complete JSON correctly', () {
      final json = {
        'totalIncome': 100000.0,
        'totalExpense': 40000.0,
        'profit': 60000.0,
        'incomeByCategory': [
          {'category': 'Пошив', 'amount': 80000.0, 'count': 10},
          {'category': 'Ремонт', 'amount': 20000.0, 'count': 5},
        ],
        'expenseByCategory': [
          {'category': 'Материалы', 'amount': 25000.0, 'count': 8},
          {'category': 'Зарплата', 'amount': 15000.0, 'count': 1},
        ],
      };

      final report = FinanceReport.fromJson(json);

      expect(report.totalIncome, equals(100000.0));
      expect(report.totalExpense, equals(40000.0));
      expect(report.profit, equals(60000.0));
      expect(report.incomeByCategory, hasLength(2));
      expect(report.expenseByCategory, hasLength(2));
    });

    test('handles null values with defaults', () {
      final json = <String, dynamic>{};

      final report = FinanceReport.fromJson(json);

      expect(report.totalIncome, equals(0));
      expect(report.totalExpense, equals(0));
      expect(report.profit, equals(0));
      expect(report.incomeByCategory, isEmpty);
      expect(report.expenseByCategory, isEmpty);
    });
  });

  group('CategorySummary', () {
    test('parses JSON correctly', () {
      final json = {
        'category': 'Пошив',
        'amount': 50000.0,
        'count': 15,
      };

      final summary = CategorySummary.fromJson(json);

      expect(summary.category, equals('Пошив'));
      expect(summary.amount, equals(50000.0));
      expect(summary.count, equals(15));
    });

    test('handles missing count with default', () {
      final json = {
        'category': 'Ремонт',
        'amount': 10000.0,
      };

      final summary = CategorySummary.fromJson(json);

      expect(summary.count, equals(0));
    });
  });

  group('TransactionCategories', () {
    test('has income categories', () {
      expect(TransactionCategories.income, contains('Пошив'));
      expect(TransactionCategories.income, contains('Ремонт'));
      expect(TransactionCategories.income, contains('Подгонка'));
    });

    test('has expense categories', () {
      expect(TransactionCategories.expense, contains('Материалы'));
      expect(TransactionCategories.expense, contains('Зарплата'));
      expect(TransactionCategories.expense, contains('Аренда'));
    });
  });
}
