import 'package:json_annotation/json_annotation.dart';

part 'qc.g.dart';

// ==================== ENUMS ====================

enum QcType {
  incoming('INCOMING', 'Входной контроль'),
  inProcess('IN_PROCESS', 'Контроль в процессе'),
  final_('FINAL', 'Финальный контроль');

  final String value;
  final String label;
  const QcType(this.value, this.label);

  static QcType fromString(String type) {
    return QcType.values.firstWhere(
      (e) => e.value == type,
      orElse: () => QcType.final_,
    );
  }
}

enum QcStatus {
  pending('PENDING', 'Ожидает'),
  inProgress('IN_PROGRESS', 'В процессе'),
  completed('COMPLETED', 'Завершена'),
  cancelled('CANCELLED', 'Отменена');

  final String value;
  final String label;
  const QcStatus(this.value, this.label);

  static QcStatus fromString(String status) {
    return QcStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => QcStatus.pending,
    );
  }
}

enum QcDecision {
  pass('PASS', 'Принято'),
  fail('FAIL', 'Отклонено'),
  conditional('CONDITIONAL', 'Принято условно');

  final String value;
  final String label;
  const QcDecision(this.value, this.label);

  static QcDecision fromString(String decision) {
    return QcDecision.values.firstWhere(
      (e) => e.value == decision,
      orElse: () => QcDecision.pass,
    );
  }
}

enum DefectType {
  material('MATERIAL', 'Дефект материала'),
  workmanship('WORKMANSHIP', 'Дефект изготовления'),
  design('DESIGN', 'Дефект дизайна'),
  measurement('MEASUREMENT', 'Несоответствие размерам'),
  other('OTHER', 'Прочее');

  final String value;
  final String label;
  const DefectType(this.value, this.label);

  static DefectType fromString(String type) {
    return DefectType.values.firstWhere(
      (e) => e.value == type,
      orElse: () => DefectType.other,
    );
  }
}

enum DefectSeverity {
  critical('CRITICAL', 'Критический'),
  major('MAJOR', 'Значительный'),
  minor('MINOR', 'Незначительный');

  final String value;
  final String label;
  const DefectSeverity(this.value, this.label);

  static DefectSeverity fromString(String severity) {
    return DefectSeverity.values.firstWhere(
      (e) => e.value == severity,
      orElse: () => DefectSeverity.major,
    );
  }
}

enum DefectStatus {
  open('OPEN', 'Открыт'),
  inProgress('IN_PROGRESS', 'В работе'),
  resolved('RESOLVED', 'Исправлен'),
  closed('CLOSED', 'Закрыт'),
  wontFix('WONT_FIX', 'Не исправлять');

  final String value;
  final String label;
  const DefectStatus(this.value, this.label);

  static DefectStatus fromString(String status) {
    return DefectStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => DefectStatus.open,
    );
  }
}

// ==================== CONVERTERS ====================

class QcTypeConverter implements JsonConverter<QcType, String> {
  const QcTypeConverter();

  @override
  QcType fromJson(String json) => QcType.fromString(json);

  @override
  String toJson(QcType type) => type.value;
}

class QcStatusConverter implements JsonConverter<QcStatus, String> {
  const QcStatusConverter();

  @override
  QcStatus fromJson(String json) => QcStatus.fromString(json);

  @override
  String toJson(QcStatus status) => status.value;
}

class QcDecisionConverter implements JsonConverter<QcDecision?, String?> {
  const QcDecisionConverter();

  @override
  QcDecision? fromJson(String? json) =>
      json != null ? QcDecision.fromString(json) : null;

  @override
  String? toJson(QcDecision? decision) => decision?.value;
}

class DefectTypeConverter implements JsonConverter<DefectType, String> {
  const DefectTypeConverter();

  @override
  DefectType fromJson(String json) => DefectType.fromString(json);

  @override
  String toJson(DefectType type) => type.value;
}

class DefectSeverityConverter implements JsonConverter<DefectSeverity, String> {
  const DefectSeverityConverter();

  @override
  DefectSeverity fromJson(String json) => DefectSeverity.fromString(json);

  @override
  String toJson(DefectSeverity severity) => severity.value;
}

class DefectStatusConverter implements JsonConverter<DefectStatus, String> {
  const DefectStatusConverter();

  @override
  DefectStatus fromJson(String json) => DefectStatus.fromString(json);

  @override
  String toJson(DefectStatus status) => status.value;
}

// ==================== SUMMARY MODELS ====================

@JsonSerializable()
class QcOrderSummary {
  final String id;
  final QcClientSummary? client;
  final QcModelSummary? model;

  QcOrderSummary({
    required this.id,
    this.client,
    this.model,
  });

  factory QcOrderSummary.fromJson(Map<String, dynamic> json) =>
      _$QcOrderSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$QcOrderSummaryToJson(this);

  String get displayName {
    final clientName = client?.name ?? 'Неизвестный';
    final modelName = model?.name ?? 'Без модели';
    return '$clientName - $modelName';
  }
}

@JsonSerializable()
class QcClientSummary {
  final String name;

  QcClientSummary({required this.name});

  factory QcClientSummary.fromJson(Map<String, dynamic> json) =>
      _$QcClientSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$QcClientSummaryToJson(this);
}

@JsonSerializable()
class QcModelSummary {
  final String name;

  QcModelSummary({required this.name});

  factory QcModelSummary.fromJson(Map<String, dynamic> json) =>
      _$QcModelSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$QcModelSummaryToJson(this);
}

@JsonSerializable()
class QcInspectorSummary {
  final String id;
  final String name;

  QcInspectorSummary({required this.id, required this.name});

  factory QcInspectorSummary.fromJson(Map<String, dynamic> json) =>
      _$QcInspectorSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$QcInspectorSummaryToJson(this);
}

@JsonSerializable()
class QcTemplateSummary {
  final String id;
  final String name;
  @QcTypeConverter()
  final QcType type;

  QcTemplateSummary({
    required this.id,
    required this.name,
    required this.type,
  });

  factory QcTemplateSummary.fromJson(Map<String, dynamic> json) =>
      _$QcTemplateSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$QcTemplateSummaryToJson(this);
}

// ==================== QC TEMPLATE ITEM ====================

@JsonSerializable()
class QcTemplateItem {
  final String id;
  final String templateId;
  final String name;
  final String? description;
  final int sequence;
  final bool isRequired;
  final String? criteria;
  final String? tolerance;
  final DateTime createdAt;
  final DateTime updatedAt;

  QcTemplateItem({
    required this.id,
    required this.templateId,
    required this.name,
    this.description,
    required this.sequence,
    required this.isRequired,
    this.criteria,
    this.tolerance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QcTemplateItem.fromJson(Map<String, dynamic> json) =>
      _$QcTemplateItemFromJson(json);

  Map<String, dynamic> toJson() => _$QcTemplateItemToJson(this);
}

// ==================== QC TEMPLATE ====================

@JsonSerializable()
class QcTemplate {
  final String id;
  final String tenantId;
  final String name;
  final String? description;
  @QcTypeConverter()
  final QcType type;
  final bool isActive;
  final String? modelId;
  final QcModelSummary? model;
  @JsonKey(defaultValue: [])
  final List<QcTemplateItem> items;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  QcTemplate({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    required this.type,
    required this.isActive,
    this.modelId,
    this.model,
    this.items = const [],
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QcTemplate.fromJson(Map<String, dynamic> json) =>
      _$QcTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$QcTemplateToJson(this);

  /// Get count of required items
  int get requiredItemsCount => items.where((i) => i.isRequired).length;
}

// ==================== QC CHECK RESULT ====================

@JsonSerializable()
class QcCheckResult {
  final String id;
  final String checkId;
  final String itemId;
  final QcTemplateItem? item;
  final bool? passed;
  final String? value;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  QcCheckResult({
    required this.id,
    required this.checkId,
    required this.itemId,
    this.item,
    this.passed,
    this.value,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QcCheckResult.fromJson(Map<String, dynamic> json) =>
      _$QcCheckResultFromJson(json);

  Map<String, dynamic> toJson() => _$QcCheckResultToJson(this);
}

// ==================== QC CHECK ====================

@JsonSerializable()
class QcCheck {
  final String id;
  final String tenantId;
  final String templateId;
  final QcTemplateSummary? template;
  final String? orderId;
  final QcOrderSummary? order;
  final String? taskId;
  @QcStatusConverter()
  final QcStatus status;
  @QcDecisionConverter()
  final QcDecision? decision;
  final String? inspectorId;
  final QcInspectorSummary? inspector;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;
  @JsonKey(defaultValue: [])
  final List<QcCheckResult> results;
  @JsonKey(defaultValue: [])
  final List<Defect> defects;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  QcCheck({
    required this.id,
    required this.tenantId,
    required this.templateId,
    this.template,
    this.orderId,
    this.order,
    this.taskId,
    required this.status,
    this.decision,
    this.inspectorId,
    this.inspector,
    this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.notes,
    this.results = const [],
    this.defects = const [],
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QcCheck.fromJson(Map<String, dynamic> json) =>
      _$QcCheckFromJson(json);

  Map<String, dynamic> toJson() => _$QcCheckToJson(this);

  /// Check display name
  String get displayName {
    final templateName = template?.name ?? 'Проверка';
    final orderInfo = order?.displayName ?? '';
    return orderInfo.isNotEmpty ? '$templateName - $orderInfo' : templateName;
  }

  /// Count of passed results
  int get passedCount => results.where((r) => r.passed == true).length;

  /// Count of failed results
  int get failedCount => results.where((r) => r.passed == false).length;

  /// Count of pending results
  int get pendingCount => results.where((r) => r.passed == null).length;

  /// Progress percentage
  int get progressPercent {
    if (results.isEmpty) return 0;
    final answered = results.where((r) => r.passed != null).length;
    return (answered / results.length * 100).round();
  }

  /// Duration in minutes (if completed)
  int? get durationMinutes {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!).inMinutes;
  }
}

// ==================== DEFECT ====================

@JsonSerializable()
class Defect {
  final String id;
  final String tenantId;
  final String? checkId;
  final QcTemplateSummary? check;
  final String? orderId;
  final QcOrderSummary? order;
  @DefectTypeConverter()
  final DefectType type;
  @DefectSeverityConverter()
  final DefectSeverity severity;
  @DefectStatusConverter()
  final DefectStatus status;
  final String title;
  final String? description;
  final String? location;
  @JsonKey(defaultValue: [])
  final List<String> photos;
  final String? assigneeId;
  final QcInspectorSummary? assignee;
  final String? resolution;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String reportedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Defect({
    required this.id,
    required this.tenantId,
    this.checkId,
    this.check,
    this.orderId,
    this.order,
    required this.type,
    required this.severity,
    required this.status,
    required this.title,
    this.description,
    this.location,
    this.photos = const [],
    this.assigneeId,
    this.assignee,
    this.resolution,
    this.resolvedAt,
    this.resolvedBy,
    required this.reportedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Defect.fromJson(Map<String, dynamic> json) => _$DefectFromJson(json);

  Map<String, dynamic> toJson() => _$DefectToJson(this);

  /// Check if defect can be resolved
  bool get canResolve =>
      status != DefectStatus.closed && status != DefectStatus.wontFix;

  /// Check if defect can be closed
  bool get canClose => status == DefectStatus.resolved;

  /// Check if defect can be reopened
  bool get canReopen => status != DefectStatus.open;

  /// Days since creation
  int get daysSinceCreation => DateTime.now().difference(createdAt).inDays;
}

// ==================== QC STATS ====================

@JsonSerializable()
class QcStats {
  final QcStatsPeriod period;
  final int totalChecks;
  final Map<String, int> byStatus;
  final Map<String, int> byDecision;
  final int passRate;
  final Map<String, int> defectsByType;
  final Map<String, int> defectsBySeverity;
  final int totalDefects;

  QcStats({
    required this.period,
    required this.totalChecks,
    required this.byStatus,
    required this.byDecision,
    required this.passRate,
    required this.defectsByType,
    required this.defectsBySeverity,
    required this.totalDefects,
  });

  factory QcStats.fromJson(Map<String, dynamic> json) =>
      _$QcStatsFromJson(json);

  Map<String, dynamic> toJson() => _$QcStatsToJson(this);
}

@JsonSerializable()
class QcStatsPeriod {
  final DateTime from;
  final DateTime to;

  QcStatsPeriod({required this.from, required this.to});

  factory QcStatsPeriod.fromJson(Map<String, dynamic> json) =>
      _$QcStatsPeriodFromJson(json);

  Map<String, dynamic> toJson() => _$QcStatsPeriodToJson(this);
}

// ==================== RESPONSES ====================

@JsonSerializable()
class TemplatesResponse {
  final List<QcTemplate> data;
  final QcMeta meta;

  TemplatesResponse({required this.data, required this.meta});

  factory TemplatesResponse.fromJson(Map<String, dynamic> json) =>
      _$TemplatesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TemplatesResponseToJson(this);
}

@JsonSerializable()
class ChecksResponse {
  final List<QcCheck> data;
  final QcMeta meta;

  ChecksResponse({required this.data, required this.meta});

  factory ChecksResponse.fromJson(Map<String, dynamic> json) =>
      _$ChecksResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChecksResponseToJson(this);
}

@JsonSerializable()
class DefectsResponse {
  final List<Defect> data;
  final QcMeta meta;

  DefectsResponse({required this.data, required this.meta});

  factory DefectsResponse.fromJson(Map<String, dynamic> json) =>
      _$DefectsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DefectsResponseToJson(this);
}

@JsonSerializable()
class QcMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  QcMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory QcMeta.fromJson(Map<String, dynamic> json) => _$QcMetaFromJson(json);

  Map<String, dynamic> toJson() => _$QcMetaToJson(this);
}
