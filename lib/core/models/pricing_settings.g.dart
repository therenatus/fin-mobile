// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PricingSettings _$PricingSettingsFromJson(Map<String, dynamic> json) =>
    PricingSettings(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      defaultRate: (json['defaultRate'] as num).toDouble(),
      overheadPct: (json['overheadPct'] as num).toDouble(),
      defaultMarginPct: (json['defaultMarginPct'] as num).toDouble(),
      roleRates: _roleRatesFromJson(json['roleRates']),
      createdAt: nullableDateTimeFromJson(json['createdAt']),
      updatedAt: nullableDateTimeFromJson(json['updatedAt']),
    );

PriceSuggestion _$PriceSuggestionFromJson(Map<String, dynamic> json) =>
    PriceSuggestion(
      unitCost: (json['unitCost'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      marginPct: (json['marginPct'] as num).toDouble(),
      suggestedTotal: (json['suggestedTotal'] as num).toDouble(),
      suggestedUnitPrice: (json['suggestedUnitPrice'] as num).toDouble(),
      breakdown: PriceBreakdown.fromJson(
        json['breakdown'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$PriceSuggestionToJson(PriceSuggestion instance) =>
    <String, dynamic>{
      'unitCost': instance.unitCost,
      'totalCost': instance.totalCost,
      'marginPct': instance.marginPct,
      'suggestedTotal': instance.suggestedTotal,
      'suggestedUnitPrice': instance.suggestedUnitPrice,
      'breakdown': instance.breakdown.toJson(),
    };

PriceBreakdown _$PriceBreakdownFromJson(Map<String, dynamic> json) =>
    PriceBreakdown(
      materials: (json['materials'] as num).toDouble(),
      labor: (json['labor'] as num).toDouble(),
      overhead: (json['overhead'] as num).toDouble(),
      margin: (json['margin'] as num).toDouble(),
    );

Map<String, dynamic> _$PriceBreakdownToJson(PriceBreakdown instance) =>
    <String, dynamic>{
      'materials': instance.materials,
      'labor': instance.labor,
      'overhead': instance.overhead,
      'margin': instance.margin,
    };
