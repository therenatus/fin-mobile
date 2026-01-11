import 'client.dart';
import 'process_step.dart';

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

class OrderModel {
  final String id;
  final String name;
  final String? category;
  final String? description;
  final String? imageUrl;
  final double basePrice;
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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      basePrice: (json['basePrice'] as num).toDouble(),
      processSteps: (json['processSteps'] as List<dynamic>?)
              ?.map((e) => ProcessStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Total estimated time for all process steps in minutes
  int get totalEstimatedTime =>
      processSteps.fold(0, (sum, step) => sum + step.estimatedTime);

  /// Total labor cost based on process step rates
  double get totalLaborCost => processSteps.fold(
      0.0, (sum, step) => sum + (step.rate ?? 0));
}

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

  factory OrderStatusLog.fromJson(Map<String, dynamic> json) {
    return OrderStatusLog(
      id: json['id'] as String,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
    );
  }
}

class Order {
  final String id;
  final String clientId;
  final String modelId;
  final int quantity;
  final OrderStatus status;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Client? client;
  final OrderModel? model;
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

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      modelId: json['modelId'] as String,
      quantity: json['quantity'] as int,
      status: OrderStatus.fromString(json['status'] as String),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      client: json['client'] != null ? Client.fromJson(json['client'] as Map<String, dynamic>) : null,
      model: json['model'] != null ? OrderModel.fromJson(json['model'] as Map<String, dynamic>) : null,
      statusLogs: (json['statusLogs'] as List<dynamic>?)
          ?.map((e) => OrderStatusLog.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

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

class OrdersResponse {
  final List<Order> orders;
  final OrdersMeta meta;

  OrdersResponse({required this.orders, required this.meta});

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      orders: (json['orders'] as List<dynamic>)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: OrdersMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class OrdersMeta {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  OrdersMeta({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory OrdersMeta.fromJson(Map<String, dynamic> json) {
    return OrdersMeta(
      page: json['page'] as int,
      perPage: json['perPage'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
