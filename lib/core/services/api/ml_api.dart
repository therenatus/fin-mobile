import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';

mixin MlApiMixin on BaseApiService {
  Future<Forecast> getOrdersForecast({int days = 7}) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/ml/forecast/orders?days=$days'),
      headers: await getHeaders(),
    );

    return handleResponse(response, Forecast.fromJson);
  }

  Future<Forecast> getRevenueForecast({int days = 7}) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/ml/forecast/revenue?days=$days'),
      headers: await getHeaders(),
    );

    return handleResponse(response, Forecast.fromJson);
  }

  Future<BusinessInsights> getBusinessInsights() async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/ml/insights'),
      headers: await getHeaders(),
    );

    return handleResponse(response, BusinessInsights.fromJson);
  }

  Future<MlReport> generateMlReport({
    required String type,
    String? periodStart,
    String? periodEnd,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/ml/report'),
      headers: await getHeaders(),
      body: jsonEncode({
        'type': type,
        if (periodStart != null) 'periodStart': periodStart,
        if (periodEnd != null) 'periodEnd': periodEnd,
      }),
    );

    return handleResponse(response, MlReport.fromJson);
  }

  Future<List<MlReport>> getReportHistory({String? type, int limit = 10}) async {
    final queryParams = <String, String>{'limit': limit.toString()};
    if (type != null) queryParams['type'] = type;

    final uri = Uri.parse('${BaseApiService.baseUrl}/ml/reports/history')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: await getHeaders(),
    );

    return handleListResponse(response, MlReport.fromJson, 'reports');
  }

  Future<MlUsageInfo> getMlUsageInfo() async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/ml/usage'),
      headers: await getHeaders(),
    );

    return handleResponse(response, MlUsageInfo.fromJson);
  }
}
