import 'package:json_annotation/json_annotation.dart';
import 'json_converters.dart';

part 'pricing_settings.g.dart';

/// Настройки ценообразования
@JsonSerializable(createToJson: false)
class PricingSettings {
  final String id;
  final String tenantId;
  final double defaultRate;
  final double overheadPct;
  final double defaultMarginPct;
  @JsonKey(fromJson: _roleRatesFromJson, toJson: _roleRatesToJson)
  final Map<String, double> roleRates;
  @JsonKey(fromJson: nullableDateTimeFromJson, toJson: nullableDateTimeToJson)
  final DateTime? createdAt;
  @JsonKey(fromJson: nullableDateTimeFromJson, toJson: nullableDateTimeToJson)
  final DateTime? updatedAt;

  PricingSettings({
    required this.id,
    required this.tenantId,
    required this.defaultRate,
    required this.overheadPct,
    required this.defaultMarginPct,
    required this.roleRates,
    this.createdAt,
    this.updatedAt,
  });

  /// Ставка для роли (или дефолтная)
  double getRateForRole(String? role) {
    if (role == null) return defaultRate;
    return roleRates[role] ?? defaultRate;
  }

  factory PricingSettings.fromJson(Map<String, dynamic> json) =>
      _$PricingSettingsFromJson(json);

  Map<String, dynamic> toJson() => {
        'defaultRate': defaultRate,
        'overheadPct': overheadPct,
        'defaultMarginPct': defaultMarginPct,
        'roleRates': roleRates,
      };
}

Map<String, double> _roleRatesFromJson(dynamic value) {
  if (value == null) return {};
  if (value is! Map) return {};
  final Map<String, double> result = {};
  value.forEach((key, val) {
    result[key as String] = (val as num).toDouble();
  });
  return result;
}

Map<String, dynamic> _roleRatesToJson(Map<String, double> rates) => rates;

/// Рекомендация по цене
@JsonSerializable()
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
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedSuggestedPrice => '${suggestedTotal.toStringAsFixed(0)} сом';

  /// Форматированная цена за единицу
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedUnitPrice => '${suggestedUnitPrice.toStringAsFixed(0)} сом';

  /// Форматированная себестоимость
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedCost => '${totalCost.toStringAsFixed(0)} сом';

  factory PriceSuggestion.fromJson(Map<String, dynamic> json) =>
      _$PriceSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$PriceSuggestionToJson(this);
}

/// Разбивка цены
@JsonSerializable()
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
  @JsonKey(includeFromJson: false, includeToJson: false)
  double get cost => materials + labor + overhead;

  /// Полная цена (с наценкой)
  @JsonKey(includeFromJson: false, includeToJson: false)
  double get total => cost + margin;

  factory PriceBreakdown.fromJson(Map<String, dynamic> json) =>
      _$PriceBreakdownFromJson(json);
  Map<String, dynamic> toJson() => _$PriceBreakdownToJson(this);
}
