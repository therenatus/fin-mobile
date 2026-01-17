/// Настройки ценообразования
class PricingSettings {
  final String id;
  final String tenantId;
  final double defaultHourlyRate;
  final double overheadPct;
  final double defaultMarginPct;
  final Map<String, double> roleRates;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PricingSettings({
    required this.id,
    required this.tenantId,
    required this.defaultHourlyRate,
    required this.overheadPct,
    required this.defaultMarginPct,
    required this.roleRates,
    this.createdAt,
    this.updatedAt,
  });

  /// Ставка для роли (или дефолтная)
  double getRateForRole(String? role) {
    if (role == null) return defaultHourlyRate;
    return roleRates[role] ?? defaultHourlyRate;
  }

  factory PricingSettings.fromJson(Map<String, dynamic> json) {
    // Parse roleRates - can be Map<String, num>
    final rawRates = json['roleRates'];
    Map<String, double> rates = {};
    if (rawRates is Map) {
      rawRates.forEach((key, value) {
        rates[key as String] = (value as num).toDouble();
      });
    }

    return PricingSettings(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      defaultHourlyRate: (json['defaultHourlyRate'] as num).toDouble(),
      overheadPct: (json['overheadPct'] as num).toDouble(),
      defaultMarginPct: (json['defaultMarginPct'] as num).toDouble(),
      roleRates: rates,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'defaultHourlyRate': defaultHourlyRate,
        'overheadPct': overheadPct,
        'defaultMarginPct': defaultMarginPct,
        'roleRates': roleRates,
      };
}

/// Рекомендация по цене
class PriceSuggestion {
  final double unitCost;
  final double totalCost;
  final double marginPct;
  final double suggestedTotal;
  final double suggestedUnitPrice;
  final PriceBreakdown breakdown;

  PriceSuggestion({
    required this.unitCost,
    required this.totalCost,
    required this.marginPct,
    required this.suggestedTotal,
    required this.suggestedUnitPrice,
    required this.breakdown,
  });

  /// Форматированная рекомендованная цена
  String get formattedSuggestedPrice => '${suggestedTotal.toStringAsFixed(0)} ₽';

  /// Форматированная цена за единицу
  String get formattedUnitPrice => '${suggestedUnitPrice.toStringAsFixed(0)} ₽';

  /// Форматированная себестоимость
  String get formattedCost => '${totalCost.toStringAsFixed(0)} ₽';

  factory PriceSuggestion.fromJson(Map<String, dynamic> json) {
    return PriceSuggestion(
      unitCost: (json['unitCost'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      marginPct: (json['marginPct'] as num).toDouble(),
      suggestedTotal: (json['suggestedTotal'] as num).toDouble(),
      suggestedUnitPrice: (json['suggestedUnitPrice'] as num).toDouble(),
      breakdown: PriceBreakdown.fromJson(json['breakdown'] as Map<String, dynamic>),
    );
  }
}

/// Разбивка цены
class PriceBreakdown {
  final double materials;
  final double labor;
  final double overhead;
  final double margin;

  PriceBreakdown({
    required this.materials,
    required this.labor,
    required this.overhead,
    required this.margin,
  });

  /// Себестоимость (без наценки)
  double get cost => materials + labor + overhead;

  /// Полная цена (с наценкой)
  double get total => cost + margin;

  factory PriceBreakdown.fromJson(Map<String, dynamic> json) {
    return PriceBreakdown(
      materials: (json['materials'] as num).toDouble(),
      labor: (json['labor'] as num).toDouble(),
      overhead: (json['overhead'] as num).toDouble(),
      margin: (json['margin'] as num).toDouble(),
    );
  }
}
