import 'package:json_annotation/json_annotation.dart';

part 'subscription.g.dart';

@JsonSerializable()
class SubscriptionPlan {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String name;
  final String? description;
  @JsonKey(defaultValue: 0.0)
  final double price;
  @JsonKey(defaultValue: 'monthly')
  final String billingCycle;
  @JsonKey(defaultValue: 1)
  final int clientLimit;
  @JsonKey(defaultValue: 10)
  final int employeeLimit;
  final String? googlePlayProductId;
  final String? appStoreProductId;
  @JsonKey(defaultValue: [])
  final List<String> features;

  SubscriptionPlan({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.billingCycle,
    required this.clientLimit,
    required this.employeeLimit,
    this.googlePlayProductId,
    this.appStoreProductId,
    required this.features,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionPlanToJson(this);

  bool get isUnlimitedClients => clientLimit == 0;
  bool get isUnlimitedEmployees => employeeLimit == 0;

  String get clientLimitText =>
      isUnlimitedClients ? 'Неограничено' : '$clientLimit';
  String get employeeLimitText =>
      isUnlimitedEmployees ? 'Неограничено' : '$employeeLimit';
}

@JsonSerializable()
class SubscriptionLimits {
  @JsonKey(defaultValue: 1)
  final int clientLimit;
  @JsonKey(defaultValue: 10)
  final int employeeLimit;
  @JsonKey(defaultValue: 0)
  final int mlForecastLimit;
  @JsonKey(defaultValue: 0)
  final int mlReportLimit;
  @JsonKey(defaultValue: 0)
  final int mlInsightLimit;

  SubscriptionLimits({
    required this.clientLimit,
    required this.employeeLimit,
    required this.mlForecastLimit,
    required this.mlReportLimit,
    required this.mlInsightLimit,
  });

  factory SubscriptionLimits.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionLimitsFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionLimitsToJson(this);
}

@JsonSerializable()
class ResourceUsage {
  @JsonKey(defaultValue: 0)
  final int currentClients;
  @JsonKey(defaultValue: 0)
  final int currentEmployees;
  @JsonKey(fromJson: _limitsFromJson)
  final SubscriptionLimits limits;
  @JsonKey(defaultValue: -1)
  final int clientsRemaining;
  @JsonKey(defaultValue: -1)
  final int employeesRemaining;
  @JsonKey(defaultValue: 'Free')
  final String planName;
  final String? planId;
  @JsonKey(defaultValue: 'free')
  final String status;
  final DateTime? expiresAt;

  ResourceUsage({
    required this.currentClients,
    required this.currentEmployees,
    required this.limits,
    required this.clientsRemaining,
    required this.employeesRemaining,
    required this.planName,
    this.planId,
    required this.status,
    this.expiresAt,
  });

  factory ResourceUsage.fromJson(Map<String, dynamic> json) =>
      _$ResourceUsageFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceUsageToJson(this);

  static SubscriptionLimits _limitsFromJson(Map<String, dynamic>? json) =>
      SubscriptionLimits.fromJson(json ?? {});

  bool get isClientLimitReached =>
      limits.clientLimit > 0 && currentClients >= limits.clientLimit;

  bool get isEmployeeLimitReached =>
      limits.employeeLimit > 0 && currentEmployees >= limits.employeeLimit;

  bool get isNearClientLimit =>
      limits.clientLimit > 0 &&
      clientsRemaining >= 0 &&
      clientsRemaining <= 2;

  bool get isNearEmployeeLimit =>
      limits.employeeLimit > 0 &&
      employeesRemaining >= 0 &&
      employeesRemaining <= 5;

  bool get isActive => status == 'active' || status == 'trial';

  bool get isTrial => status == 'trial';

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  String get statusText {
    switch (status) {
      case 'active':
        return 'Активна';
      case 'trial':
        return 'Пробный период';
      case 'cancelled':
        return 'Отменена';
      case 'past_due':
        return 'Просрочена';
      case 'expired':
        return 'Истекла';
      default:
        return 'Бесплатный план';
    }
  }

  double get clientUsagePercent {
    if (limits.clientLimit == 0) return 0.0;
    return (currentClients / limits.clientLimit).clamp(0.0, 1.0);
  }

  double get employeeUsagePercent {
    if (limits.employeeLimit == 0) return 0.0;
    return (currentEmployees / limits.employeeLimit).clamp(0.0, 1.0);
  }
}

@JsonSerializable()
class Subscription {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String tenantId;
  @JsonKey(defaultValue: '')
  final String planId;
  final SubscriptionPlan? plan;
  @JsonKey(defaultValue: 'free')
  final String status;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime startDate;
  final DateTime? nextBillingDate;
  final DateTime? trialEndDate;
  final DateTime? expiresAt;
  final String? platform;

  Subscription({
    required this.id,
    required this.tenantId,
    required this.planId,
    this.plan,
    required this.status,
    required this.startDate,
    this.nextBillingDate,
    this.trialEndDate,
    this.expiresAt,
    this.platform,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionToJson(this);

  static DateTime _dateTimeFromJson(String? json) =>
      json != null ? DateTime.parse(json) : DateTime.now();

  bool get isActive => status == 'active' || status == 'trial';
}
