import 'material.dart' show MaterialUnit;

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

class PurchaseSupplier {
  final String id;
  final String name;

  PurchaseSupplier({
    required this.id,
    required this.name,
  });

  factory PurchaseSupplier.fromJson(Map<String, dynamic> json) {
    return PurchaseSupplier(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

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

  factory PurchaseItemMaterial.fromJson(Map<String, dynamic> json) {
    return PurchaseItemMaterial(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      unit: json['unit'] as String,
      quantity: (json['quantity'] as num?)?.toDouble(),
    );
  }

  MaterialUnit get materialUnit => MaterialUnit.fromString(unit);
}

class PurchaseItem {
  final String id;
  final String purchaseId;
  final String materialId;
  final double quantity;
  final double receivedQty;
  final double unitPrice;
  final double totalPrice;
  final PurchaseItemMaterial? material;
  final DateTime createdAt;
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

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'] as String,
      purchaseId: json['purchaseId'] as String,
      materialId: json['materialId'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      receivedQty: (json['receivedQty'] as num?)?.toDouble() ?? 0,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      material: json['material'] != null
          ? PurchaseItemMaterial.fromJson(json['material'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      remainingQty: (json['remainingQty'] as num?)?.toDouble(),
      isFullyReceived: json['isFullyReceived'] as bool?,
    );
  }

  double get computedRemainingQty => remainingQty ?? (quantity - receivedQty);
  bool get computedIsFullyReceived => isFullyReceived ?? (receivedQty >= quantity);

  String get formattedQuantity {
    final unit = material?.materialUnit.label ?? '';
    return '${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 2)} $unit';
  }

  String get formattedReceivedQty {
    final unit = material?.materialUnit.label ?? '';
    return '${receivedQty.toStringAsFixed(receivedQty.truncateToDouble() == receivedQty ? 0 : 2)} $unit';
  }

  String get formattedUnitPrice => '${unitPrice.toStringAsFixed(2)} ₽';
  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(2)} ₽';
}

class Purchase {
  final String id;
  final String number;
  final PurchaseStatus status;
  final String? supplierId;
  final PurchaseSupplier? supplier;
  final DateTime? orderDate;
  final DateTime? expectedDate;
  final DateTime? receivedDate;
  final double totalAmount;
  final String? notes;
  final List<PurchaseItem> items;
  final int itemsCount;
  final DateTime createdAt;
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

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as String,
      number: json['number'] as String,
      status: PurchaseStatus.fromString(json['status'] as String),
      supplierId: json['supplierId'] as String?,
      supplier: json['supplier'] != null
          ? PurchaseSupplier.fromJson(json['supplier'] as Map<String, dynamic>)
          : null,
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate'] as String)
          : null,
      expectedDate: json['expectedDate'] != null
          ? DateTime.parse(json['expectedDate'] as String)
          : null,
      receivedDate: json['receivedDate'] != null
          ? DateTime.parse(json['receivedDate'] as String)
          : null,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PurchaseItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      itemsCount: (json['_count']?['items'] as int?) ?? (json['items'] as List<dynamic>?)?.length ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFullyReceived: json['isFullyReceived'] as bool?,
    );
  }

  String get formattedTotalAmount => '${totalAmount.toStringAsFixed(2)} ₽';

  bool get canEdit => status == PurchaseStatus.draft;
  bool get canReceive => status == PurchaseStatus.ordered || status == PurchaseStatus.partial;
  bool get isFinal => status == PurchaseStatus.received || status == PurchaseStatus.cancelled;
}

class PurchasesResponse {
  final List<Purchase> purchases;
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  PurchasesResponse({
    required this.purchases,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory PurchasesResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>?;
    return PurchasesResponse(
      purchases: (json['purchases'] as List<dynamic>)
          .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: meta?['page'] as int? ?? 1,
      perPage: meta?['per_page'] as int? ?? 20,
      total: meta?['total'] as int? ?? 0,
      totalPages: meta?['total_pages'] as int? ?? 1,
    );
  }
}
