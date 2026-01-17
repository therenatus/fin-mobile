// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
  id: json['id'] as String,
  name: json['name'] as String,
  role: json['role'] as String,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
  'name': instance.name,
  'role': instance.role,
  'phone': ?instance.phone,
  'email': ?instance.email,
};

EmployeeRole _$EmployeeRoleFromJson(Map<String, dynamic> json) => EmployeeRole(
  id: json['id'] as String,
  code: json['code'] as String,
  label: json['label'] as String,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$EmployeeRoleToJson(EmployeeRole instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'label': instance.label,
      'sortOrder': instance.sortOrder,
    };
