import 'package:json_annotation/json_annotation.dart';

part 'workload_calendar.g.dart';

// ==================== WORKLOAD TASK (simplified for calendar) ====================

@JsonSerializable()
class WorkloadTask {
  final String id;
  final String operationName;
  final String? orderId;
  final String? clientName;
  final String? modelName;
  final String? assignee;
  final String status;
  final double plannedHours;

  WorkloadTask({
    required this.id,
    required this.operationName,
    this.orderId,
    this.clientName,
    this.modelName,
    this.assignee,
    required this.status,
    required this.plannedHours,
  });

  factory WorkloadTask.fromJson(Map<String, dynamic> json) =>
      _$WorkloadTaskFromJson(json);

  Map<String, dynamic> toJson() => _$WorkloadTaskToJson(this);

  /// Order info string
  String get orderInfo {
    if (clientName != null && modelName != null) {
      return '$clientName - $modelName';
    }
    return orderId ?? 'Неизвестный заказ';
  }
}

// ==================== WORKLOAD DAY ====================

enum WorkloadStatus {
  light('light', 'Лёгкая'),
  normal('normal', 'Нормальная'),
  heavy('heavy', 'Высокая'),
  overload('overload', 'Перегрузка');

  final String value;
  final String label;
  const WorkloadStatus(this.value, this.label);

  static WorkloadStatus fromString(String status) {
    return WorkloadStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => WorkloadStatus.normal,
    );
  }
}

class WorkloadStatusConverter
    implements JsonConverter<WorkloadStatus, String> {
  const WorkloadStatusConverter();

  @override
  WorkloadStatus fromJson(String json) => WorkloadStatus.fromString(json);

  @override
  String toJson(WorkloadStatus status) => status.value;
}

@JsonSerializable()
class WorkloadDay {
  final String date;
  final String dayOfWeek;
  final double totalCapacity;
  final double plannedHours;
  final double actualHours;
  final int loadPercentage;
  @WorkloadStatusConverter()
  final WorkloadStatus status;
  @JsonKey(defaultValue: [])
  final List<WorkloadTask> tasks;

  WorkloadDay({
    required this.date,
    required this.dayOfWeek,
    required this.totalCapacity,
    required this.plannedHours,
    required this.actualHours,
    required this.loadPercentage,
    required this.status,
    this.tasks = const [],
  });

  factory WorkloadDay.fromJson(Map<String, dynamic> json) =>
      _$WorkloadDayFromJson(json);

  Map<String, dynamic> toJson() => _$WorkloadDayToJson(this);

  /// Date as DateTime
  DateTime get dateTime => DateTime.parse(date);

  /// Available hours (capacity - planned)
  double get availableHours =>
      (totalCapacity - plannedHours).clamp(0, double.infinity);

  /// Is weekend
  bool get isWeekend {
    final dt = dateTime;
    return dt.weekday == DateTime.saturday || dt.weekday == DateTime.sunday;
  }
}

// ==================== WORKLOAD SUMMARY ====================

@JsonSerializable()
class WorkloadSummary {
  final double totalPlannedHours;
  final double totalActualHours;
  final double totalCapacity;
  final int averageLoad;
  final int overloadedDays;
  final int employeesCount;

  WorkloadSummary({
    required this.totalPlannedHours,
    required this.totalActualHours,
    required this.totalCapacity,
    required this.averageLoad,
    required this.overloadedDays,
    required this.employeesCount,
  });

  factory WorkloadSummary.fromJson(Map<String, dynamic> json) =>
      _$WorkloadSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$WorkloadSummaryToJson(this);

  /// Efficiency percentage (actual / planned)
  int get efficiencyPercent {
    if (totalPlannedHours == 0) return 0;
    return (totalActualHours / totalPlannedHours * 100).round();
  }
}

// ==================== EMPLOYEE SUMMARY ====================

@JsonSerializable()
class EmployeeSummary {
  final String id;
  final String name;
  final String? role;

  EmployeeSummary({
    required this.id,
    required this.name,
    this.role,
  });

  factory EmployeeSummary.fromJson(Map<String, dynamic> json) =>
      _$EmployeeSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeSummaryToJson(this);
}

// ==================== WORKLOAD CALENDAR ====================

@JsonSerializable()
class WorkloadCalendar {
  @JsonKey(defaultValue: [])
  final List<WorkloadDay> calendar;
  final WorkloadSummary summary;
  @JsonKey(defaultValue: [])
  final List<EmployeeSummary> employees;

  WorkloadCalendar({
    this.calendar = const [],
    required this.summary,
    this.employees = const [],
  });

  factory WorkloadCalendar.fromJson(Map<String, dynamic> json) =>
      _$WorkloadCalendarFromJson(json);

  Map<String, dynamic> toJson() => _$WorkloadCalendarToJson(this);

  /// Days with overload
  List<WorkloadDay> get overloadedDays =>
      calendar.where((d) => d.status == WorkloadStatus.overload).toList();

  /// Days with high load (heavy + overload)
  List<WorkloadDay> get highLoadDays => calendar
      .where((d) =>
          d.status == WorkloadStatus.heavy ||
          d.status == WorkloadStatus.overload)
      .toList();
}

// ==================== GANTT DATA ====================

@JsonSerializable()
class GanttTask {
  final String id;
  final String name;
  final int sequence;
  final DateTime plannedStart;
  final DateTime plannedEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final String? assignee;
  final String status;
  final int progress;

  GanttTask({
    required this.id,
    required this.name,
    required this.sequence,
    required this.plannedStart,
    required this.plannedEnd,
    this.actualStart,
    this.actualEnd,
    this.assignee,
    required this.status,
    required this.progress,
  });

  factory GanttTask.fromJson(Map<String, dynamic> json) =>
      _$GanttTaskFromJson(json);

  Map<String, dynamic> toJson() => _$GanttTaskToJson(this);

  /// Duration in days
  int get durationDays => plannedEnd.difference(plannedStart).inDays + 1;
}

@JsonSerializable()
class GanttPlan {
  final String id;
  final String orderId;
  final String orderInfo;
  final String status;
  final DateTime plannedStart;
  final DateTime plannedEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  @JsonKey(defaultValue: [])
  final List<GanttTask> tasks;

  GanttPlan({
    required this.id,
    required this.orderId,
    required this.orderInfo,
    required this.status,
    required this.plannedStart,
    required this.plannedEnd,
    this.actualStart,
    this.actualEnd,
    this.tasks = const [],
  });

  factory GanttPlan.fromJson(Map<String, dynamic> json) =>
      _$GanttPlanFromJson(json);

  Map<String, dynamic> toJson() => _$GanttPlanToJson(this);

  /// Overall progress (based on completed tasks)
  int get overallProgress {
    if (tasks.isEmpty) return 0;
    final total = tasks.fold(0, (sum, t) => sum + t.progress);
    return (total / tasks.length).round();
  }
}

@JsonSerializable()
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  factory DateRange.fromJson(Map<String, dynamic> json) =>
      _$DateRangeFromJson(json);

  Map<String, dynamic> toJson() => _$DateRangeToJson(this);

  int get totalDays => end.difference(start).inDays + 1;
}

@JsonSerializable()
class GanttData {
  @JsonKey(defaultValue: [])
  final List<GanttPlan> plans;
  final DateRange dateRange;

  GanttData({
    this.plans = const [],
    required this.dateRange,
  });

  factory GanttData.fromJson(Map<String, dynamic> json) =>
      _$GanttDataFromJson(json);

  Map<String, dynamic> toJson() => _$GanttDataToJson(this);
}
