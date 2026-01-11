class ClientContact {
  final String? email;
  final String? phone;
  final String? telegram;
  final String? whatsapp;

  ClientContact({this.email, this.phone, this.telegram, this.whatsapp});

  factory ClientContact.fromJson(Map<String, dynamic> json) {
    return ClientContact(
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      telegram: json['telegram'] as String?,
      whatsapp: json['whatsapp'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'phone': phone,
    'telegram': telegram,
    'whatsapp': whatsapp,
  };
}

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

  factory ClientAssignedModel.fromJson(Map<String, dynamic> json) {
    return ClientAssignedModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      basePrice: (json['basePrice'] as num).toDouble(),
    );
  }
}

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
  final List<String> assignedModelIds;
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

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      name: json['name'] as String,
      contacts: ClientContact.fromJson(json['contacts'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      ordersCount: json['ordersCount'] as int?,
      totalSpent: (json['totalSpent'] as num?)?.toDouble(),
      assignedModelIds: (json['assignedModelIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      assignedModels: (json['assignedModels'] as List<dynamic>?)
          ?.map((e) => ClientAssignedModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contacts': contacts.toJson(),
      'preferences': preferences,
    };
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  bool get isVip => (totalSpent ?? 0) > 50000 || (ordersCount ?? 0) > 10;
}
