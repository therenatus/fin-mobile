// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plan _$PlanFromJson(Map<String, dynamic> json) => Plan(
  id: json['id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$PlanToJson(Plan instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
};

Tenant _$TenantFromJson(Map<String, dynamic> json) => Tenant(
  id: json['id'] as String,
  name: json['name'] as String,
  plan: json['plan'] == null
      ? null
      : Plan.fromJson(json['plan'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TenantToJson(Tenant instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'plan': ?instance.plan?.toJson(),
};

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  tenantId: json['tenantId'] as String,
  tenant: json['tenant'] == null
      ? null
      : Tenant.fromJson(json['tenant'] as Map<String, dynamic>),
  roles:
      (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': ?instance.name,
  'avatarUrl': ?instance.avatarUrl,
  'tenantId': instance.tenantId,
  'tenant': ?instance.tenant?.toJson(),
  'roles': instance.roles,
  'createdAt': ?instance.createdAt?.toIso8601String(),
  'updatedAt': ?instance.updatedAt?.toIso8601String(),
};

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'user': instance.user.toJson(),
    };
