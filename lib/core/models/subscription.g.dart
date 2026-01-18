// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionPlan _$SubscriptionPlanFromJson(Map<String, dynamic> json) =>
    SubscriptionPlan(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      billingCycle: json['billingCycle'] as String? ?? 'monthly',
      clientLimit: (json['clientLimit'] as num?)?.toInt() ?? 1,
      employeeLimit: (json['employeeLimit'] as num?)?.toInt() ?? 10,
      googlePlayProductId: json['googlePlayProductId'] as String?,
      appStoreProductId: json['appStoreProductId'] as String?,
      features:
          (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$SubscriptionPlanToJson(
  SubscriptionPlan instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  if (instance.description case final value?) 'description': value,
  'price': instance.price,
  'billingCycle': instance.billingCycle,
  'clientLimit': instance.clientLimit,
  'employeeLimit': instance.employeeLimit,
  if (instance.googlePlayProductId case final value?)
    'googlePlayProductId': value,
  if (instance.appStoreProductId case final value?) 'appStoreProductId': value,
  'features': instance.features,
};

SubscriptionLimits _$SubscriptionLimitsFromJson(Map<String, dynamic> json) =>
    SubscriptionLimits(
      clientLimit: (json['clientLimit'] as num?)?.toInt() ?? 1,
      employeeLimit: (json['employeeLimit'] as num?)?.toInt() ?? 10,
      mlForecastLimit: (json['mlForecastLimit'] as num?)?.toInt() ?? 0,
      mlReportLimit: (json['mlReportLimit'] as num?)?.toInt() ?? 0,
      mlInsightLimit: (json['mlInsightLimit'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SubscriptionLimitsToJson(SubscriptionLimits instance) =>
    <String, dynamic>{
      'clientLimit': instance.clientLimit,
      'employeeLimit': instance.employeeLimit,
      'mlForecastLimit': instance.mlForecastLimit,
      'mlReportLimit': instance.mlReportLimit,
      'mlInsightLimit': instance.mlInsightLimit,
    };

ResourceUsage _$ResourceUsageFromJson(Map<String, dynamic> json) =>
    ResourceUsage(
      currentClients: (json['currentClients'] as num?)?.toInt() ?? 0,
      currentEmployees: (json['currentEmployees'] as num?)?.toInt() ?? 0,
      limits: ResourceUsage._limitsFromJson(
        json['limits'] as Map<String, dynamic>?,
      ),
      clientsRemaining: (json['clientsRemaining'] as num?)?.toInt() ?? -1,
      employeesRemaining: (json['employeesRemaining'] as num?)?.toInt() ?? -1,
      planName: json['planName'] as String? ?? 'Free',
      planId: json['planId'] as String?,
      status: json['status'] as String? ?? 'free',
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$ResourceUsageToJson(ResourceUsage instance) =>
    <String, dynamic>{
      'currentClients': instance.currentClients,
      'currentEmployees': instance.currentEmployees,
      'limits': instance.limits.toJson(),
      'clientsRemaining': instance.clientsRemaining,
      'employeesRemaining': instance.employeesRemaining,
      'planName': instance.planName,
      if (instance.planId case final value?) 'planId': value,
      'status': instance.status,
      if (instance.expiresAt?.toIso8601String() case final value?)
        'expiresAt': value,
    };

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) => Subscription(
  id: json['id'] as String? ?? '',
  tenantId: json['tenantId'] as String? ?? '',
  planId: json['planId'] as String? ?? '',
  plan: json['plan'] == null
      ? null
      : SubscriptionPlan.fromJson(json['plan'] as Map<String, dynamic>),
  status: json['status'] as String? ?? 'free',
  startDate: Subscription._dateTimeFromJson(json['startDate'] as String?),
  nextBillingDate: json['nextBillingDate'] == null
      ? null
      : DateTime.parse(json['nextBillingDate'] as String),
  trialEndDate: json['trialEndDate'] == null
      ? null
      : DateTime.parse(json['trialEndDate'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  platform: json['platform'] as String?,
);

Map<String, dynamic> _$SubscriptionToJson(Subscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'planId': instance.planId,
      if (instance.plan?.toJson() case final value?) 'plan': value,
      'status': instance.status,
      'startDate': instance.startDate.toIso8601String(),
      if (instance.nextBillingDate?.toIso8601String() case final value?)
        'nextBillingDate': value,
      if (instance.trialEndDate?.toIso8601String() case final value?)
        'trialEndDate': value,
      if (instance.expiresAt?.toIso8601String() case final value?)
        'expiresAt': value,
      if (instance.platform case final value?) 'platform': value,
    };
