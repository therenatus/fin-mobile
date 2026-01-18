import 'package:json_annotation/json_annotation.dart';
import 'json_converters.dart';
import 'material.dart' show MaterialUnit;

part 'purchase.g.dart';

enum PurchaseStatus {
  draft,
  ordered,
  partial,
  received,
  cancelled;

  String get label {
    switch (this) {
      case PurchaseStatus.draft:
        return 'Черновик';
      case PurchaseStatus.ordered:
        return 'Заказано';
      case PurchaseStatus.partial:
        return 'Частично';
      case PurchaseStatus.received:
        return 'Получено';
      case PurchaseStatus.cancelled:
        return 'Отменено';
    }
  }

  static PurchaseStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DRAFT':
        return PurchaseStatus.draft;
      case 'ORDERED':
        return PurchaseStatus.ordered;
      case 'PARTIAL':
        return PurchaseStatus.partial;
      case 'RECEIVED':
        return PurchaseStatus.received;
      case 'CANCELLED':
        return PurchaseStatus.cancelled;
      default:
        return PurchaseStatus.draft;
    }
  }

  String toJson() => name.toUpperCase();
}

@JsonSerializable()
class PurchaseSupplier {
  final String id;
  final String name;

  PurchaseSupplier({
    required this.id,
    required this.name,
  });

  factory PurchaseSupplier.fromJson(Map<String, dynamic> json) =>
      _$PurchaseSupplierFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseSupplierToJson(this);
}

@JsonSerializable()
class PurchaseItemMaterial {
  final String id;
  final String name;
  final String sku;
  final String unit;
  final double? quantity; // Current stock

  PurchaseItemMaterial({
    required this.id,
    required this.name,
    required this.sku,
    required this.unit,
    this.quantity,
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  MaterialUnit get materialUnit => MaterialUnit.fromString(unit);

  factory PurchaseItemMaterial.fromJson(Map<String, dynamic> json) =>
      _$PurchaseItemMaterialFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseItemMaterialToJson(this);
}

@JsonSerializable()
class PurchaseItem {
  final String id;
  final String purchaseId;
  final String materialId;
  final double quantity;
  @JsonKey(defaultValue: 0.0)
  final double receivedQty;
  final double unitPrice;
  final double totalPrice;
  final PurchaseItemMaterial? material;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime updatedAt;

  // Computed from backend
  final double? remainingQty;
  final bool? isFullyReceived;

  PurchaseItem({
    required this.id,
    required this.purchaseId,
    required this.materialId,
    required this.quantity,
    required this.receivedQty,
    required this.unitPrice,
    required this.totalPrice,
    this.material,
    required this.createdAt,
    required this.updatedAt,
    this.remainingQty,
    this.isFullyReceived,
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  double get computedRemainingQty => remainingQty ?? (quantity - receivedQty);

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get computedIsFullyReceived => isFullyReceived ?? (receivedQty >= quantity);

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedQuantity {
    final unit = material?.materialUnit.label ?? '';
    return '${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 2)} $unit';
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedReceivedQty {
    final unit = material?.materialUnit.label ?? '';
    return '${receivedQty.toStringAsFixed(receivedQty.truncateToDouble() == receivedQty ? 0 : 2)} $unit';
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedUnitPrice => '${unitPrice.toStringAsFixed(2)} ₽';

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(2)} ₽';

  factory PurchaseItem.fromJson(Map<String, dynamic> json) =>
      _$PurchaseItemFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseItemToJson(this);
}

@JsonSerializable()
class Purchase {
  final String id;
  final String number;
  @JsonKey(fromJson: _purchaseStatusFromJson, toJson: _purchaseStatusToJson)
  final PurchaseStatus status;
  final String? supplierId;
  final PurchaseSupplier? supplier;
  @JsonKey(fromJson: nullableDateTimeFromJson, toJson: nullableDateTimeToJson)
  final DateTime? orderDate;
  @JsonKey(fromJson: nullableDateTimeFromJson, toJson: nullableDateTimeToJson)
  final DateTime? expectedDate;
  @JsonKey(fromJson: nullableDateTimeFromJson, toJson: nullableDateTimeToJson)
  final DateTime? receivedDate;
  @JsonKey(defaultValue: 0.0)
  final double totalAmount;
  final String? notes;
  @JsonKey(defaultValue: [])
  final List<PurchaseItem> items;
  @JsonKey(readValue: _readItemsCount, defaultValue: 0)
  final int itemsCount;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime updatedAt;

  // Computed from backend
  final bool? isFullyReceived;

  Purchase({
    required this.id,
    required this.number,
    required this.status,
    this.supplierId,
    this.supplier,
    this.orderDate,
    this.expectedDate,
    this.receivedDate,
    required this.totalAmount,
    this.notes,
    this.items = const [],
    this.itemsCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isFullyReceived,
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedTotalAmount => '${totalAmount.toStringAsFixed(2)} ₽';

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get canEdit => status == PurchaseStatus.draft;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get canReceive => status == PurchaseStatus.ordered || status == PurchaseStatus.partial;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isFinal => status == PurchaseStatus.received || status == PurchaseStatus.cancelled;

  factory Purchase.fromJson(Map<String, dynamic> json) =>
      _$PurchaseFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseToJson(this);
}

// Helper functions
PurchaseStatus _purchaseStatusFromJson(String value) =>
    PurchaseStatus.fromString(value);

String _purchaseStatusToJson(PurchaseStatus status) => status.toJson();

Object? _readItemsCount(Map<dynamic, dynamic> json, String key) {
  // Try _count.items first, then items.length
  final count = (json['_count'] as Map<String, dynamic>?)?['items'];
  if (count != null) return count;
  final items = json['items'] as List<dynamic>?;
  return items?.length ?? 0;
}

@JsonSerializable()
class PurchasesResponse {
  final List<Purchase> purchases;
  @JsonKey(readValue: _readPage, defaultValue: 1)
  final int page;
  @JsonKey(readValue: _readPerPage, defaultValue: 20)
  final int perPage;
  @JsonKey(readValue: _readTotal, defaultValue: 0)
  final int total;
  @JsonKey(readValue: _readTotalPages, defaultValue: 1)
  final int totalPages;

  PurchasesResponse({
    required this.purchases,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory PurchasesResponse.fromJson(Map<String, dynamic> json) =>
      _$PurchasesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PurchasesResponseToJson(this);
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
