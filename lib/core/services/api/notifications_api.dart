import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_api_service.dart';
import '../../models/in_app_notification.dart';

mixin NotificationsApiMixin on BaseApiService {
  // ==================== DEVICE REGISTRATION ====================

  Future<void> registerPushDevice(String playerId) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrl}/notifications/devices/register'),
        headers: await getHeaders(),
        body: jsonEncode({'playerId': playerId}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        log('Push device registered successfully');
      } else {
        log('Failed to register push device: ${response.statusCode}');
      }
    } catch (e) {
      log('Error registering push device: $e');
    }
  }

  Future<void> unregisterPushDevice() async {
    try {
      final response = await http.delete(
        Uri.parse('${BaseApiService.baseUrl}/notifications/devices/unregister'),
        headers: await getHeaders(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        log('Push device unregistered successfully');
      } else {
        log('Failed to unregister push device: ${response.statusCode}');
      }
    } catch (e) {
      log('Error unregistering push device: $e');
    }
  }

  // ==================== NOTIFICATION HISTORY ====================

  Future<NotificationHistoryResponse> getNotificationHistory({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (unreadOnly) 'unreadOnly': 'true',
    };

    final uri = Uri.parse('${BaseApiService.baseUrl}/notifications/history')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await getHeaders());

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return NotificationHistoryResponse.fromJson(json);
    } else {
      throw Exception('Failed to get notification history: ${response.statusCode}');
    }
  }

  Future<int> getUnreadNotificationCount() async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/notifications/unread-count'),
      headers: await getHeaders(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return UnreadCountResponse.fromJson(json).unreadCount;
    } else {
      throw Exception('Failed to get unread count: ${response.statusCode}');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final response = await http.patch(
      Uri.parse('${BaseApiService.baseUrl}/notifications/$notificationId/read'),
      headers: await getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to mark notification as read: ${response.statusCode}');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    final response = await http.patch(
      Uri.parse('${BaseApiService.baseUrl}/notifications/read-all'),
      headers: await getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to mark all notifications as read: ${response.statusCode}');
    }
  }

  // ==================== NOTIFICATION PREFERENCES ====================

  Future<NotificationPreferences> getNotificationPreferences() async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/notifications/preferences'),
      headers: await getHeaders(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return NotificationPreferences.fromJson(json);
    } else {
      throw Exception('Failed to get notification preferences: ${response.statusCode}');
    }
  }

  Future<void> updateNotificationPreferences({required bool pushEnabled}) async {
    final response = await http.patch(
      Uri.parse('${BaseApiService.baseUrl}/notifications/preferences'),
      headers: await getHeaders(),
      body: jsonEncode({'pushEnabled': pushEnabled}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update notification preferences: ${response.statusCode}');
    }
  }
}
