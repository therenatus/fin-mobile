// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workload_calendar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkloadTask _$WorkloadTaskFromJson(Map<String, dynamic> json) => WorkloadTask(
  id: json['id'] as String,
  operationName: json['operationName'] as String,
  orderId: json['orderId'] as String?,
  clientName: json['clientName'] as String?,
  modelName: json['modelName'] as String?,
  assignee: json['assignee'] as String?,
  status: json['status'] as String,
  plannedHours: (json['plannedHours'] as num).toDouble(),
);

Map<String, dynamic> _$WorkloadTaskToJson(WorkloadTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'operationName': instance.operationName,
      if (instance.orderId case final value?) 'orderId': value,
      if (instance.clientName case final value?) 'clientName': value,
      if (instance.modelName case final value?) 'modelName': value,
      if (instance.assignee case final value?) 'assignee': value,
      'status': instance.status,
      'plannedHours': instance.plannedHours,
    };

WorkloadDay _$WorkloadDayFromJson(Map<String, dynamic> json) => WorkloadDay(
  date: json['date'] as String,
  dayOfWeek: json['dayOfWeek'] as String,
  totalCapacity: (json['totalCapacity'] as num).toDouble(),
  plannedHours: (json['plannedHours'] as num).toDouble(),
  actualHours: (json['actualHours'] as num).toDouble(),
  loadPercentage: (json['loadPercentage'] as num).toInt(),
  status: const WorkloadStatusConverter().fromJson(json['status'] as String),
  tasks:
      (json['tasks'] as List<dynamic>?)
          ?.map((e) => WorkloadTask.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$WorkloadDayToJson(WorkloadDay instance) =>
    <String, dynamic>{
      'date': instance.date,
      'dayOfWeek': instance.dayOfWeek,
      'totalCapacity': instance.totalCapacity,
      'plannedHours': instance.plannedHours,
      'actualHours': instance.actualHours,
      'loadPercentage': instance.loadPercentage,
      'status': const WorkloadStatusConverter().toJson(instance.status),
      'tasks': instance.tasks.map((e) => e.toJson()).toList(),
    };

WorkloadSummary _$WorkloadSummaryFromJson(Map<String, dynamic> json) =>
    WorkloadSummary(
      totalPlannedHours: (json['totalPlannedHours'] as num).toDouble(),
      totalActualHours: (json['totalActualHours'] as num).toDouble(),
      totalCapacity: (json['totalCapacity'] as num).toDouble(),
      averageLoad: (json['averageLoad'] as num).toInt(),
      overloadedDays: (json['overloadedDays'] as num).toInt(),
      employeesCount: (json['employeesCount'] as num).toInt(),
    );

Map<String, dynamic> _$WorkloadSummaryToJson(WorkloadSummary instance) =>
    <String, dynamic>{
      'totalPlannedHours': instance.totalPlannedHours,
      'totalActualHours': instance.totalActualHours,
      'totalCapacity': instance.totalCapacity,
      'averageLoad': instance.averageLoad,
      'overloadedDays': instance.overloadedDays,
      'employeesCount': instance.employeesCount,
    };

EmployeeSummary _$EmployeeSummaryFromJson(Map<String, dynamic> json) =>
    EmployeeSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$EmployeeSummaryToJson(EmployeeSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      if (instance.role case final value?) 'role': value,
    };

WorkloadCalendar _$WorkloadCalendarFromJson(Map<String, dynamic> json) =>
    WorkloadCalendar(
      calendar:
          (json['calendar'] as List<dynamic>?)
              ?.map((e) => WorkloadDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: WorkloadSummary.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      employees:
          (json['employees'] as List<dynamic>?)
              ?.map((e) => EmployeeSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$WorkloadCalendarToJson(WorkloadCalendar instance) =>
    <String, dynamic>{
      'calendar': instance.calendar.map((e) => e.toJson()).toList(),
      'summary': instance.summary.toJson(),
      'employees': instance.employees.map((e) => e.toJson()).toList(),
    };

GanttTask _$GanttTaskFromJson(Map<String, dynamic> json) => GanttTask(
  id: json['id'] as String,
  name: json['name'] as String,
  sequence: (json['sequence'] as num).toInt(),
  plannedStart: DateTime.parse(json['plannedStart'] as String),
  plannedEnd: DateTime.parse(json['plannedEnd'] as String),
  actualStart: json['actualStart'] == null
      ? null
      : DateTime.parse(json['actualStart'] as String),
  actualEnd: json['actualEnd'] == null
      ? null
      : DateTime.parse(json['actualEnd'] as String),
  assignee: json['assignee'] as String?,
  status: json['status'] as String,
  progress: (json['progress'] as num).toInt(),
);

Map<String, dynamic> _$GanttTaskToJson(GanttTask instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sequence': instance.sequence,
  'plannedStart': instance.plannedStart.toIso8601String(),
  'plannedEnd': instance.plannedEnd.toIso8601String(),
  if (instance.actualStart?.toIso8601String() case final value?)
    'actualStart': value,
  if (instance.actualEnd?.toIso8601String() case final value?)
    'actualEnd': value,
  if (instance.assignee case final value?) 'assignee': value,
  'status': instance.status,
  'progress': instance.progress,
};

GanttPlan _$GanttPlanFromJson(Map<String, dynamic> json) => GanttPlan(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  orderInfo: json['orderInfo'] as String,
  status: json['status'] as String,
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
          ?.map((e) => GanttTask.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$GanttPlanToJson(GanttPlan instance) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'orderInfo': instance.orderInfo,
  'status': instance.status,
  'plannedStart': instance.plannedStart.toIso8601String(),
  'plannedEnd': instance.plannedEnd.toIso8601String(),
  if (instance.actualStart?.toIso8601String() case final value?)
    'actualStart': value,
  if (instance.actualEnd?.toIso8601String() case final value?)
    'actualEnd': value,
  'tasks': instance.tasks.map((e) => e.toJson()).toList(),
};

DateRange _$DateRangeFromJson(Map<String, dynamic> json) => DateRange(
  start: DateTime.parse(json['start'] as String),
  end: DateTime.parse(json['end'] as String),
);

Map<String, dynamic> _$DateRangeToJson(DateRange instance) => <String, dynamic>{
  'start': instance.start.toIso8601String(),
  'end': instance.end.toIso8601String(),
};

GanttData _$GanttDataFromJson(Map<String, dynamic> json) => GanttData(
  plans:
      (json['plans'] as List<dynamic>?)
          ?.map((e) => GanttPlan.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  dateRange: DateRange.fromJson(json['dateRange'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GanttDataToJson(GanttData instance) => <String, dynamic>{
  'plans': instance.plans.map((e) => e.toJson()).toList(),
  'dateRange': instance.dateRange.toJson(),
};
