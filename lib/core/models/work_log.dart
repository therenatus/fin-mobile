import 'employee.dart';
import 'order.dart';

class WorkLog {
  final String id;
  final String employeeId;
  final String orderId;
  final String step;
  final int quantity;
  final double hours;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Employee? employee;
  final Order? order;
  // Payroll-specific fields
  final String? modelName;
  final double? rate;
  final String? rateType;
  final double? payout;

  WorkLog({
    required this.id,
    required this.employeeId,
    required this.orderId,
    required this.step,
    required this.quantity,
    required this.hours,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.employee,
    this.order,
    this.modelName,
    this.rate,
    this.rateType,
    this.payout,
  });

  factory WorkLog.fromJson(Map<String, dynamic> json) {
    return WorkLog(
      id: json['id'] as String? ?? '',
      employeeId: json['employeeId'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      step: json['step'] as String,
      quantity: json['quantity'] as int,
      hours: (json['hours'] as num?)?.toDouble() ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      employee: json['employee'] != null
          ? Employee.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
      order: json['order'] != null
          ? Order.fromJson(json['order'] as Map<String, dynamic>)
          : null,
      modelName: json['modelName'] as String?,
      rate: (json['rate'] as num?)?.toDouble(),
      rateType: json['rateType'] as String?,
      payout: (json['payout'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'orderId': orderId,
      'step': step,
      'quantity': quantity,
      'hours': hours,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
