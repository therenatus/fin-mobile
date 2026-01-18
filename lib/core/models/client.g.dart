// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientContact _$ClientContactFromJson(Map<String, dynamic> json) =>
    ClientContact(
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      telegram: json['telegram'] as String?,
      whatsapp: json['whatsapp'] as String?,
    );

Map<String, dynamic> _$ClientContactToJson(ClientContact instance) =>
    <String, dynamic>{
      if (instance.email case final value?) 'email': value,
      if (instance.phone case final value?) 'phone': value,
      if (instance.telegram case final value?) 'telegram': value,
      if (instance.whatsapp case final value?) 'whatsapp': value,
    };

ClientAssignedModel _$ClientAssignedModelFromJson(Map<String, dynamic> json) =>
    ClientAssignedModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      basePrice: (json['basePrice'] as num).toDouble(),
    );

Map<String, dynamic> _$ClientAssignedModelToJson(
  ClientAssignedModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  if (instance.category case final value?) 'category': value,
  'basePrice': instance.basePrice,
};

Client _$ClientFromJson(Map<String, dynamic> json) => Client(
  id: json['id'] as String,
  name: json['name'] as String,
  contacts: ClientContact.fromJson(json['contacts'] as Map<String, dynamic>),
  notes: json['notes'] as String?,
  preferences: json['preferences'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  ordersCount: (json['ordersCount'] as num?)?.toInt(),
  totalSpent: (json['totalSpent'] as num?)?.toDouble(),
  assignedModelIds:
      (json['assignedModelIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  assignedModels:
      (json['assignedModels'] as List<dynamic>?)
          ?.map((e) => ClientAssignedModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$ClientToJson(Client instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'contacts': instance.contacts.toJson(),
  if (instance.notes case final value?) 'notes': value,
  if (instance.preferences case final value?) 'preferences': value,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  if (instance.ordersCount case final value?) 'ordersCount': value,
  if (instance.totalSpent case final value?) 'totalSpent': value,
  'assignedModelIds': instance.assignedModelIds,
  'assignedModels': instance.assignedModels.map((e) => e.toJson()).toList(),
};
