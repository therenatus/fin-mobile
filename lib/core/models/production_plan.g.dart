// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssigneeSummary _$AssigneeSummaryFromJson(Map<String, dynamic> json) =>
    AssigneeSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$AssigneeSummaryToJson(AssigneeSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      if (instance.role case final value?) 'role': value,
    };

ProductionTask _$ProductionTaskFromJson(Map<String, dynamic> json) =>
    ProductionTask(
      id: json['id'] as String,
      planId: json['planId'] as String,
      operationName: json['operationName'] as String,
      sequence: (json['sequence'] as num).toInt(),
      plannedStart: DateTime.parse(json['plannedStart'] as String),
      plannedEnd: DateTime.parse(json['plannedEnd'] as String),
      plannedHours: (json['plannedHours'] as num).toDouble(),
      actualStart: json['actualStart'] == null
          ? null
          : DateTime.parse(json['actualStart'] as String),
      actualEnd: json['actualEnd'] == null
          ? null
          : DateTime.parse(json['actualEnd'] as String),
      actualHours: (json['actualHours'] as num?)?.toDouble(),
      assigneeId: json['assigneeId'] as String?,
      assignee: json['assignee'] == null
          ? null
          : AssigneeSummary.fromJson(json['assignee'] as Map<String, dynamic>),
      status: const TaskStatusConverter().fromJson(json['status'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProductionTaskToJson(ProductionTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planId': instance.planId,
      'operationName': instance.operationName,
      'sequence': instance.sequence,
      'plannedStart': instance.plannedStart.toIso8601String(),
      'plannedEnd': instance.plannedEnd.toIso8601String(),
      'plannedHours': instance.plannedHours,
      if (instance.actualStart?.toIso8601String() case final value?)
        'actualStart': value,
      if (instance.actualEnd?.toIso8601String() case final value?)
        'actualEnd': value,
      if (instance.actualHours case final value?) 'actualHours': value,
      if (instance.assigneeId case final value?) 'assigneeId': value,
      if (instance.assignee?.toJson() case final value?) 'assignee': value,
      'status': const TaskStatusConverter().toJson(instance.status),
      if (instance.notes case final value?) 'notes': value,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

PlanOrderSummary _$PlanOrderSummaryFromJson(Map<String, dynamic> json) =>
    PlanOrderSummary(
      id: json['id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      client: json['client'] == null
          ? null
          : ClientSummary.fromJson(json['client'] as Map<String, dynamic>),
      model: json['model'] == null
          ? null
          : OrderModelSummary.fromJson(json['model'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlanOrderSummaryToJson(PlanOrderSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quantity': instance.quantity,
      if (instance.client?.toJson() case final value?) 'client': value,
      if (instance.model?.toJson() case final value?) 'model': value,
    };

ClientSummary _$ClientSummaryFromJson(Map<String, dynamic> json) =>
    ClientSummary(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$ClientSummaryToJson(ClientSummary instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

OrderModelSummary _$OrderModelSummaryFromJson(Map<String, dynamic> json) =>
    OrderModelSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      basePrice: (json['basePrice'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$OrderModelSummaryToJson(OrderModelSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      if (instance.basePrice case final value?) 'basePrice': value,
    };

ProductionPlan _$ProductionPlanFromJson(Map<String, dynamic> json) =>
    ProductionPlan(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      orderId: json['orderId'] as String,
      status: const PlanStatusConverter().fromJson(json['status'] as String),
      plannedStart: DateTime.parse(json['plannedStart'] as String),
      plannedEnd: DateTime.parse(json['plannedEnd'] as String),
      actualStart: json['actualStart'] == null
          ? null
          : DateTime.parse(json['actualStart'] as String),
      actualEnd: json['actualEnd'] == null
          ? null
          : DateTime.parse(json['actualEnd'] as String),
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map((e) => ProductionTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      order: json['order'] == null
          ? null
          : PlanOrderSummary.fromJson(json['order'] as Map<String, dynamic>),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProductionPlanToJson(ProductionPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'orderId': instance.orderId,
      'status': const PlanStatusConverter().toJson(instance.status),
      'plannedStart': instance.plannedStart.toIso8601String(),
      'plannedEnd': instance.plannedEnd.toIso8601String(),
      if (instance.actualStart?.toIso8601String() case final value?)
        'actualStart': value,
      if (instance.actualEnd?.toIso8601String() case final value?)
        'actualEnd': value,
      'tasks': instance.tasks.map((e) => e.toJson()).toList(),
      if (instance.order?.toJson() case final value?) 'order': value,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

PlansResponse _$PlansResponseFromJson(Map<String, dynamic> json) =>
    PlansResponse(
      plans: (json['plans'] as List<dynamic>)
          .map((e) => ProductionPlan.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PlansMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlansResponseToJson(PlansResponse instance) =>
    <String, dynamic>{
      'plans': instance.plans.map((e) => e.toJson()).toList(),
      'meta': instance.meta.toJson(),
    };

PlansMeta _$PlansMetaFromJson(Map<String, dynamic> json) => PlansMeta(
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  total: (json['total'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
);

Map<String, dynamic> _$PlansMetaToJson(PlansMeta instance) => <String, dynamic>{
  'page': instance.page,
  'limit': instance.limit,
  'total': instance.total,
  'totalPages': instance.totalPages,
};

TasksResponse _$TasksResponseFromJson(Map<String, dynamic> json) =>
    TasksResponse(
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => ProductionTask.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PlansMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TasksResponseToJson(TasksResponse instance) =>
    <String, dynamic>{
      'tasks': instance.tasks.map((e) => e.toJson()).toList(),
      'meta': instance.meta.toJson(),
    };
