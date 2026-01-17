// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String?,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  basePrice: (json['basePrice'] as num).toDouble(),
  processSteps:
      (json['processSteps'] as List<dynamic>?)
          ?.map((e) => ProcessStep.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': ?instance.category,
      'description': ?instance.description,
      'imageUrl': ?instance.imageUrl,
      'basePrice': instance.basePrice,
      'processSteps': instance.processSteps.map((e) => e.toJson()).toList(),
    };

OrderStatusLog _$OrderStatusLogFromJson(Map<String, dynamic> json) =>
    OrderStatusLog(
      id: json['id'] as String,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$OrderStatusLogToJson(OrderStatusLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'timestamp': instance.timestamp.toIso8601String(),
      'notes': ?instance.notes,
    };

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: json['id'] as String,
  clientId: json['clientId'] as String,
  modelId: json['modelId'] as String,
  quantity: (json['quantity'] as num).toInt(),
  status: const OrderStatusConverter().fromJson(json['status'] as String),
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  client: json['client'] == null
      ? null
      : Client.fromJson(json['client'] as Map<String, dynamic>),
  model: json['model'] == null
      ? null
      : OrderModel.fromJson(json['model'] as Map<String, dynamic>),
  statusLogs:
      (json['statusLogs'] as List<dynamic>?)
          ?.map((e) => OrderStatusLog.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'clientId': instance.clientId,
  'modelId': instance.modelId,
  'quantity': instance.quantity,
  'status': const OrderStatusConverter().toJson(instance.status),
  'dueDate': ?instance.dueDate?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'client': ?instance.client?.toJson(),
  'model': ?instance.model?.toJson(),
  'statusLogs': instance.statusLogs.map((e) => e.toJson()).toList(),
};

OrdersResponse _$OrdersResponseFromJson(Map<String, dynamic> json) =>
    OrdersResponse(
      orders: (json['orders'] as List<dynamic>)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: OrdersMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrdersResponseToJson(OrdersResponse instance) =>
    <String, dynamic>{
      'orders': instance.orders.map((e) => e.toJson()).toList(),
      'meta': instance.meta.toJson(),
    };

OrdersMeta _$OrdersMetaFromJson(Map<String, dynamic> json) => OrdersMeta(
  page: (json['page'] as num).toInt(),
  perPage: (json['perPage'] as num).toInt(),
  total: (json['total'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
);

Map<String, dynamic> _$OrdersMetaToJson(OrdersMeta instance) =>
    <String, dynamic>{
      'page': instance.page,
      'perPage': instance.perPage,
      'total': instance.total,
      'totalPages': instance.totalPages,
    };
