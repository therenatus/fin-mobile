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

class Transaction {
  final String id;
  final DateTime date;
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

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: TransactionType.fromString(json['type'] as String),
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      orderId: json['orderId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'type': type.value,
      'category': category,
      'amount': amount,
      if (description != null) 'description': description,
      if (orderId != null) 'orderId': orderId,
    };
  }
}

class FinanceReport {
  final double totalIncome;
  final double totalExpense;
  final double profit;
  final List<CategorySummary> incomeByCategory;
  final List<CategorySummary> expenseByCategory;

  FinanceReport({
    required this.totalIncome,
    required this.totalExpense,
    required this.profit,
    required this.incomeByCategory,
    required this.expenseByCategory,
  });

  factory FinanceReport.fromJson(Map<String, dynamic> json) {
    return FinanceReport(
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0,
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0,
      incomeByCategory: (json['incomeByCategory'] as List<dynamic>?)
              ?.map((e) => CategorySummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      expenseByCategory: (json['expenseByCategory'] as List<dynamic>?)
              ?.map((e) => CategorySummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CategorySummary {
  final String category;
  final double amount;
  final int count;

  CategorySummary({
    required this.category,
    required this.amount,
    required this.count,
  });

  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    return CategorySummary(
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      count: json['count'] as int? ?? 0,
    );
  }
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
