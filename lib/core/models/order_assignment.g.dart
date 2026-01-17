// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderAssignment _$OrderAssignmentFromJson(Map<String, dynamic> json) =>
    OrderAssignment(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      stepName: json['stepName'] as String,
      employeeId: json['employeeId'] as String,
      employee: json['employee'] == null
          ? null
          : Employee.fromJson(json['employee'] as Map<String, dynamic>),
      assignedAt: DateTime.parse(json['assignedAt'] as String),
    );

Map<String, dynamic> _$OrderAssignmentToJson(OrderAssignment instance) =>
    <String, dynamic>{
      'stepName': instance.stepName,
      'employeeId': instance.employeeId,
    };
