import 'package:json_annotation/json_annotation.dart';
import 'employee.dart';
import 'order.dart';

part 'work_log.g.dart';

@JsonSerializable()
class WorkLog {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String employeeId;
  @JsonKey(defaultValue: '')
  final String orderId;
  final String step;
  final int quantity;
  @JsonKey(defaultValue: 0.0)
  final double hours;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime date;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime updatedAt;
  final Employee? employee;
  final Order? order;
  // Payroll-specific fields
  final String? modelName;
  final double? rate;
  final String? rateType;
  final double? payout;

  WorkLog({
    required this.id,
    required this.employeeId,
    required this.orderId,
    required this.step,
    required this.quantity,
    required this.hours,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.employee,
    this.order,
    this.modelName,
    this.rate,
    this.rateType,
    this.payout,
  });

  factory WorkLog.fromJson(Map<String, dynamic> json) =>
      _$WorkLogFromJson(json);

  Map<String, dynamic> toJson() => _$WorkLogToJson(this);

  static DateTime _dateTimeFromJson(String? json) =>
      json != null ? DateTime.parse(json) : DateTime.now();
}
