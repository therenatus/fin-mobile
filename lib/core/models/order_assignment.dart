import 'package:json_annotation/json_annotation.dart';
import 'employee.dart';

part 'order_assignment.g.dart';

/// Order assignment for an employee
@JsonSerializable()
class OrderAssignment {
  @JsonKey(includeToJson: false)
  final String id;
  @JsonKey(includeToJson: false)
  final String orderId;
  final String stepName;
  final String employeeId;
  @JsonKey(includeToJson: false)
  final Employee? employee;
  @JsonKey(includeToJson: false)
  final DateTime assignedAt;

  OrderAssignment({
    required this.id,
    required this.orderId,
    required this.stepName,
    required this.employeeId,
    this.employee,
    required this.assignedAt,
  });

  factory OrderAssignment.fromJson(Map<String, dynamic> json) =>
      _$OrderAssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$OrderAssignmentToJson(this);
}
