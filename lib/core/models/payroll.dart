import 'work_log.dart';
import 'employee.dart';

class EmployeePayrollDetail {
  final double totalPayout;
  final List<WorkLog> workLogs;
  final Employee? employee;

  EmployeePayrollDetail({
    required this.totalPayout,
    required this.workLogs,
    this.employee,
  });

  factory EmployeePayrollDetail.fromJson(Map<String, dynamic> json) {
    return EmployeePayrollDetail(
      totalPayout: (json['totalPayout'] as num?)?.toDouble() ?? 0.0,
      workLogs: (json['workLogs'] as List<dynamic>?)
              ?.map((e) => WorkLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      employee: json['employee'] != null
          ? Employee.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPayout': totalPayout,
      'workLogs': workLogs.map((e) => e.toJson()).toList(),
      if (employee != null) 'employee': employee!.toJson(),
    };
  }
}

class Payroll {
  final String id;
  final String tenantId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalPayout;
  final Map<String, EmployeePayrollDetail> details;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payroll({
    required this.id,
    required this.tenantId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalPayout,
    required this.details,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payroll.fromJson(Map<String, dynamic> json) {
    final detailsJson = json['details'] as Map<String, dynamic>? ?? {};
    final details = <String, EmployeePayrollDetail>{};

    detailsJson.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        details[key] = EmployeePayrollDetail.fromJson(value);
      }
    });

    return Payroll(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      totalPayout: (json['totalPayout'] as num?)?.toDouble() ?? 0.0,
      details: details,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'totalPayout': totalPayout,
      'details': details.map((key, value) => MapEntry(key, value.toJson())),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedPeriod {
    final startMonth = _monthName(periodStart.month);
    final endMonth = _monthName(periodEnd.month);

    if (periodStart.month == periodEnd.month && periodStart.year == periodEnd.year) {
      return '$startMonth ${periodStart.year}';
    }

    return '${periodStart.day} $startMonth - ${periodEnd.day} $endMonth ${periodEnd.year}';
  }

  String get formattedTotalPayout {
    if (totalPayout >= 1000000) {
      return '${(totalPayout / 1000000).toStringAsFixed(1)} млн ₽';
    } else if (totalPayout >= 1000) {
      return '${(totalPayout / 1000).toStringAsFixed(0)} тыс ₽';
    }
    return '${totalPayout.toStringAsFixed(0)} ₽';
  }

  static String _monthName(int month) {
    const months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return months[month - 1];
  }
}
