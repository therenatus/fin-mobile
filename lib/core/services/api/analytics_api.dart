import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';

mixin AnalyticsApiMixin on BaseApiService {
  Future<AnalyticsDashboard> getAnalyticsDashboard({String period = 'month'}) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/analytics/dashboard?period=$period'),
      headers: await getHeaders(),
    );

    return handleResponse(response, AnalyticsDashboard.fromJson);
  }

  Future<DashboardStats> getDashboardStats({String period = 'month'}) async {
    final dashboard = await getAnalyticsDashboard(period: period);
    return dashboard.summary;
  }

  Future<Map<String, dynamic>> getWorkloadCalendar({
    int days = 14,
    String? employeeId,
  }) async {
    final queryParams = <String, String>{
      'days': days.toString(),
    };
    if (employeeId != null) queryParams['employeeId'] = employeeId;

    final uri = Uri.parse('${BaseApiService.baseUrl}/analytics/workload/calendar')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] ?? body;
      return data as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (!refreshed) {
        BaseApiService.notifySessionExpired();
        throw createException('Сессия истекла', statusCode: 401);
      }
      final retryResponse = await http.get(
        uri,
        headers: await getHeaders(),
      );
      if (retryResponse.statusCode == 200) {
        final body = jsonDecode(retryResponse.body) as Map<String, dynamic>;
        final data = body['data'] ?? body;
        return data as Map<String, dynamic>;
      }
      throw createException('Failed to get workload calendar', statusCode: retryResponse.statusCode);
    } else {
      throw createException(
        'Failed to get workload calendar',
        statusCode: response.statusCode,
      );
    }
  }
}
