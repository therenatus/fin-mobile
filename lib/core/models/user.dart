import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class Plan {
  final String id;
  final String name;
  @JsonKey(defaultValue: 0.0)
  final double price;

  Plan({
    required this.id,
    required this.name,
    required this.price,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);

  Map<String, dynamic> toJson() => _$PlanToJson(this);
}

@JsonSerializable()
class Tenant {
  final String id;
  final String name;
  final Plan? plan;

  Tenant({
    required this.id,
    required this.name,
    this.plan,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);

  Map<String, dynamic> toJson() => _$TenantToJson(this);
}

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String tenantId;
  final Tenant? tenant;
  @JsonKey(defaultValue: [])
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

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool get isAdmin => roles.contains('tenant-admin') || roles.contains('admin');

  bool get isManager => roles.contains('manager');

  bool get canEditClients => isAdmin;
}

@JsonSerializable()
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
