// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientUser _$ClientUserFromJson(Map<String, dynamic> json) => ClientUser(
  id: json['id'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  name: json['name'] as String,
  isVerified: json['isVerified'] as bool? ?? false,
  tenants:
      (json['tenants'] as List<dynamic>?)
          ?.map((e) => TenantLink.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$ClientUserToJson(ClientUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.email case final value?) 'email': value,
      if (instance.phone case final value?) 'phone': value,
      'name': instance.name,
      'isVerified': instance.isVerified,
      'tenants': instance.tenants.map((e) => e.toJson()).toList(),
    };

TenantLink _$TenantLinkFromJson(Map<String, dynamic> json) => TenantLink(
  clientId: json['clientId'] as String,
  tenantId: json['tenantId'] as String,
  tenantName: json['tenantName'] as String,
  tenantDomain: json['tenantDomain'] as String?,
);

Map<String, dynamic> _$TenantLinkToJson(TenantLink instance) =>
    <String, dynamic>{
      'clientId': instance.clientId,
      'tenantId': instance.tenantId,
      'tenantName': instance.tenantName,
      if (instance.tenantDomain case final value?) 'tenantDomain': value,
    };

ClientAuthResponse _$ClientAuthResponseFromJson(Map<String, dynamic> json) =>
    ClientAuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: ClientUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ClientAuthResponseToJson(ClientAuthResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'user': instance.user.toJson(),
    };

ClientOrder _$ClientOrderFromJson(Map<String, dynamic> json) => ClientOrder(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  tenantName: json['tenantName'] as String,
  model: ClientOrderModel.fromJson(json['model'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num).toInt(),
  status: json['status'] as String,
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ClientOrderToJson(
  ClientOrder instance,
) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'tenantName': instance.tenantName,
  'model': instance.model.toJson(),
  'quantity': instance.quantity,
  'status': instance.status,
  if (instance.dueDate?.toIso8601String() case final value?) 'dueDate': value,
  'createdAt': instance.createdAt.toIso8601String(),
};

ClientOrderModel _$ClientOrderModelFromJson(Map<String, dynamic> json) =>
    ClientOrderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      imageUrl: json['imageUrl'] as String?,
      basePrice: (json['basePrice'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ClientOrderModelToJson(ClientOrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      if (instance.category case final value?) 'category': value,
      if (instance.imageUrl case final value?) 'imageUrl': value,
      if (instance.basePrice case final value?) 'basePrice': value,
    };

ClientOrdersResponse _$ClientOrdersResponseFromJson(
  Map<String, dynamic> json,
) => ClientOrdersResponse(
  orders: (json['orders'] as List<dynamic>)
      .map((e) => ClientOrder.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ClientOrdersResponseToJson(
  ClientOrdersResponse instance,
) => <String, dynamic>{
  'orders': instance.orders.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
