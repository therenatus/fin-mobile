// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeePayrollDetail _$EmployeePayrollDetailFromJson(
  Map<String, dynamic> json,
) => EmployeePayrollDetail(
  totalPayout: (json['totalPayout'] as num?)?.toDouble() ?? 0.0,
  workLogs:
      (json['workLogs'] as List<dynamic>?)
          ?.map((e) => WorkLog.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  employee: json['employee'] == null
      ? null
      : Employee.fromJson(json['employee'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EmployeePayrollDetailToJson(
  EmployeePayrollDetail instance,
) => <String, dynamic>{
  'totalPayout': instance.totalPayout,
  'workLogs': instance.workLogs.map((e) => e.toJson()).toList(),
  if (instance.employee?.toJson() case final value?) 'employee': value,
};

Payroll _$PayrollFromJson(Map<String, dynamic> json) => Payroll(
  id: readId(json, 'id') as String? ?? '',
  tenantId: json['tenantId'] as String? ?? '',
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  totalPayout: (json['totalPayout'] as num?)?.toDouble() ?? 0.0,
  details: Payroll._detailsFromJson(json['details'] as Map<String, dynamic>?),
  createdAt: Payroll._dateTimeFromJson(json['createdAt'] as String?),
  updatedAt: Payroll._dateTimeFromJson(json['updatedAt'] as String?),
);

Map<String, dynamic> _$PayrollToJson(Payroll instance) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'totalPayout': instance.totalPayout,
  'details': Payroll._detailsToJson(instance.details),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
