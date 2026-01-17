import 'package:json_annotation/json_annotation.dart';

part 'client.g.dart';

@JsonSerializable()
class ClientContact {
  final String? email;
  final String? phone;
  final String? telegram;
  final String? whatsapp;

  ClientContact({this.email, this.phone, this.telegram, this.whatsapp});

  factory ClientContact.fromJson(Map<String, dynamic> json) =>
      _$ClientContactFromJson(json);

  Map<String, dynamic> toJson() => _$ClientContactToJson(this);
}

@JsonSerializable()
class ClientAssignedModel {
  final String id;
  final String name;
  final String? category;
  final double basePrice;

  ClientAssignedModel({
    required this.id,
    required this.name,
    this.category,
    required this.basePrice,
  });

  factory ClientAssignedModel.fromJson(Map<String, dynamic> json) =>
      _$ClientAssignedModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClientAssignedModelToJson(this);
}

@JsonSerializable()
class Client {
  final String id;
  final String name;
  final ClientContact contacts;
  final String? notes;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? ordersCount;
  final double? totalSpent;
  @JsonKey(defaultValue: [])
  final List<String> assignedModelIds;
  @JsonKey(defaultValue: [])
  final List<ClientAssignedModel> assignedModels;

  Client({
    required this.id,
    required this.name,
    required this.contacts,
    this.notes,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
    this.ordersCount,
    this.totalSpent,
    this.assignedModelIds = const [],
    this.assignedModels = const [],
  });

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);

  Map<String, dynamic> toJson() => _$ClientToJson(this);

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  bool get isVip => (totalSpent ?? 0) > 50000 || (ordersCount ?? 0) > 10;
}
