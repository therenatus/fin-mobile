import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';

mixin BillingApiMixin on BaseApiService {
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/billing/plans'),
      headers: await getHeaders(auth: false),
    );

    return handleListResponse(response, SubscriptionPlan.fromJson, 'plans');
  }

  Future<ResourceUsage> getResourceUsage() async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/billing/usage'),
      headers: await getHeaders(),
    );

    return handleResponse(response, ResourceUsage.fromJson);
  }

  Future<Subscription?> getCurrentSubscription() async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/billing/subscription'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 404) {
      return null;
    }

    return handleResponse(response, Subscription.fromJson);
  }

  Future<Subscription> verifyGooglePlayPurchase({
    required String productId,
    required String purchaseToken,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/billing/verify/google-play'),
      headers: await getHeaders(),
      body: jsonEncode({
        'productId': productId,
        'purchaseToken': purchaseToken,
      }),
    );

    return handleResponse(response, Subscription.fromJson);
  }

  Future<Subscription> verifyAppStorePurchase({
    required String receiptData,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/billing/verify/app-store'),
      headers: await getHeaders(),
      body: jsonEncode({
        'receiptData': receiptData,
      }),
    );

    return handleResponse(response, Subscription.fromJson);
  }
}
