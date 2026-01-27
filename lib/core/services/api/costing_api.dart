import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';

/// Costing, pricing and profitability API mixin
mixin CostingApiMixin on BaseApiService {
  // ==================== ORDER COST ====================

  /// Get order cost
  Future<OrderCost> getOrderCost(String orderId) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/orders/$orderId/cost'),
      headers: await getHeaders(),
    );

    return handleResponse(response, OrderCost.fromJson);
  }

  /// Recalculate order cost
  Future<OrderCost> recalculateOrderCost(String orderId) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/orders/$orderId/cost/recalc'),
      headers: await getHeaders(),
    );

    return handleResponse(response, OrderCost.fromJson);
  }

  // ==================== COSTING (PRICE SUGGESTION & REPORTS) ====================

  /// Get price suggestion for model
  Future<PriceSuggestion> getPriceSuggestion({
    required String modelId,
    required int quantity,
    double? marginPct,
  }) async {
    final queryParams = {
      'modelId': modelId,
      'quantity': quantity.toString(),
      if (marginPct != null) 'marginPct': marginPct.toString(),
    };

    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/costing/price-suggestion')
          .replace(queryParameters: queryParams),
      headers: await getHeaders(),
    );

    return handleResponse(response, PriceSuggestion.fromJson);
  }

  /// Get profitability report
  Future<ProfitabilityReport> getProfitabilityReport({
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      if (period != null) 'period': period,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };

    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/costing/profitability')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null),
      headers: await getHeaders(),
    );

    return handleResponse(response, ProfitabilityReport.fromJson);
  }

  /// Get variance report
  Future<VarianceReport> getVarianceReport({
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      if (period != null) 'period': period,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };

    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/costing/variance-report')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null),
      headers: await getHeaders(),
    );

    return handleResponse(response, VarianceReport.fromJson);
  }

  // ==================== PRICING SETTINGS ====================

  /// Get pricing settings
  Future<PricingSettings> getPricingSettings() async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/settings/pricing'),
      headers: await getHeaders(),
    );

    return handleResponse(response, PricingSettings.fromJson);
  }

  /// Update pricing settings
  Future<PricingSettings> updatePricingSettings({
    double? defaultRate,
    double? overheadPct,
    double? defaultMarginPct,
    Map<String, double>? roleRates,
  }) async {
    final response = await http.patch(
      Uri.parse('${BaseApiService.baseUrl}/settings/pricing'),
      headers: await getHeaders(),
      body: jsonEncode({
        if (defaultRate != null) 'defaultRate': defaultRate,
        if (overheadPct != null) 'overheadPct': overheadPct,
        if (defaultMarginPct != null) 'defaultMarginPct': defaultMarginPct,
        if (roleRates != null) 'roleRates': roleRates,
      }),
    );

    return handleResponse(response, PricingSettings.fromJson);
  }
}
