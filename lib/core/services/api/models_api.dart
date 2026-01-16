import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';

mixin ModelsApiMixin on BaseApiService {
  Future<List<OrderModel>> getModels({int page = 1, int limit = 50}) async {
    return getListWithRetry(
      () async => http.get(
        Uri.parse('${BaseApiService.baseUrl}/models?page=$page&limit=$limit'),
        headers: await getHeaders(),
      ),
      OrderModel.fromJson,
      'models',
    );
  }

  Future<OrderModel> getModel(String id) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/models/$id'),
      headers: await getHeaders(),
    );

    return handleResponse(response, OrderModel.fromJson);
  }

  Future<OrderModel> createModel({
    required String name,
    String? category,
    required double basePrice,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/models'),
      headers: await getHeaders(),
      body: jsonEncode({
        'name': name,
        if (category != null) 'category': category,
        'basePrice': basePrice,
        if (description != null) 'description': description,
      }),
    );

    return handleResponse(response, OrderModel.fromJson);
  }

  Future<OrderModel> updateModel({
    required String id,
    String? name,
    String? category,
    double? basePrice,
    String? description,
  }) async {
    final response = await http.put(
      Uri.parse('${BaseApiService.baseUrl}/models/$id'),
      headers: await getHeaders(),
      body: jsonEncode({
        if (name != null) 'name': name,
        if (category != null) 'category': category,
        if (basePrice != null) 'basePrice': basePrice,
        if (description != null) 'description': description,
      }),
    );

    return handleResponse(response, OrderModel.fromJson);
  }

  Future<void> deleteModel(String id) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/models/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw createException(
        body['message'] ?? 'Failed to delete model',
        statusCode: response.statusCode,
      );
    }
  }

  Future<OrderModel> uploadModelImage(String modelId, File file) async {
    final token = await getAccessToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseApiService.baseUrl}/models/$modelId/image'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('image', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return handleResponse(response, OrderModel.fromJson);
  }

  Future<OrderModel> deleteModelImage(String modelId) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/models/$modelId/image'),
      headers: await getHeaders(),
    );

    return handleResponse(response, OrderModel.fromJson);
  }

  Future<List<ProcessStep>> getProcessSteps(String modelId) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/models/$modelId/steps'),
      headers: await getHeaders(),
    );

    return handleListResponse(response, ProcessStep.fromJson, 'steps');
  }

  Future<ProcessStep> createProcessStep({
    required String modelId,
    required int stepOrder,
    required String name,
    required int estimatedTime,
    required String executorRole,
    double? rate,
    String? rateType,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/models/$modelId/steps'),
      headers: await getHeaders(),
      body: jsonEncode({
        'stepOrder': stepOrder,
        'name': name,
        'estimatedTime': estimatedTime,
        'executorRole': executorRole,
        if (rate != null) 'rate': rate,
        if (rateType != null) 'rateType': rateType,
      }),
    );

    return handleResponse(response, ProcessStep.fromJson);
  }

  Future<ProcessStep> updateProcessStep({
    required String stepId,
    int? stepOrder,
    String? name,
    int? estimatedTime,
    String? executorRole,
    double? rate,
    String? rateType,
  }) async {
    final response = await http.put(
      Uri.parse('${BaseApiService.baseUrl}/models/steps/$stepId'),
      headers: await getHeaders(),
      body: jsonEncode({
        if (stepOrder != null) 'stepOrder': stepOrder,
        if (name != null) 'name': name,
        if (estimatedTime != null) 'estimatedTime': estimatedTime,
        if (executorRole != null) 'executorRole': executorRole,
        if (rate != null) 'rate': rate,
        if (rateType != null) 'rateType': rateType,
      }),
    );

    return handleResponse(response, ProcessStep.fromJson);
  }

  Future<void> deleteProcessStep(String stepId) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/models/steps/$stepId'),
      headers: await getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw createException(
        body['message'] ?? 'Failed to delete process step',
        statusCode: response.statusCode,
      );
    }
  }
}
