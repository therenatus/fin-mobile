// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeUser _$EmployeeUserFromJson(Map<String, dynamic> json) => EmployeeUser(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  phone: json['phone'] as String?,
  tenantId: json['tenantId'] as String,
  tenantName: json['tenantName'] as String,
  isActive: json['isActive'] as bool? ?? true,
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
);

Map<String, dynamic> _$EmployeeUserToJson(EmployeeUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'phone': ?instance.phone,
      'tenantId': instance.tenantId,
      'tenantName': instance.tenantName,
      'isActive': instance.isActive,
      'lastLoginAt': ?instance.lastLoginAt?.toIso8601String(),
    };

EmployeeAuthResponse _$EmployeeAuthResponseFromJson(
  Map<String, dynamic> json,
) => EmployeeAuthResponse(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  user: EmployeeUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EmployeeAuthResponseToJson(
  EmployeeAuthResponse instance,
) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'user': instance.user.toJson(),
};

EmployeeAssignment _$EmployeeAssignmentFromJson(Map<String, dynamic> json) =>
    EmployeeAssignment(
      id: json['id'] as String,
      stepName: json['stepName'] as String,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      order: EmployeeAssignmentOrder.fromJson(
        json['order'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$EmployeeAssignmentToJson(EmployeeAssignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stepName': instance.stepName,
      'assignedAt': instance.assignedAt.toIso8601String(),
      'order': instance.order.toJson(),
    };

EmployeeAssignmentOrder _$EmployeeAssignmentOrderFromJson(
  Map<String, dynamic> json,
) => EmployeeAssignmentOrder(
  id: json['id'] as String,
  status: json['status'] as String,
  quantity: (json['quantity'] as num).toInt(),
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  modelName: json['modelName'] as String,
  modelCategory: json['modelCategory'] as String?,
  clientName: json['clientName'] as String,
  completedQuantity: (json['completedQuantity'] as num?)?.toInt() ?? 0,
  totalCompletedQuantity:
      (json['totalCompletedQuantity'] as num?)?.toInt() ?? 0,
  loggedHours: (json['loggedHours'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$EmployeeAssignmentOrderToJson(
  EmployeeAssignmentOrder instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'quantity': instance.quantity,
  'dueDate': ?instance.dueDate?.toIso8601String(),
  'modelName': instance.modelName,
  'modelCategory': ?instance.modelCategory,
  'clientName': instance.clientName,
  'completedQuantity': instance.completedQuantity,
  'totalCompletedQuantity': instance.totalCompletedQuantity,
  'loggedHours': instance.loggedHours,
};

EmployeeWorkLog _$EmployeeWorkLogFromJson(Map<String, dynamic> json) =>
    EmployeeWorkLog(
      id: json['id'] as String,
      step: json['step'] as String,
      quantity: (json['quantity'] as num).toInt(),
      hours: (json['hours'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      order: EmployeeWorkLogOrder.fromJson(
        json['order'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$EmployeeWorkLogToJson(EmployeeWorkLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'step': instance.step,
      'quantity': instance.quantity,
      'hours': instance.hours,
      'date': instance.date.toIso8601String(),
      'order': instance.order.toJson(),
    };

EmployeeWorkLogOrder _$EmployeeWorkLogOrderFromJson(
  Map<String, dynamic> json,
) => EmployeeWorkLogOrder(
  id: json['id'] as String,
  modelName: json['modelName'] as String,
  clientName: json['clientName'] as String,
);

Map<String, dynamic> _$EmployeeWorkLogOrderToJson(
  EmployeeWorkLogOrder instance,
) => <String, dynamic>{
  'id': instance.id,
  'modelName': instance.modelName,
  'clientName': instance.clientName,
};

EmployeePayroll _$EmployeePayrollFromJson(Map<String, dynamic> json) =>
    EmployeePayroll(
      id: json['id'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      totalPayout: (json['totalPayout'] as num).toDouble(),
      workLogs: (json['workLogs'] as List<dynamic>)
          .map(
            (e) => EmployeePayrollWorkLog.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$EmployeePayrollToJson(EmployeePayroll instance) =>
    <String, dynamic>{
      'id': instance.id,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'totalPayout': instance.totalPayout,
      'workLogs': instance.workLogs.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

EmployeePayrollWorkLog _$EmployeePayrollWorkLogFromJson(
  Map<String, dynamic> json,
) => EmployeePayrollWorkLog(
  step: json['step'] as String,
  quantity: (json['quantity'] as num).toInt(),
  hours: (json['hours'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
  modelName: json['modelName'] as String?,
);

Map<String, dynamic> _$EmployeePayrollWorkLogToJson(
  EmployeePayrollWorkLog instance,
) => <String, dynamic>{
  'step': instance.step,
  'quantity': instance.quantity,
  'hours': instance.hours,
  'date': instance.date.toIso8601String(),
  'modelName': ?instance.modelName,
};

CreateWorkLogRequest _$CreateWorkLogRequestFromJson(
  Map<String, dynamic> json,
) => CreateWorkLogRequest(
  assignmentId: json['assignmentId'] as String,
  quantity: (json['quantity'] as num).toInt(),
  hours: (json['hours'] as num?)?.toDouble(),
  date: json['date'] as String,
);

Map<String, dynamic> _$CreateWorkLogRequestToJson(
  CreateWorkLogRequest instance,
) => <String, dynamic>{
  'assignmentId': instance.assignmentId,
  'quantity': instance.quantity,
  'hours': ?instance.hours,
  'date': instance.date,
};

EmployeeAssignmentsResponse _$EmployeeAssignmentsResponseFromJson(
  Map<String, dynamic> json,
) => EmployeeAssignmentsResponse(
  assignments: (json['assignments'] as List<dynamic>)
      .map((e) => EmployeeAssignment.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EmployeeAssignmentsResponseToJson(
  EmployeeAssignmentsResponse instance,
) => <String, dynamic>{
  'assignments': instance.assignments.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
