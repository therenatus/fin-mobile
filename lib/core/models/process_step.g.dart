// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'process_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProcessStep _$ProcessStepFromJson(Map<String, dynamic> json) => ProcessStep(
  id: json['id'] as String,
  modelId: json['modelId'] as String,
  stepOrder: (json['stepOrder'] as num).toInt(),
  name: json['name'] as String,
  estimatedTime: (json['estimatedTime'] as num).toInt(),
  executorRole: json['executorRole'] as String,
  rate: (json['rate'] as num?)?.toDouble(),
  rateType: json['rateType'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProcessStepToJson(ProcessStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelId': instance.modelId,
      'stepOrder': instance.stepOrder,
      'name': instance.name,
      'estimatedTime': instance.estimatedTime,
      'executorRole': instance.executorRole,
      if (instance.rate case final value?) 'rate': value,
      if (instance.rateType case final value?) 'rateType': value,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
