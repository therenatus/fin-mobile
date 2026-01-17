class Supplier {
  final String id;
  final String name;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? address;
  final String? inn;
  final String? notes;
  final bool isActive;
  final int materialsCount;
  final int purchasesCount;
  final DateTime createdAt;
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

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      name: json['name'] as String,
      contactName: json['contactName'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      inn: json['inn'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      materialsCount: (json['_count']?['materials'] as int?) ?? 0,
      purchasesCount: (json['_count']?['purchases'] as int?) ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'contactName': contactName,
        'phone': phone,
        'email': email,
        'address': address,
        'inn': inn,
        'notes': notes,
      };

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  bool get hasContact => contactName != null || phone != null || email != null;
}

class SuppliersResponse {
  final List<Supplier> suppliers;
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  SuppliersResponse({
    required this.suppliers,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory SuppliersResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>?;
    return SuppliersResponse(
      suppliers: (json['suppliers'] as List<dynamic>)
          .map((e) => Supplier.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: meta?['page'] as int? ?? 1,
      perPage: meta?['per_page'] as int? ?? 20,
      total: meta?['total'] as int? ?? 0,
      totalPages: meta?['total_pages'] as int? ?? 1,
    );
  }
}
