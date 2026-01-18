// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Supplier _$SupplierFromJson(Map<String, dynamic> json) => Supplier(
  id: json['id'] as String,
  name: json['name'] as String,
  contactName: json['contactName'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  inn: json['inn'] as String?,
  notes: json['notes'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  materialsCount:
      (_readMaterialsCount(json, 'materialsCount') as num?)?.toInt() ?? 0,
  purchasesCount:
      (_readPurchasesCount(json, 'purchasesCount') as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SupplierToJson(Supplier instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  if (instance.contactName case final value?) 'contactName': value,
  if (instance.phone case final value?) 'phone': value,
  if (instance.email case final value?) 'email': value,
  if (instance.address case final value?) 'address': value,
  if (instance.inn case final value?) 'inn': value,
  if (instance.notes case final value?) 'notes': value,
  'isActive': instance.isActive,
  'materialsCount': instance.materialsCount,
  'purchasesCount': instance.purchasesCount,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

SuppliersResponse _$SuppliersResponseFromJson(Map<String, dynamic> json) =>
    SuppliersResponse(
      suppliers: (json['suppliers'] as List<dynamic>)
          .map((e) => Supplier.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (_readPage(json, 'page') as num?)?.toInt() ?? 1,
      perPage: (_readPerPage(json, 'perPage') as num?)?.toInt() ?? 20,
      total: (_readTotal(json, 'total') as num?)?.toInt() ?? 0,
      totalPages: (_readTotalPages(json, 'totalPages') as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$SuppliersResponseToJson(SuppliersResponse instance) =>
    <String, dynamic>{
      'suppliers': instance.suppliers.map((e) => e.toJson()).toList(),
      'page': instance.page,
      'perPage': instance.perPage,
      'total': instance.total,
      'totalPages': instance.totalPages,
    };
