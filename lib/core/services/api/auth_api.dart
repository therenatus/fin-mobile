import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../models/models.dart';
import '../base_api_service.dart';

mixin AuthApiMixin on BaseApiService {
  Future<AuthResponse> login(String email, String password) async {
    return performLogin(
      endpoint: '/auth/login',
      body: {'email': email, 'password': password},
      fromJson: AuthResponse.fromJson,
      onSuccess: (response) async {
        await storage.saveTokens(response.accessToken, response.refreshToken);
        await storage.saveUser(response.user);
        log('LOGIN: Success! User: ${response.user.email}');
      },
    );
  }

  Future<AuthResponse> register(String email, String password, String tenantName) async {
    return withNetworkErrorHandling(() async {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrl}/auth/signup'),
        headers: await getHeaders(auth: false),
        body: jsonEncode({
          'email': email,
          'password': password,
          'tenantName': tenantName,
        }),
      ).timeout(const Duration(seconds: 15));

      final authResponse = await handleResponse(response, AuthResponse.fromJson);
      await storage.saveTokens(authResponse.accessToken, authResponse.refreshToken);
      await storage.saveUser(authResponse.user);

      return authResponse;
    });
  }

  Future<void> logout() async {
    return performLogout(
      endpoint: '/auth/logout',
      onComplete: () => storage.clearAll(),
    );
  }

  Future<Map<String, dynamic>> getProfile() async {
    log('getProfile: calling ${BaseApiService.baseUrl}/auth/me');
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/auth/me'),
      headers: await getHeaders(),
    );

    log('getProfile: status=${response.statusCode}');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body['data'] ?? body;
    }
    throw createException(
      body['message'] ?? 'Failed to get profile',
      statusCode: response.statusCode,
    );
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/auth/change-password'),
      headers: await getHeaders(),
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw createException(
        body['message'] ?? 'Failed to change password',
        statusCode: response.statusCode,
      );
    }
  }

  Future<User> uploadAvatar(File file) async {
    final token = await getAccessToken();
    log('uploadAvatar: file=${file.path}');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseApiService.baseUrl}/auth/profile/avatar'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    final extension = file.path.split('.').last.toLowerCase();
    final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

    final multipartFile = await http.MultipartFile.fromPath(
      'avatar',
      file.path,
      contentType: MediaType.parse(mimeType),
    );
    request.files.add(multipartFile);

    log('uploadAvatar: sending to ${BaseApiService.baseUrl}/auth/profile/avatar');
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    log('uploadAvatar: status=${response.statusCode}');

    final user = await handleResponse(response, User.fromJson);
    await storage.saveUser(user);
    return user;
  }

  Future<User> deleteAvatar() async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/auth/profile/avatar'),
      headers: await getHeaders(),
    );

    final user = await handleResponse(response, User.fromJson);
    await storage.saveUser(user);
    return user;
  }
}
