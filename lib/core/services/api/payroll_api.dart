import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';

mixin PayrollApiMixin on BaseApiService {
  Future<List<WorkLog>> getWorkLogs() async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/payroll/worklogs'),
      headers: await getHeaders(),
    );

    return handleListResponse(response, WorkLog.fromJson, 'worklogs');
  }

  Future<WorkLog> createWorkLog({
    required String employeeId,
    required String orderId,
    required String step,
    required int quantity,
    required double hours,
    required DateTime date,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/payroll/worklogs'),
      headers: await getHeaders(),
      body: jsonEncode({
        'employeeId': employeeId,
        'orderId': orderId,
        'step': step,
        'quantity': quantity,
        'hours': hours,
        'date': date.toIso8601String(),
      }),
    );

    return handleResponse(response, WorkLog.fromJson);
  }

  Future<List<Payroll>> getPayrolls() async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/payroll'),
      headers: await getHeaders(),
    );

    return handleListResponse(response, Payroll.fromJson, 'payrolls');
  }

  Future<Payroll> generatePayroll({
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/payroll/generate'),
      headers: await getHeaders(),
      body: jsonEncode({
        'periodStart': periodStart.toIso8601String(),
        'periodEnd': periodEnd.toIso8601String(),
      }),
    );

    return handleResponse(response, Payroll.fromJson);
  }
}
