import 'pagination_meta.dart';

class EmployeeUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String tenantId;
  final String tenantName;
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

  factory EmployeeUser.fromJson(Map<String, dynamic> json) {
    return EmployeeUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      tenantId: json['tenantId'] as String,
      tenantName: json['tenantName'] as String,
      isActive: json['isActive'] as bool? ?? true,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'isActive': isActive,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }
}

class EmployeeAuthResponse {
  final String accessToken;
  final String refreshToken;
  final EmployeeUser user;

  EmployeeAuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory EmployeeAuthResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeAuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: EmployeeUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

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

  factory EmployeeAssignment.fromJson(Map<String, dynamic> json) {
    return EmployeeAssignment(
      id: json['id'] as String,
      stepName: json['stepName'] as String,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      order: EmployeeAssignmentOrder.fromJson(json['order'] as Map<String, dynamic>),
    );
  }
}

class EmployeeAssignmentOrder {
  final String id;
  final String status;
  final int quantity;
  final DateTime? dueDate;
  final String modelName;
  final String? modelCategory;
  final String clientName;
  final int completedQuantity;      // This employee's progress
  final int totalCompletedQuantity; // ALL employees' progress for this step
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
    final completedQty = json['completedQuantity'] as int? ?? 0;
    return EmployeeAssignmentOrder(
      id: json['id'] as String,
      status: json['status'] as String,
      quantity: json['quantity'] as int,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      modelName: json['modelName'] as String,
      modelCategory: json['modelCategory'] as String?,
      clientName: json['clientName'] as String,
      completedQuantity: completedQty,
      // Use totalCompletedQuantity if available, fallback to completedQuantity for backwards compatibility
      totalCompletedQuantity: json['totalCompletedQuantity'] as int? ?? completedQty,
      loggedHours: (json['loggedHours'] as num?)?.toDouble() ?? 0,
    );
  }

  /// This employee's remaining work
  int get remaining => quantity - completedQuantity;

  /// Total remaining work for this step (considering ALL employees)
  int get totalRemaining => quantity - totalCompletedQuantity;

  /// Whether this step is fully completed by any employees
  bool get isStepCompleted => totalCompletedQuantity >= quantity;

  double get progressPercent => quantity > 0 ? completedQuantity / quantity : 0;
  double get totalProgressPercent => quantity > 0 ? totalCompletedQuantity / quantity : 0;
}

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

  factory EmployeeWorkLog.fromJson(Map<String, dynamic> json) {
    return EmployeeWorkLog(
      id: json['id'] as String,
      step: json['step'] as String,
      quantity: json['quantity'] as int,
      hours: (json['hours'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      order: EmployeeWorkLogOrder.fromJson(json['order'] as Map<String, dynamic>),
    );
  }
}

class EmployeeWorkLogOrder {
  final String id;
  final String modelName;
  final String clientName;

  EmployeeWorkLogOrder({
    required this.id,
    required this.modelName,
    required this.clientName,
  });

  factory EmployeeWorkLogOrder.fromJson(Map<String, dynamic> json) {
    return EmployeeWorkLogOrder(
      id: json['id'] as String,
      modelName: json['modelName'] as String,
      clientName: json['clientName'] as String,
    );
  }
}

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

  factory EmployeePayroll.fromJson(Map<String, dynamic> json) {
    return EmployeePayroll(
      id: json['id'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      totalPayout: (json['totalPayout'] as num).toDouble(),
      workLogs: (json['workLogs'] as List<dynamic>)
          .map((e) => EmployeePayrollWorkLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

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

  factory EmployeePayrollWorkLog.fromJson(Map<String, dynamic> json) {
    return EmployeePayrollWorkLog(
      step: json['step'] as String,
      quantity: json['quantity'] as int,
      hours: (json['hours'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      modelName: json['modelName'] as String?,
    );
  }
}

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

  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'quantity': quantity,
      if (hours != null) 'hours': hours,
      'date': date,
    };
  }
}

class EmployeeAssignmentsResponse {
  final List<EmployeeAssignment> assignments;
  final PaginationMeta meta;

  EmployeeAssignmentsResponse({required this.assignments, required this.meta});

  factory EmployeeAssignmentsResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeAssignmentsResponse(
      assignments: (json['assignments'] as List<dynamic>)
          .map((e) => EmployeeAssignment.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}
