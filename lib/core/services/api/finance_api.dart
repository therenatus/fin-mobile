import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';

mixin FinanceApiMixin on BaseApiService {
  Future<List<Transaction>> getTransactions({
    String? type,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (type != null) queryParams['type'] = type;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final uri = Uri.parse('${BaseApiService.baseUrl}/finance/transactions')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: await getHeaders(),
    );

    return handleListResponse(response, Transaction.fromJson, 'transactions');
  }

  Future<Transaction> createTransaction({
    required DateTime date,
    required String type,
    required String category,
    required double amount,
    String? description,
    String? orderId,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/finance/transactions'),
      headers: await getHeaders(),
      body: jsonEncode({
        'date': date.toIso8601String(),
        'type': type,
        'category': category,
        'amount': amount,
        if (description != null) 'description': description,
        if (orderId != null) 'orderId': orderId,
      }),
    );

    return handleResponse(response, Transaction.fromJson);
  }

  Future<void> deleteTransaction(String id) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/finance/transactions/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw createException(
        body['message'] ?? 'Failed to delete transaction',
        statusCode: response.statusCode,
      );
    }
  }

  Future<FinanceReport> getFinanceReport({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final uri = Uri.parse('${BaseApiService.baseUrl}/finance/report')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: await getHeaders(),
    );

    return handleResponse(response, FinanceReport.fromJson);
  }
}
