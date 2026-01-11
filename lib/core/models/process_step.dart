class ProcessStep {
  final String id;
  final String modelId;
  final int stepOrder;
  final String name;
  final int estimatedTime; // in minutes
  final String executorRole;
  final double? rate;
  final String? rateType; // 'per_unit' or 'per_hour'
  final DateTime createdAt;
  final DateTime updatedAt;

  ProcessStep({
    required this.id,
    required this.modelId,
    required this.stepOrder,
    required this.name,
    required this.estimatedTime,
    required this.executorRole,
    this.rate,
    this.rateType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProcessStep.fromJson(Map<String, dynamic> json) {
    return ProcessStep(
      id: json['id'] as String,
      modelId: json['modelId'] as String,
      stepOrder: json['stepOrder'] as int,
      name: json['name'] as String,
      estimatedTime: json['estimatedTime'] as int,
      executorRole: json['executorRole'] as String,
      rate: json['rate'] != null ? (json['rate'] as num).toDouble() : null,
      rateType: json['rateType'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelId': modelId,
      'stepOrder': stepOrder,
      'name': name,
      'estimatedTime': estimatedTime,
      'executorRole': executorRole,
      if (rate != null) 'rate': rate,
      if (rateType != null) 'rateType': rateType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get rateTypeLabel {
    switch (rateType) {
      case 'per_unit':
        return 'за единицу';
      case 'per_hour':
        return 'за час';
      default:
        return '';
    }
  }

  String get executorRoleLabel {
    switch (executorRole) {
      case 'tailor':
        return 'Портной';
      case 'designer':
        return 'Дизайнер';
      case 'cutter':
        return 'Раскройщик';
      case 'seamstress':
        return 'Швея';
      case 'finisher':
        return 'Отделочник';
      case 'presser':
        return 'Гладильщик';
      case 'quality':
        return 'ОТК';
      default:
        return executorRole;
    }
  }

  String get formattedRate {
    if (rate == null) return 'Не указана';
    return '${rate!.toStringAsFixed(0)} руб. $rateTypeLabel';
  }

  String get formattedTime {
    if (estimatedTime < 60) {
      return '$estimatedTime мин';
    }
    final hours = estimatedTime ~/ 60;
    final minutes = estimatedTime % 60;
    if (minutes == 0) {
      return '$hours ч';
    }
    return '$hours ч $minutes мин';
  }

  ProcessStep copyWith({
    String? id,
    String? modelId,
    int? stepOrder,
    String? name,
    int? estimatedTime,
    String? executorRole,
    double? rate,
    String? rateType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProcessStep(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      stepOrder: stepOrder ?? this.stepOrder,
      name: name ?? this.name,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      executorRole: executorRole ?? this.executorRole,
      rate: rate ?? this.rate,
      rateType: rateType ?? this.rateType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
