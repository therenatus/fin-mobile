class Plan {
  final String id;
  final String name;
  final double price;

  Plan({
    required this.id,
    required this.name,
    required this.price,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}

class Tenant {
  final String id;
  final String name;
  final Plan? plan;

  Tenant({
    required this.id,
    required this.name,
    this.plan,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      name: json['name'] as String,
      plan: json['plan'] != null ? Plan.fromJson(json['plan'] as Map<String, dynamic>) : null,
    );
  }
}

class User {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String tenantId;
  final Tenant? tenant;
  final List<String> roles;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.tenantId,
    this.tenant,
    required this.roles,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      tenantId: json['tenantId'] as String,
      tenant: json['tenant'] != null ? Tenant.fromJson(json['tenant'] as Map<String, dynamic>) : null,
      roles: List<String>.from(json['roles'] ?? []),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'tenantId': tenantId,
      'roles': roles,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  bool get isAdmin => roles.contains('tenant-admin') || roles.contains('admin');

  bool get isManager => roles.contains('manager');

  /// Менеджеры не могут редактировать заказчиков
  bool get canEditClients => isAdmin;
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
