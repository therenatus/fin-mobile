import 'package:json_annotation/json_annotation.dart';
import 'json_converters.dart';

part 'transaction.g.dart';

enum TransactionType {
  income('income', 'Доход'),
  expense('expense', 'Расход');

  final String value;
  final String label;
  const TransactionType(this.value, this.label);

  static TransactionType fromString(String type) {
    return TransactionType.values.firstWhere(
      (e) => e.value == type,
      orElse: () => TransactionType.income,
    );
  }
}

@JsonSerializable()
class Transaction {
  final String id;
  final DateTime date;
  @TransactionTypeConverter()
  final TransactionType type;
  final String category;
  final double amount;
  final String? description;
  final String? orderId;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.date,
    required this.type,
    required this.category,
    required this.amount,
    this.description,
    this.orderId,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}

@JsonSerializable()
class FinanceReport {
  @JsonKey(defaultValue: 0.0)
  final double totalIncome;
  @JsonKey(defaultValue: 0.0)
  final double totalExpense;
  @JsonKey(defaultValue: 0.0)
  final double profit;
  @JsonKey(defaultValue: [])
  final List<CategorySummary> incomeByCategory;
  @JsonKey(defaultValue: [])
  final List<CategorySummary> expenseByCategory;

  FinanceReport({
    required this.totalIncome,
    required this.totalExpense,
    required this.profit,
    required this.incomeByCategory,
    required this.expenseByCategory,
  });

  factory FinanceReport.fromJson(Map<String, dynamic> json) =>
      _$FinanceReportFromJson(json);

  Map<String, dynamic> toJson() => _$FinanceReportToJson(this);
}

@JsonSerializable()
class CategorySummary {
  final String category;
  final double amount;
  @JsonKey(defaultValue: 0)
  final int count;

  CategorySummary({
    required this.category,
    required this.amount,
    required this.count,
  });

  factory CategorySummary.fromJson(Map<String, dynamic> json) =>
      _$CategorySummaryFromJson(json);

  Map<String, dynamic> toJson() => _$CategorySummaryToJson(this);
}

// Categories for transactions
class TransactionCategories {
  static const List<String> income = [
    'Пошив',
    'Ремонт',
    'Подгонка',
    'Аксессуары',
    'Другое',
  ];

  static const List<String> expense = [
    'Материалы',
    'Зарплата',
    'Аренда',
    'Оборудование',
    'Коммунальные',
    'Реклама',
    'Налоги',
    'Другое',
  ];
}
