import 'package:json_annotation/json_annotation.dart';
import 'pagination_meta.dart';

part 'employee_user.g.dart';

@JsonSerializable()
class EmployeeUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String tenantId;
  final String tenantName;
  @JsonKey(defaultValue: true)
  final bool isActive;
  final DateTime? lastLoginAt;

  EmployeeUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    required this.tenantId,
    required this.tenantName,
    this.isActive = true,
    this.lastLoginAt,
  });

  factory EmployeeUser.fromJson(Map<String, dynamic> json) =>
      _$EmployeeUserFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeUserToJson(this);
}

@JsonSerializable()
class EmployeeAuthResponse {
  final String accessToken;
  final String refreshToken;
  final EmployeeUser user;

  EmployeeAuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory EmployeeAuthResponse.fromJson(Map<String, dynamic> json) =>
      _$EmployeeAuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeAuthResponseToJson(this);
}

@JsonSerializable()
class EmployeeAssignment {
  final String id;
  final String stepName;
  final DateTime assignedAt;
  final EmployeeAssignmentOrder order;

  EmployeeAssignment({
    required this.id,
    required this.stepName,
    required this.assignedAt,
    required this.order,
  });

  factory EmployeeAssignment.fromJson(Map<String, dynamic> json) =>
      _$EmployeeAssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeAssignmentToJson(this);
}

@JsonSerializable(createFactory: false)
class EmployeeAssignmentOrder {
  final String id;
  final String status;
  final int quantity;
  final DateTime? dueDate;
  final String modelName;
  final String? modelCategory;
  final String clientName;
  @JsonKey(defaultValue: 0)
  final int completedQuantity;      // This employee's progress
  @JsonKey(defaultValue: 0)
  final int totalCompletedQuantity; // ALL employees' progress for this step
  @JsonKey(defaultValue: 0.0)
  final double loggedHours;

  EmployeeAssignmentOrder({
    required this.id,
    required this.status,
    required this.quantity,
    this.dueDate,
    required this.modelName,
    this.modelCategory,
    required this.clientName,
    this.completedQuantity = 0,
    this.totalCompletedQuantity = 0,
    this.loggedHours = 0,
  });

  factory EmployeeAssignmentOrder.fromJson(Map<String, dynamic> json) {
    final completedQty = (json['completedQuantity'] as num?)?.toInt() ?? 0;
    // Fallback totalCompletedQuantity to completedQuantity for backwards compatibility
    final totalCompletedQty = json['totalCompletedQuantity'] != null
        ? (json['totalCompletedQuantity'] as num).toInt()
        : completedQty;

    return EmployeeAssignmentOrder(
      id: json['id'] as String,
      status: json['status'] as String,
      quantity: (json['quantity'] as num).toInt(),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      modelName: json['modelName'] as String,
      modelCategory: json['modelCategory'] as String?,
      clientName: json['clientName'] as String,
      completedQuantity: completedQty,
      totalCompletedQuantity: totalCompletedQty,
      loggedHours: (json['loggedHours'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => _$EmployeeAssignmentOrderToJson(this);

  /// This employee's remaining work
  int get remaining => quantity - completedQuantity;

  /// Total remaining work for this step (considering ALL employees)
  int get totalRemaining => quantity - totalCompletedQuantity;

  /// Whether this step is fully completed by any employees
  bool get isStepCompleted => totalCompletedQuantity >= quantity;

  double get progressPercent => quantity > 0 ? completedQuantity / quantity : 0;
  double get totalProgressPercent => quantity > 0 ? totalCompletedQuantity / quantity : 0;
}

@JsonSerializable()
class EmployeeWorkLog {
  final String id;
  final String step;
  final int quantity;
  final double hours;
  final DateTime date;
  final EmployeeWorkLogOrder order;

  EmployeeWorkLog({
    required this.id,
    required this.step,
    required this.quantity,
    required this.hours,
    required this.date,
    required this.order,
  });

  factory EmployeeWorkLog.fromJson(Map<String, dynamic> json) =>
      _$EmployeeWorkLogFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeWorkLogToJson(this);
}

@JsonSerializable()
class EmployeeWorkLogOrder {
  final String id;
  final String modelName;
  final String clientName;

  EmployeeWorkLogOrder({
    required this.id,
    required this.modelName,
    required this.clientName,
  });

  factory EmployeeWorkLogOrder.fromJson(Map<String, dynamic> json) =>
      _$EmployeeWorkLogOrderFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeWorkLogOrderToJson(this);
}

@JsonSerializable()
class EmployeePayroll {
  final String id;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalPayout;
  final List<EmployeePayrollWorkLog> workLogs;
  final DateTime createdAt;

  EmployeePayroll({
    required this.id,
    required this.periodStart,
    required this.periodEnd,
    required this.totalPayout,
    required this.workLogs,
    required this.createdAt,
  });

  factory EmployeePayroll.fromJson(Map<String, dynamic> json) =>
      _$EmployeePayrollFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeePayrollToJson(this);
}

@JsonSerializable()
class EmployeePayrollWorkLog {
  final String step;
  final int quantity;
  final double hours;
  final DateTime date;
  final String? modelName;

  EmployeePayrollWorkLog({
    required this.step,
    required this.quantity,
    required this.hours,
    required this.date,
    this.modelName,
  });

  factory EmployeePayrollWorkLog.fromJson(Map<String, dynamic> json) =>
      _$EmployeePayrollWorkLogFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeePayrollWorkLogToJson(this);
}

@JsonSerializable()
class CreateWorkLogRequest {
  final String assignmentId;
  final int quantity;
  final double? hours;
  final String date;

  CreateWorkLogRequest({
    required this.assignmentId,
    required this.quantity,
    this.hours,
    required this.date,
  });

  factory CreateWorkLogRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWorkLogRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateWorkLogRequestToJson(this);
}

@JsonSerializable()
class EmployeeAssignmentsResponse {
  final List<EmployeeAssignment> assignments;
  final PaginationMeta meta;

  EmployeeAssignmentsResponse({required this.assignments, required this.meta});

  factory EmployeeAssignmentsResponse.fromJson(Map<String, dynamic> json) =>
      _$EmployeeAssignmentsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeAssignmentsResponseToJson(this);
}
