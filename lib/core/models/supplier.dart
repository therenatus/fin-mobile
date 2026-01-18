import 'package:json_annotation/json_annotation.dart';
import 'json_converters.dart';

part 'supplier.g.dart';

@JsonSerializable()
class Supplier {
  final String id;
  final String name;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? address;
  final String? inn;
  final String? notes;
  @JsonKey(defaultValue: true)
  final bool isActive;
  @JsonKey(readValue: _readMaterialsCount, defaultValue: 0)
  final int materialsCount;
  @JsonKey(readValue: _readPurchasesCount, defaultValue: 0)
  final int purchasesCount;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime updatedAt;

  Supplier({
    required this.id,
    required this.name,
    this.contactName,
    this.phone,
    this.email,
    this.address,
    this.inn,
    this.notes,
    this.isActive = true,
    this.materialsCount = 0,
    this.purchasesCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Custom toJson for create/update (only includes editable fields)
  Map<String, dynamic> toJson() => {
        'name': name,
        'contactName': contactName,
        'phone': phone,
        'email': email,
        'address': address,
        'inn': inn,
        'notes': notes,
      };

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get hasContact => contactName != null || phone != null || email != null;

  factory Supplier.fromJson(Map<String, dynamic> json) =>
      _$SupplierFromJson(json);
}

// Helper functions for reading _count fields
Object? _readMaterialsCount(Map<dynamic, dynamic> json, String key) =>
    (json['_count'] as Map<String, dynamic>?)?['materials'];
Object? _readPurchasesCount(Map<dynamic, dynamic> json, String key) =>
    (json['_count'] as Map<String, dynamic>?)?['purchases'];

@JsonSerializable()
class SuppliersResponse {
  final List<Supplier> suppliers;
  @JsonKey(readValue: _readPage, defaultValue: 1)
  final int page;
  @JsonKey(readValue: _readPerPage, defaultValue: 20)
  final int perPage;
  @JsonKey(readValue: _readTotal, defaultValue: 0)
  final int total;
  @JsonKey(readValue: _readTotalPages, defaultValue: 1)
  final int totalPages;

  SuppliersResponse({
    required this.suppliers,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory SuppliersResponse.fromJson(Map<String, dynamic> json) =>
      _$SuppliersResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SuppliersResponseToJson(this);
}

// Helper functions for reading meta fields
Object? _readPage(Map<dynamic, dynamic> json, String key) =>
    (json['meta'] as Map<String, dynamic>?)?['page'];
Object? _readPerPage(Map<dynamic, dynamic> json, String key) =>
    (json['meta'] as Map<String, dynamic>?)?['per_page'];
Object? _readTotal(Map<dynamic, dynamic> json, String key) =>
    (json['meta'] as Map<String, dynamic>?)?['total'];
Object? _readTotalPages(Map<dynamic, dynamic> json, String key) =>
    (json['meta'] as Map<String, dynamic>?)?['total_pages'];
