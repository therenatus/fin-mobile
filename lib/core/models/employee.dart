import 'package:json_annotation/json_annotation.dart';

part 'employee.g.dart';

@JsonSerializable()
class Employee {
  @JsonKey(includeToJson: false)
  final String id;
  final String name;
  final String role;
  final String? phone;
  final String? email;
  @JsonKey(defaultValue: true, includeToJson: false)
  final bool isActive;
  @JsonKey(includeToJson: false)
  final DateTime createdAt;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    this.phone,
    this.email,
    this.isActive = true,
    required this.createdAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) =>
      _$EmployeeFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeToJson(this);
}

/// Role from database
@JsonSerializable()
class EmployeeRole {
  final String id;
  final String code;
  final String label;
  @JsonKey(defaultValue: 0)
  final int sortOrder;

  EmployeeRole({
    required this.id,
    required this.code,
    required this.label,
    required this.sortOrder,
  });

  factory EmployeeRole.fromJson(Map<String, dynamic> json) =>
      _$EmployeeRoleFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeRoleToJson(this);

  @override
  String toString() => label;
}
