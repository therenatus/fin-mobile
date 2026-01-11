import 'pagination_meta.dart';

class ClientUser {
  final String id;
  final String? email;
  final String? phone;
  final String name;
  final bool isVerified;
  final List<TenantLink> tenants;

  ClientUser({
    required this.id,
    this.email,
    this.phone,
    required this.name,
    this.isVerified = false,
    this.tenants = const [],
  });

  factory ClientUser.fromJson(Map<String, dynamic> json) {
    return ClientUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      name: json['name'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
      tenants: (json['tenants'] as List<dynamic>?)
              ?.map((e) => TenantLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'name': name,
        'isVerified': isVerified,
      };
}

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

  factory TenantLink.fromJson(Map<String, dynamic> json) {
    return TenantLink(
      clientId: json['clientId'] as String,
      tenantId: json['tenantId'] as String,
      tenantName: json['tenantName'] as String,
      tenantDomain: json['tenantDomain'] as String?,
    );
  }
}

class ClientAuthResponse {
  final String accessToken;
  final String refreshToken;
  final ClientUser user;

  ClientAuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory ClientAuthResponse.fromJson(Map<String, dynamic> json) {
    return ClientAuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: ClientUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

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

  factory ClientOrder.fromJson(Map<String, dynamic> json) {
    return ClientOrder(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      tenantName: json['tenantName'] as String,
      model: ClientOrderModel.fromJson(json['model'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      status: json['status'] as String,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

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

  factory ClientOrderModel.fromJson(Map<String, dynamic> json) {
    return ClientOrderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      imageUrl: json['imageUrl'] as String?,
      basePrice: (json['basePrice'] as num?)?.toDouble(),
    );
  }
}

class ClientOrdersResponse {
  final List<ClientOrder> orders;
  final PaginationMeta meta;

  ClientOrdersResponse({required this.orders, required this.meta});

  factory ClientOrdersResponse.fromJson(Map<String, dynamic> json) {
    return ClientOrdersResponse(
      orders: (json['orders'] as List<dynamic>)
          .map((e) => ClientOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}
