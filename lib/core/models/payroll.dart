import 'package:json_annotation/json_annotation.dart';
import 'work_log.dart';
import 'employee.dart';
import 'json_converters.dart';

part 'payroll.g.dart';

@JsonSerializable()
class EmployeePayrollDetail {
  @JsonKey(defaultValue: 0.0)
  final double totalPayout;
  @JsonKey(defaultValue: [])
  final List<WorkLog> workLogs;
  final Employee? employee;

  EmployeePayrollDetail({
    required this.totalPayout,
    required this.workLogs,
    this.employee,
  });

  factory EmployeePayrollDetail.fromJson(Map<String, dynamic> json) =>
      _$EmployeePayrollDetailFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeePayrollDetailToJson(this);
}

@JsonSerializable()
class Payroll {
  @JsonKey(readValue: readId, defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String tenantId;
  final DateTime periodStart;
  final DateTime periodEnd;
  @JsonKey(defaultValue: 0.0)
  final double totalPayout;
  @JsonKey(fromJson: _detailsFromJson, toJson: _detailsToJson)
  final Map<String, EmployeePayrollDetail> details;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _dateTimeFromJson)
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

  factory Payroll.fromJson(Map<String, dynamic> json) =>
      _$PayrollFromJson(json);

  Map<String, dynamic> toJson() => _$PayrollToJson(this);

  static Map<String, EmployeePayrollDetail> _detailsFromJson(
      Map<String, dynamic>? json) {
    if (json == null) return {};
    final details = <String, EmployeePayrollDetail>{};
    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        details[key] = EmployeePayrollDetail.fromJson(value);
      }
    });
    return details;
  }

  static Map<String, dynamic> _detailsToJson(
      Map<String, EmployeePayrollDetail> details) {
    return details.map((key, value) => MapEntry(key, value.toJson()));
  }

  static DateTime _dateTimeFromJson(String? json) =>
      json != null ? DateTime.parse(json) : DateTime.now();

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
      return '${(totalPayout / 1000000).toStringAsFixed(1)} млн сом';
    } else if (totalPayout >= 1000) {
      return '${(totalPayout / 1000).toStringAsFixed(0)} тыс сом';
    }
    return '${totalPayout.toStringAsFixed(0)} сом';
  }

  static String _monthName(int month) {
    const months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return months[month - 1];
  }
}
