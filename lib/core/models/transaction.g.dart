// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  type: const TransactionTypeConverter().fromJson(json['type'] as String),
  category: json['category'] as String,
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String?,
  orderId: json['orderId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'type': const TransactionTypeConverter().toJson(instance.type),
      'category': instance.category,
      'amount': instance.amount,
      'description': ?instance.description,
      'orderId': ?instance.orderId,
      'createdAt': instance.createdAt.toIso8601String(),
    };

FinanceReport _$FinanceReportFromJson(Map<String, dynamic> json) =>
    FinanceReport(
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
      incomeByCategory:
          (json['incomeByCategory'] as List<dynamic>?)
              ?.map((e) => CategorySummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      expenseByCategory:
          (json['expenseByCategory'] as List<dynamic>?)
              ?.map((e) => CategorySummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$FinanceReportToJson(
  FinanceReport instance,
) => <String, dynamic>{
  'totalIncome': instance.totalIncome,
  'totalExpense': instance.totalExpense,
  'profit': instance.profit,
  'incomeByCategory': instance.incomeByCategory.map((e) => e.toJson()).toList(),
  'expenseByCategory': instance.expenseByCategory
      .map((e) => e.toJson())
      .toList(),
};

CategorySummary _$CategorySummaryFromJson(Map<String, dynamic> json) =>
    CategorySummary(
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CategorySummaryToJson(CategorySummary instance) =>
    <String, dynamic>{
      'category': instance.category,
      'amount': instance.amount,
      'count': instance.count,
    };
