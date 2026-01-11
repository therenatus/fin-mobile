class Employee {
  final String id;
  final String name;
  final String role;
  final String? phone;
  final String? email;
  final bool isActive;
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

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
    };
  }
}

/// Роль сотрудника из БД
class EmployeeRole {
  final String id;
  final String code;
  final String label;
  final int sortOrder;

  EmployeeRole({
    required this.id,
    required this.code,
    required this.label,
    required this.sortOrder,
  });

  factory EmployeeRole.fromJson(Map<String, dynamic> json) {
    return EmployeeRole(
      id: json['id'] as String,
      code: json['code'] as String,
      label: json['label'] as String,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  @override
  String toString() => label;
}
