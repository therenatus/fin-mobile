// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QcOrderSummary _$QcOrderSummaryFromJson(Map<String, dynamic> json) =>
    QcOrderSummary(
      id: json['id'] as String,
      client: json['client'] == null
          ? null
          : QcClientSummary.fromJson(json['client'] as Map<String, dynamic>),
      model: json['model'] == null
          ? null
          : QcModelSummary.fromJson(json['model'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QcOrderSummaryToJson(QcOrderSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.client?.toJson() case final value?) 'client': value,
      if (instance.model?.toJson() case final value?) 'model': value,
    };

QcClientSummary _$QcClientSummaryFromJson(Map<String, dynamic> json) =>
    QcClientSummary(name: json['name'] as String);

Map<String, dynamic> _$QcClientSummaryToJson(QcClientSummary instance) =>
    <String, dynamic>{'name': instance.name};

QcModelSummary _$QcModelSummaryFromJson(Map<String, dynamic> json) =>
    QcModelSummary(name: json['name'] as String);

Map<String, dynamic> _$QcModelSummaryToJson(QcModelSummary instance) =>
    <String, dynamic>{'name': instance.name};

QcInspectorSummary _$QcInspectorSummaryFromJson(Map<String, dynamic> json) =>
    QcInspectorSummary(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$QcInspectorSummaryToJson(QcInspectorSummary instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

QcTemplateSummary _$QcTemplateSummaryFromJson(Map<String, dynamic> json) =>
    QcTemplateSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      type: const QcTypeConverter().fromJson(json['type'] as String),
    );

Map<String, dynamic> _$QcTemplateSummaryToJson(QcTemplateSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': const QcTypeConverter().toJson(instance.type),
    };

QcTemplateItem _$QcTemplateItemFromJson(Map<String, dynamic> json) =>
    QcTemplateItem(
      id: json['id'] as String,
      templateId: json['templateId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sequence: (json['sequence'] as num).toInt(),
      isRequired: json['isRequired'] as bool,
      criteria: json['criteria'] as String?,
      tolerance: json['tolerance'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$QcTemplateItemToJson(QcTemplateItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'templateId': instance.templateId,
      'name': instance.name,
      if (instance.description case final value?) 'description': value,
      'sequence': instance.sequence,
      'isRequired': instance.isRequired,
      if (instance.criteria case final value?) 'criteria': value,
      if (instance.tolerance case final value?) 'tolerance': value,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

QcTemplate _$QcTemplateFromJson(Map<String, dynamic> json) => QcTemplate(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  type: const QcTypeConverter().fromJson(json['type'] as String),
  isActive: json['isActive'] as bool,
  modelId: json['modelId'] as String?,
  model: json['model'] == null
      ? null
      : QcModelSummary.fromJson(json['model'] as Map<String, dynamic>),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => QcTemplateItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$QcTemplateToJson(QcTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'name': instance.name,
      if (instance.description case final value?) 'description': value,
      'type': const QcTypeConverter().toJson(instance.type),
      'isActive': instance.isActive,
      if (instance.modelId case final value?) 'modelId': value,
      if (instance.model?.toJson() case final value?) 'model': value,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

QcCheckResult _$QcCheckResultFromJson(Map<String, dynamic> json) =>
    QcCheckResult(
      id: json['id'] as String,
      checkId: json['checkId'] as String,
      itemId: json['itemId'] as String,
      item: json['item'] == null
          ? null
          : QcTemplateItem.fromJson(json['item'] as Map<String, dynamic>),
      passed: json['passed'] as bool?,
      value: json['value'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$QcCheckResultToJson(QcCheckResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'checkId': instance.checkId,
      'itemId': instance.itemId,
      if (instance.item?.toJson() case final value?) 'item': value,
      if (instance.passed case final value?) 'passed': value,
      if (instance.value case final value?) 'value': value,
      if (instance.notes case final value?) 'notes': value,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

QcCheck _$QcCheckFromJson(Map<String, dynamic> json) => QcCheck(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  templateId: json['templateId'] as String,
  template: json['template'] == null
      ? null
      : QcTemplateSummary.fromJson(json['template'] as Map<String, dynamic>),
  orderId: json['orderId'] as String?,
  order: json['order'] == null
      ? null
      : QcOrderSummary.fromJson(json['order'] as Map<String, dynamic>),
  taskId: json['taskId'] as String?,
  status: const QcStatusConverter().fromJson(json['status'] as String),
  decision: const QcDecisionConverter().fromJson(json['decision'] as String?),
  inspectorId: json['inspectorId'] as String?,
  inspector: json['inspector'] == null
      ? null
      : QcInspectorSummary.fromJson(json['inspector'] as Map<String, dynamic>),
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  notes: json['notes'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => QcCheckResult.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  defects:
      (json['defects'] as List<dynamic>?)
          ?.map((e) => Defect.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$QcCheckToJson(QcCheck instance) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'templateId': instance.templateId,
  if (instance.template?.toJson() case final value?) 'template': value,
  if (instance.orderId case final value?) 'orderId': value,
  if (instance.order?.toJson() case final value?) 'order': value,
  if (instance.taskId case final value?) 'taskId': value,
  'status': const QcStatusConverter().toJson(instance.status),
  if (const QcDecisionConverter().toJson(instance.decision) case final value?)
    'decision': value,
  if (instance.inspectorId case final value?) 'inspectorId': value,
  if (instance.inspector?.toJson() case final value?) 'inspector': value,
  if (instance.scheduledAt?.toIso8601String() case final value?)
    'scheduledAt': value,
  if (instance.startedAt?.toIso8601String() case final value?)
    'startedAt': value,
  if (instance.completedAt?.toIso8601String() case final value?)
    'completedAt': value,
  if (instance.notes case final value?) 'notes': value,
  'results': instance.results.map((e) => e.toJson()).toList(),
  'defects': instance.defects.map((e) => e.toJson()).toList(),
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

Defect _$DefectFromJson(Map<String, dynamic> json) => Defect(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  checkId: json['checkId'] as String?,
  check: json['check'] == null
      ? null
      : QcTemplateSummary.fromJson(json['check'] as Map<String, dynamic>),
  orderId: json['orderId'] as String?,
  order: json['order'] == null
      ? null
      : QcOrderSummary.fromJson(json['order'] as Map<String, dynamic>),
  type: const DefectTypeConverter().fromJson(json['type'] as String),
  severity: const DefectSeverityConverter().fromJson(
    json['severity'] as String,
  ),
  status: const DefectStatusConverter().fromJson(json['status'] as String),
  title: json['title'] as String,
  description: json['description'] as String?,
  location: json['location'] as String?,
  photos:
      (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  assigneeId: json['assigneeId'] as String?,
  assignee: json['assignee'] == null
      ? null
      : QcInspectorSummary.fromJson(json['assignee'] as Map<String, dynamic>),
  resolution: json['resolution'] as String?,
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
  resolvedBy: json['resolvedBy'] as String?,
  reportedBy: json['reportedBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$DefectToJson(Defect instance) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  if (instance.checkId case final value?) 'checkId': value,
  if (instance.check?.toJson() case final value?) 'check': value,
  if (instance.orderId case final value?) 'orderId': value,
  if (instance.order?.toJson() case final value?) 'order': value,
  'type': const DefectTypeConverter().toJson(instance.type),
  'severity': const DefectSeverityConverter().toJson(instance.severity),
  'status': const DefectStatusConverter().toJson(instance.status),
  'title': instance.title,
  if (instance.description case final value?) 'description': value,
  if (instance.location case final value?) 'location': value,
  'photos': instance.photos,
  if (instance.assigneeId case final value?) 'assigneeId': value,
  if (instance.assignee?.toJson() case final value?) 'assignee': value,
  if (instance.resolution case final value?) 'resolution': value,
  if (instance.resolvedAt?.toIso8601String() case final value?)
    'resolvedAt': value,
  if (instance.resolvedBy case final value?) 'resolvedBy': value,
  'reportedBy': instance.reportedBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

QcStats _$QcStatsFromJson(Map<String, dynamic> json) => QcStats(
  period: QcStatsPeriod.fromJson(json['period'] as Map<String, dynamic>),
  totalChecks: (json['totalChecks'] as num).toInt(),
  byStatus: Map<String, int>.from(json['byStatus'] as Map),
  byDecision: Map<String, int>.from(json['byDecision'] as Map),
  passRate: (json['passRate'] as num).toInt(),
  defectsByType: Map<String, int>.from(json['defectsByType'] as Map),
  defectsBySeverity: Map<String, int>.from(json['defectsBySeverity'] as Map),
  totalDefects: (json['totalDefects'] as num).toInt(),
);

Map<String, dynamic> _$QcStatsToJson(QcStats instance) => <String, dynamic>{
  'period': instance.period.toJson(),
  'totalChecks': instance.totalChecks,
  'byStatus': instance.byStatus,
  'byDecision': instance.byDecision,
  'passRate': instance.passRate,
  'defectsByType': instance.defectsByType,
  'defectsBySeverity': instance.defectsBySeverity,
  'totalDefects': instance.totalDefects,
};

QcStatsPeriod _$QcStatsPeriodFromJson(Map<String, dynamic> json) =>
    QcStatsPeriod(
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
    );

Map<String, dynamic> _$QcStatsPeriodToJson(QcStatsPeriod instance) =>
    <String, dynamic>{
      'from': instance.from.toIso8601String(),
      'to': instance.to.toIso8601String(),
    };

TemplatesResponse _$TemplatesResponseFromJson(Map<String, dynamic> json) =>
    TemplatesResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => QcTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: QcMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TemplatesResponseToJson(TemplatesResponse instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
      'meta': instance.meta.toJson(),
    };

ChecksResponse _$ChecksResponseFromJson(Map<String, dynamic> json) =>
    ChecksResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => QcCheck.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: QcMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChecksResponseToJson(ChecksResponse instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
      'meta': instance.meta.toJson(),
    };

DefectsResponse _$DefectsResponseFromJson(Map<String, dynamic> json) =>
    DefectsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => Defect.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: QcMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DefectsResponseToJson(DefectsResponse instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
      'meta': instance.meta.toJson(),
    };

QcMeta _$QcMetaFromJson(Map<String, dynamic> json) => QcMeta(
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  total: (json['total'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
);

Map<String, dynamic> _$QcMetaToJson(QcMeta instance) => <String, dynamic>{
  'page': instance.page,
  'limit': instance.limit,
  'total': instance.total,
  'totalPages': instance.totalPages,
};
