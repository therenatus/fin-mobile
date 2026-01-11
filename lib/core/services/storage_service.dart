import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../models/client_user.dart';
import '../models/employee_user.dart';

class StorageService {
  // Manager tokens
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user';
  // Client tokens
  static const String _clientAccessTokenKey = 'client_access_token';
  static const String _clientRefreshTokenKey = 'client_refresh_token';
  static const String _clientUserKey = 'client_user';
  // Employee tokens
  static const String _employeeAccessTokenKey = 'employee_access_token';
  static const String _employeeRefreshTokenKey = 'employee_refresh_token';
  static const String _employeeUserKey = 'employee_user';
  // Settings
  static const String _themeKey = 'theme_mode';
  static const String _appModeKey = 'app_mode'; // 'manager', 'client', or 'employee'

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ==================== TOKENS ====================

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final p = await prefs;
    await p.setString(_accessTokenKey, accessToken);
    await p.setString(_refreshTokenKey, refreshToken);
  }

  Future<String?> getAccessToken() async {
    final p = await prefs;
    return p.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final p = await prefs;
    return p.getString(_refreshTokenKey);
  }

  Future<void> clearTokens() async {
    final p = await prefs;
    await p.remove(_accessTokenKey);
    await p.remove(_refreshTokenKey);
  }

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== USER ====================

  Future<void> saveUser(User user) async {
    final p = await prefs;
    await p.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final p = await prefs;
    final userJson = p.getString(_userKey);
    if (userJson == null) return null;
    try {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearUser() async {
    final p = await prefs;
    await p.remove(_userKey);
  }

  // ==================== CLIENT TOKENS ====================

  Future<void> saveClientTokens(String accessToken, String refreshToken) async {
    final p = await prefs;
    await p.setString(_clientAccessTokenKey, accessToken);
    await p.setString(_clientRefreshTokenKey, refreshToken);
  }

  Future<String?> getClientAccessToken() async {
    final p = await prefs;
    return p.getString(_clientAccessTokenKey);
  }

  Future<String?> getClientRefreshToken() async {
    final p = await prefs;
    return p.getString(_clientRefreshTokenKey);
  }

  Future<void> clearClientTokens() async {
    final p = await prefs;
    await p.remove(_clientAccessTokenKey);
    await p.remove(_clientRefreshTokenKey);
    await p.remove(_clientUserKey);
  }

  Future<bool> hasClientTokens() async {
    final token = await getClientAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== CLIENT USER ====================

  Future<void> saveClientUser(ClientUser user) async {
    final p = await prefs;
    await p.setString(_clientUserKey, jsonEncode(user.toJson()));
  }

  Future<ClientUser?> getClientUser() async {
    final p = await prefs;
    final userJson = p.getString(_clientUserKey);
    if (userJson == null) return null;
    try {
      return ClientUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  // ==================== APP MODE ====================

  Future<void> saveAppMode(String mode) async {
    final p = await prefs;
    await p.setString(_appModeKey, mode);
  }

  Future<String?> getAppMode() async {
    final p = await prefs;
    return p.getString(_appModeKey);
  }

  Future<void> clearAppMode() async {
    final p = await prefs;
    await p.remove(_appModeKey);
  }

  // ==================== THEME ====================

  Future<void> saveThemeMode(String mode) async {
    final p = await prefs;
    await p.setString(_themeKey, mode);
  }

  Future<String> getThemeMode() async {
    final p = await prefs;
    return p.getString(_themeKey) ?? 'system';
  }

  // ==================== CLEAR ALL ====================

  Future<void> clearAll() async {
    final p = await prefs;
    await p.clear();
  }

  Future<void> clearManagerData() async {
    await clearTokens();
    await clearUser();
  }

  Future<void> clearClientData() async {
    await clearClientTokens();
  }

  // ==================== EMPLOYEE TOKENS ====================

  Future<void> saveEmployeeTokens(String accessToken, String refreshToken) async {
    final p = await prefs;
    await p.setString(_employeeAccessTokenKey, accessToken);
    await p.setString(_employeeRefreshTokenKey, refreshToken);
  }

  Future<String?> getEmployeeAccessToken() async {
    final p = await prefs;
    return p.getString(_employeeAccessTokenKey);
  }

  Future<String?> getEmployeeRefreshToken() async {
    final p = await prefs;
    return p.getString(_employeeRefreshTokenKey);
  }

  Future<void> clearEmployeeTokens() async {
    final p = await prefs;
    await p.remove(_employeeAccessTokenKey);
    await p.remove(_employeeRefreshTokenKey);
    await p.remove(_employeeUserKey);
  }

  Future<bool> hasEmployeeTokens() async {
    final token = await getEmployeeAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== EMPLOYEE USER ====================

  Future<void> saveEmployeeUser(EmployeeUser user) async {
    final p = await prefs;
    await p.setString(_employeeUserKey, jsonEncode(user.toJson()));
  }

  Future<EmployeeUser?> getEmployeeUser() async {
    final p = await prefs;
    final userJson = p.getString(_employeeUserKey);
    if (userJson == null) return null;
    try {
      return EmployeeUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearEmployeeData() async {
    await clearEmployeeTokens();
  }
}
