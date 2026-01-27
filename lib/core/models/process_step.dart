import 'package:json_annotation/json_annotation.dart';

part 'process_step.g.dart';

@JsonSerializable()
class ProcessStep {
  final String id;
  final String modelId;
  final int stepOrder;
  final String name;
  final int estimatedTime; // in minutes
  @JsonKey(defaultValue: 0)
  final int setupTime; // setup time in minutes
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
    this.setupTime = 0,
    required this.executorRole,
    this.rate,
    this.rateType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProcessStep.fromJson(Map<String, dynamic> json) =>
      _$ProcessStepFromJson(json);

  Map<String, dynamic> toJson() => _$ProcessStepToJson(this);

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
    return '${rate!.toStringAsFixed(0)} сом $rateTypeLabel';
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
    int? setupTime,
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
      setupTime: setupTime ?? this.setupTime,
      executorRole: executorRole ?? this.executorRole,
      rate: rate ?? this.rate,
      rateType: rateType ?? this.rateType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
