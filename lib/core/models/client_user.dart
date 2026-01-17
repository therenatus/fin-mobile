import 'package:json_annotation/json_annotation.dart';
import 'pagination_meta.dart';

part 'client_user.g.dart';

@JsonSerializable()
class ClientUser {
  final String id;
  final String? email;
  final String? phone;
  final String name;
  @JsonKey(defaultValue: false)
  final bool isVerified;
  @JsonKey(defaultValue: [])
  final List<TenantLink> tenants;

  ClientUser({
    required this.id,
    this.email,
    this.phone,
    required this.name,
    this.isVerified = false,
    this.tenants = const [],
  });

  factory ClientUser.fromJson(Map<String, dynamic> json) =>
      _$ClientUserFromJson(json);

  Map<String, dynamic> toJson() => _$ClientUserToJson(this);
}

@JsonSerializable()
class TenantLink {
  final String clientId;
  final String tenantId;
  final String tenantName;
  final String? tenantDomain;

  TenantLink({
    required this.clientId,
    required this.tenantId,
    required this.tenantName,
    this.tenantDomain,
  });

  factory TenantLink.fromJson(Map<String, dynamic> json) =>
      _$TenantLinkFromJson(json);

  Map<String, dynamic> toJson() => _$TenantLinkToJson(this);
}

@JsonSerializable()
class ClientAuthResponse {
  final String accessToken;
  final String refreshToken;
  final ClientUser user;

  ClientAuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory ClientAuthResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientAuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ClientAuthResponseToJson(this);
}

@JsonSerializable()
class ClientOrder {
  final String id;
  final String tenantId;
  final String tenantName;
  final ClientOrderModel model;
  final int quantity;
  final String status;
  final DateTime? dueDate;
  final DateTime createdAt;

  ClientOrder({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.model,
    required this.quantity,
    required this.status,
    this.dueDate,
    required this.createdAt,
  });

  factory ClientOrder.fromJson(Map<String, dynamic> json) =>
      _$ClientOrderFromJson(json);

  Map<String, dynamic> toJson() => _$ClientOrderToJson(this);

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Ожидает';
      case 'in_progress':
        return 'В работе';
      case 'completed':
        return 'Готово';
      case 'cancelled':
        return 'Отменён';
      default:
        return status;
    }
  }

  double get totalCost => (model.basePrice ?? 0) * quantity;
}

@JsonSerializable()
class ClientOrderModel {
  final String id;
  final String name;
  final String? category;
  final String? imageUrl;
  final double? basePrice;

  ClientOrderModel({
    required this.id,
    required this.name,
    this.category,
    this.imageUrl,
    this.basePrice,
  });

  factory ClientOrderModel.fromJson(Map<String, dynamic> json) =>
      _$ClientOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClientOrderModelToJson(this);
}

@JsonSerializable()
class ClientOrdersResponse {
  final List<ClientOrder> orders;
  final PaginationMeta meta;

  ClientOrdersResponse({required this.orders, required this.meta});

  factory ClientOrdersResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientOrdersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ClientOrdersResponseToJson(this);
}
