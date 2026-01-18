import 'package:json_annotation/json_annotation.dart';

part 'production_plan.g.dart';

// ==================== ENUMS ====================

enum PlanStatus {
  draft('DRAFT', 'Черновик'),
  scheduled('SCHEDULED', 'Запланирован'),
  inProgress('IN_PROGRESS', 'В работе'),
  completed('COMPLETED', 'Завершён'),
  cancelled('CANCELLED', 'Отменён');

  final String value;
  final String label;
  const PlanStatus(this.value, this.label);

  static PlanStatus fromString(String status) {
    return PlanStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => PlanStatus.draft,
    );
  }
}

enum TaskStatus {
  pending('PENDING', 'Ожидает'),
  ready('READY', 'Готов к работе'),
  inProgress('IN_PROGRESS', 'В работе'),
  completed('COMPLETED', 'Выполнен'),
  blocked('BLOCKED', 'Заблокирован');

  final String value;
  final String label;
  const TaskStatus(this.value, this.label);

  static TaskStatus fromString(String status) {
    return TaskStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => TaskStatus.pending,
    );
  }
}

// ==================== CONVERTERS ====================

class PlanStatusConverter implements JsonConverter<PlanStatus, String> {
  const PlanStatusConverter();

  @override
  PlanStatus fromJson(String json) => PlanStatus.fromString(json);

  @override
  String toJson(PlanStatus status) => status.value;
}

class TaskStatusConverter implements JsonConverter<TaskStatus, String> {
  const TaskStatusConverter();

  @override
  TaskStatus fromJson(String json) => TaskStatus.fromString(json);

  @override
  String toJson(TaskStatus status) => status.value;
}

// ==================== ASSIGNEE SUMMARY ====================

@JsonSerializable()
class AssigneeSummary {
  final String id;
  final String name;
  final String? role;

  AssigneeSummary({
    required this.id,
    required this.name,
    this.role,
  });

  factory AssigneeSummary.fromJson(Map<String, dynamic> json) =>
      _$AssigneeSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AssigneeSummaryToJson(this);
}

// ==================== PRODUCTION TASK ====================

@JsonSerializable()
class ProductionTask {
  final String id;
  final String planId;
  final String operationName;
  final int sequence;
  final DateTime plannedStart;
  final DateTime plannedEnd;
  final double plannedHours;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final double? actualHours;
  final String? assigneeId;
  final AssigneeSummary? assignee;
  @TaskStatusConverter()
  final TaskStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductionTask({
    required this.id,
    required this.planId,
    required this.operationName,
    required this.sequence,
    required this.plannedStart,
    required this.plannedEnd,
    required this.plannedHours,
    this.actualStart,
    this.actualEnd,
    this.actualHours,
    this.assigneeId,
    this.assignee,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductionTask.fromJson(Map<String, dynamic> json) =>
      _$ProductionTaskFromJson(json);

  Map<String, dynamic> toJson() => _$ProductionTaskToJson(this);

  /// Progress percentage (0-100)
  int get progressPercent {
    if (status == TaskStatus.completed) return 100;
    if (actualHours != null && plannedHours > 0) {
      return (actualHours! / plannedHours * 100).clamp(0, 100).round();
    }
    return status == TaskStatus.inProgress ? 50 : 0;
  }

  /// Check if task is overdue
  bool get isOverdue {
    if (status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(plannedEnd);
  }

  /// Planned duration in days
  int get plannedDays {
    return plannedEnd.difference(plannedStart).inDays + 1;
  }
}

// ==================== ORDER SUMMARY ====================

@JsonSerializable()
class PlanOrderSummary {
  final String id;
  final int quantity;
  final ClientSummary? client;
  final OrderModelSummary? model;

  PlanOrderSummary({
    required this.id,
    required this.quantity,
    this.client,
    this.model,
  });

  factory PlanOrderSummary.fromJson(Map<String, dynamic> json) =>
      _$PlanOrderSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$PlanOrderSummaryToJson(this);
}

@JsonSerializable()
class ClientSummary {
  final String id;
  final String name;

  ClientSummary({required this.id, required this.name});

  factory ClientSummary.fromJson(Map<String, dynamic> json) =>
      _$ClientSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ClientSummaryToJson(this);
}

@JsonSerializable()
class OrderModelSummary {
  final String id;
  final String name;
  final double? basePrice;

  OrderModelSummary({
    required this.id,
    required this.name,
    this.basePrice,
  });

  factory OrderModelSummary.fromJson(Map<String, dynamic> json) =>
      _$OrderModelSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelSummaryToJson(this);
}

// ==================== PRODUCTION PLAN ====================

@JsonSerializable()
class ProductionPlan {
  final String id;
  final String tenantId;
  final String orderId;
  @PlanStatusConverter()
  final PlanStatus status;
  final DateTime plannedStart;
  final DateTime plannedEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  @JsonKey(defaultValue: [])
  final List<ProductionTask> tasks;
  final PlanOrderSummary? order;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductionPlan({
    required this.id,
    required this.tenantId,
    required this.orderId,
    required this.status,
    required this.plannedStart,
    required this.plannedEnd,
    this.actualStart,
    this.actualEnd,
    this.tasks = const [],
    this.order,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductionPlan.fromJson(Map<String, dynamic> json) =>
      _$ProductionPlanFromJson(json);

  Map<String, dynamic> toJson() => _$ProductionPlanToJson(this);

  /// Order info string
  String get orderInfo {
    if (order == null) return 'Заказ #$orderId';
    final client = order!.client?.name ?? 'Неизвестный';
    final model = order!.model?.name ?? 'Без модели';
    return '$client - $model (x${order!.quantity})';
  }

  /// Total planned hours
  double get totalPlannedHours =>
      tasks.fold(0.0, (sum, t) => sum + t.plannedHours);

  /// Total actual hours
  double get totalActualHours =>
      tasks.fold(0.0, (sum, t) => sum + (t.actualHours ?? 0));

  /// Completed tasks count
  int get completedTasksCount =>
      tasks.where((t) => t.status == TaskStatus.completed).length;

  /// Progress percentage
  int get progressPercent {
    if (tasks.isEmpty) return 0;
    return (completedTasksCount / tasks.length * 100).round();
  }

  /// Planned duration in days
  int get plannedDays => plannedEnd.difference(plannedStart).inDays + 1;

  /// Is plan overdue
  bool get isOverdue {
    if (status == PlanStatus.completed || status == PlanStatus.cancelled) {
      return false;
    }
    return DateTime.now().isAfter(plannedEnd);
  }
}

// ==================== RESPONSE ====================

@JsonSerializable()
class PlansResponse {
  final List<ProductionPlan> plans;
  final PlansMeta meta;

  PlansResponse({required this.plans, required this.meta});

  factory PlansResponse.fromJson(Map<String, dynamic> json) =>
      _$PlansResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PlansResponseToJson(this);
}

@JsonSerializable()
class PlansMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PlansMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PlansMeta.fromJson(Map<String, dynamic> json) =>
      _$PlansMetaFromJson(json);

  Map<String, dynamic> toJson() => _$PlansMetaToJson(this);
}

@JsonSerializable()
class TasksResponse {
  final List<ProductionTask> tasks;
  final PlansMeta meta;

  TasksResponse({required this.tasks, required this.meta});

  factory TasksResponse.fromJson(Map<String, dynamic> json) =>
      _$TasksResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TasksResponseToJson(this);
}
