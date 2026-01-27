import 'package:json_annotation/json_annotation.dart';
import 'client.dart';
import 'process_step.dart';
import 'json_converters.dart';

part 'order.g.dart';

enum OrderStatus {
  pending('pending', 'Ожидает'),
  inProgress('in_progress', 'В работе'),
  completed('completed', 'Выполнен'),
  cancelled('cancelled', 'Отменён');

  final String value;
  final String label;
  const OrderStatus(this.value, this.label);

  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => OrderStatus.pending,
    );
  }
}

@JsonSerializable()
class OrderModel {
  final String id;
  final String name;
  final String? category;
  final String? description;
  final String? imageUrl;
  final double basePrice;
  @JsonKey(defaultValue: [])
  final List<ProcessStep> processSteps;

  OrderModel({
    required this.id,
    required this.name,
    this.category,
    this.description,
    this.imageUrl,
    required this.basePrice,
    this.processSteps = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  /// Total estimated time for all process steps in minutes
  int get totalEstimatedTime =>
      processSteps.fold(0, (sum, step) => sum + step.estimatedTime);

  /// Total labor cost based on process step rates
  double get totalLaborCost => processSteps.fold(
      0.0, (sum, step) => sum + (step.rate ?? 0));
}

@JsonSerializable()
class OrderStatusLog {
  final String id;
  final String status;
  final DateTime timestamp;
  final String? notes;

  OrderStatusLog({
    required this.id,
    required this.status,
    required this.timestamp,
    this.notes,
  });

  factory OrderStatusLog.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusLogFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatusLogToJson(this);
}

@JsonSerializable()
class Order {
  final String id;
  final String clientId;
  final String modelId;
  final int quantity;
  @OrderStatusConverter()
  final OrderStatus status;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Client? client;
  final OrderModel? model;
  @JsonKey(defaultValue: [])
  final List<OrderStatusLog> statusLogs;

  Order({
    required this.id,
    required this.clientId,
    required this.modelId,
    required this.quantity,
    required this.status,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.client,
    this.model,
    this.statusLogs = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);

  double get totalPrice => (model?.basePrice ?? 0) * quantity;

  bool get isOverdue {
    if (dueDate == null) return false;
    if (status == OrderStatus.completed || status == OrderStatus.cancelled) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  int get daysUntilDue {
    if (dueDate == null) return 0;
    return dueDate!.difference(DateTime.now()).inDays;
  }
}

@JsonSerializable()
class OrdersResponse {
  final List<Order> orders;
  final OrdersMeta meta;

  OrdersResponse({required this.orders, required this.meta});

  factory OrdersResponse.fromJson(Map<String, dynamic> json) =>
      _$OrdersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrdersResponseToJson(this);
}

@JsonSerializable()
class OrdersMeta {
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(defaultValue: 20)
  final int perPage;
  @JsonKey(defaultValue: 0)
  final int total;
  @JsonKey(defaultValue: 0)
  final int totalPages;

  OrdersMeta({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory OrdersMeta.fromJson(Map<String, dynamic> json) =>
      _$OrdersMetaFromJson(json);

  Map<String, dynamic> toJson() => _$OrdersMetaToJson(this);
}
