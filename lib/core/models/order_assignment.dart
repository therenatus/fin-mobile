import 'employee.dart';

/// Назначение сотрудника на этап заказа
class OrderAssignment {
  final String id;
  final String orderId;
  final String stepName;
  final String employeeId;
  final Employee? employee;
  final DateTime assignedAt;

  OrderAssignment({
    required this.id,
    required this.orderId,
    required this.stepName,
    required this.employeeId,
    this.employee,
    required this.assignedAt,
  });

  factory OrderAssignment.fromJson(Map<String, dynamic> json) {
    return OrderAssignment(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      stepName: json['stepName'] as String,
      employeeId: json['employeeId'] as String,
      employee: json['employee'] != null
          ? Employee.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepName': stepName,
      'employeeId': employeeId,
    };
  }
}
