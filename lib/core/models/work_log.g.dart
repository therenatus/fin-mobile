// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkLog _$WorkLogFromJson(Map<String, dynamic> json) => WorkLog(
  id: json['id'] as String? ?? '',
  employeeId: json['employeeId'] as String? ?? '',
  orderId: json['orderId'] as String? ?? '',
  step: json['step'] as String,
  quantity: (json['quantity'] as num).toInt(),
  hours: (json['hours'] as num?)?.toDouble() ?? 0.0,
  date: WorkLog._dateTimeFromJson(json['date'] as String?),
  createdAt: WorkLog._dateTimeFromJson(json['createdAt'] as String?),
  updatedAt: WorkLog._dateTimeFromJson(json['updatedAt'] as String?),
  employee: json['employee'] == null
      ? null
      : Employee.fromJson(json['employee'] as Map<String, dynamic>),
  order: json['order'] == null
      ? null
      : Order.fromJson(json['order'] as Map<String, dynamic>),
  modelName: json['modelName'] as String?,
  rate: (json['rate'] as num?)?.toDouble(),
  rateType: json['rateType'] as String?,
  payout: (json['payout'] as num?)?.toDouble(),
);

Map<String, dynamic> _$WorkLogToJson(WorkLog instance) => <String, dynamic>{
  'id': instance.id,
  'employeeId': instance.employeeId,
  'orderId': instance.orderId,
  'step': instance.step,
  'quantity': instance.quantity,
  'hours': instance.hours,
  'date': instance.date.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  if (instance.employee?.toJson() case final value?) 'employee': value,
  if (instance.order?.toJson() case final value?) 'order': value,
  if (instance.modelName case final value?) 'modelName': value,
  if (instance.rate case final value?) 'rate': value,
  if (instance.rateType case final value?) 'rateType': value,
  if (instance.payout case final value?) 'payout': value,
};
