/// Модель плана подписки
class SubscriptionPlan {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String billingCycle;
  final int clientLimit;
  final int employeeLimit;
  final String? googlePlayProductId;
  final String? appStoreProductId;
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

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      billingCycle: json['billingCycle'] ?? 'monthly',
      clientLimit: json['clientLimit'] ?? 1,
      employeeLimit: json['employeeLimit'] ?? 10,
      googlePlayProductId: json['googlePlayProductId'],
      appStoreProductId: json['appStoreProductId'],
      features: List<String>.from(json['features'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'billingCycle': billingCycle,
      'clientLimit': clientLimit,
      'employeeLimit': employeeLimit,
      'googlePlayProductId': googlePlayProductId,
      'appStoreProductId': appStoreProductId,
      'features': features,
    };
  }

  bool get isUnlimitedClients => clientLimit == 0;
  bool get isUnlimitedEmployees => employeeLimit == 0;

  String get clientLimitText =>
      isUnlimitedClients ? 'Неограничено' : '$clientLimit';
  String get employeeLimitText =>
      isUnlimitedEmployees ? 'Неограничено' : '$employeeLimit';
}

/// Модель лимитов подписки
class SubscriptionLimits {
  final int clientLimit;
  final int employeeLimit;
  final int mlForecastLimit;
  final int mlReportLimit;
  final int mlInsightLimit;

  SubscriptionLimits({
    required this.clientLimit,
    required this.employeeLimit,
    required this.mlForecastLimit,
    required this.mlReportLimit,
    required this.mlInsightLimit,
  });

  factory SubscriptionLimits.fromJson(Map<String, dynamic> json) {
    return SubscriptionLimits(
      clientLimit: json['clientLimit'] ?? 1,
      employeeLimit: json['employeeLimit'] ?? 10,
      mlForecastLimit: json['mlForecastLimit'] ?? 0,
      mlReportLimit: json['mlReportLimit'] ?? 0,
      mlInsightLimit: json['mlInsightLimit'] ?? 0,
    );
  }
}

/// Модель использования ресурсов
class ResourceUsage {
  final int currentClients;
  final int currentEmployees;
  final SubscriptionLimits limits;
  final int clientsRemaining;
  final int employeesRemaining;
  final String planName;
  final String? planId;
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

  factory ResourceUsage.fromJson(Map<String, dynamic> json) {
    return ResourceUsage(
      currentClients: json['currentClients'] ?? 0,
      currentEmployees: json['currentEmployees'] ?? 0,
      limits: SubscriptionLimits.fromJson(json['limits'] ?? {}),
      clientsRemaining: json['clientsRemaining'] ?? -1,
      employeesRemaining: json['employeesRemaining'] ?? -1,
      planName: json['planName'] ?? 'Free',
      planId: json['planId'],
      status: json['status'] ?? 'free',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
    );
  }

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

/// Модель текущей подписки
class Subscription {
  final String id;
  final String tenantId;
  final String planId;
  final SubscriptionPlan? plan;
  final String status;
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

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? '',
      tenantId: json['tenantId'] ?? '',
      planId: json['planId'] ?? '',
      plan: json['plan'] != null
          ? SubscriptionPlan.fromJson(json['plan'])
          : null,
      status: json['status'] ?? 'free',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      nextBillingDate: json['nextBillingDate'] != null
          ? DateTime.parse(json['nextBillingDate'])
          : null,
      trialEndDate: json['trialEndDate'] != null
          ? DateTime.parse(json['trialEndDate'])
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      platform: json['platform'],
    );
  }

  bool get isActive => status == 'active' || status == 'trial';
}
