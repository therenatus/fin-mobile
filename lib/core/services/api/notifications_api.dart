import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_api_service.dart';

mixin NotificationsApiMixin on BaseApiService {
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
}
