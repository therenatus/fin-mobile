import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';

mixin AssignmentsApiMixin on BaseApiService {
  Future<List<OrderAssignment>> getOrderAssignments(String orderId) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/orders/$orderId/assignments'),
      headers: await getHeaders(),
    );

    return handleListResponse(response, OrderAssignment.fromJson, 'assignments');
  }

  Future<OrderAssignment> createOrderAssignment({
    required String orderId,
    required String stepName,
    required String employeeId,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/orders/$orderId/assignments'),
      headers: await getHeaders(),
      body: jsonEncode({
        'stepName': stepName,
        'employeeId': employeeId,
      }),
    );

    return handleResponse(response, OrderAssignment.fromJson);
  }

  Future<void> deleteOrderAssignment(String orderId, String assignmentId) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/orders/$orderId/assignments/$assignmentId'),
      headers: await getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw createException(
        body['message'] ?? 'Failed to delete assignment',
        statusCode: response.statusCode,
      );
    }
  }
}
