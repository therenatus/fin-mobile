import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../models/employee_user.dart';
import 'secure_storage_service.dart';

/// Generic token handler for any user mode.
/// Consolidates duplicated token management logic.
class TokenHandler<T> {
  final SecureStorageService _secure;
  final String _accessKey;
  final String _refreshKey;
  final String _userKey;
  final T Function(Map<String, dynamic>) _fromJson;
  final Map<String, dynamic> Function(T) _toJson;

  TokenHandler({
    required SecureStorageService secure,
    required String accessKey,
    required String refreshKey,
    required String userKey,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
  })  : _secure = secure,
        _accessKey = accessKey,
        _refreshKey = refreshKey,
        _userKey = userKey,
        _fromJson = fromJson,
        _toJson = toJson;

  /// Save access and refresh tokens
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await Future.wait([
      _secure.write(_accessKey, accessToken),
      _secure.write(_refreshKey, refreshToken),
    ]);
  }

  /// Get access token
  Future<String?> getAccessToken() => _secure.read(_accessKey);

  /// Get refresh token
  Future<String?> getRefreshToken() => _secure.read(_refreshKey);

  /// Clear all tokens and user data
  Future<void> clearTokens() async {
    await Future.wait([
      _secure.delete(_accessKey),
      _secure.delete(_refreshKey),
      _secure.delete(_userKey),
    ]);
  }

  /// Check if tokens exist
  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Save user data
  Future<void> saveUser(T user) async {
    await _secure.write(_userKey, jsonEncode(_toJson(user)));
  }

  /// Get user data
  Future<T?> getUser() async {
    final userJson = await _secure.read(_userKey);
    if (userJson == null) return null;
    try {
      return _fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Clear user data only
  Future<void> clearUser() async {
    await _secure.delete(_userKey);
  }
}

class StorageService {
  // Keys for SharedPreferences (non-sensitive data)
  static const String _themeKey = 'theme_mode';
  static const String _appModeKey = 'app_mode';
  static const String _migrationKey = 'secure_storage_migrated_v1';

  // Legacy keys for migration
  static const String _legacyAccessTokenKey = 'access_token';
  static const String _legacyRefreshTokenKey = 'refresh_token';
  static const String _legacyUserKey = 'user';
  static const String _legacyClientAccessTokenKey = 'client_access_token';
  static const String _legacyClientRefreshTokenKey = 'client_refresh_token';
  static const String _legacyClientUserKey = 'client_user';
  static const String _legacyEmployeeAccessTokenKey = 'employee_access_token';
  static const String _legacyEmployeeRefreshTokenKey = 'employee_refresh_token';
  static const String _legacyEmployeeUserKey = 'employee_user';

  SharedPreferences? _prefs;
  final SecureStorageService _secure;

  /// Token handlers for each mode
  late final TokenHandler<User> managerTokens;
  late final TokenHandler<ClientUser> clientTokens;
  late final TokenHandler<EmployeeUser> employeeTokens;

  StorageService() : _secure = SecureStorageService() {
    _initTokenHandlers();
  }

  /// Constructor for testing with mock secure storage
  StorageService.withSecureStorage(this._secure) {
    _initTokenHandlers();
  }

  void _initTokenHandlers() {
    managerTokens = TokenHandler<User>(
      secure: _secure,
      accessKey: 'manager_access_token',
      refreshKey: 'manager_refresh_token',
      userKey: 'manager_user',
      fromJson: User.fromJson,
      toJson: (user) => user.toJson(),
    );

    clientTokens = TokenHandler<ClientUser>(
      secure: _secure,
      accessKey: 'client_access_token',
      refreshKey: 'client_refresh_token',
      userKey: 'client_user',
      fromJson: ClientUser.fromJson,
      toJson: (user) => user.toJson(),
    );

    employeeTokens = TokenHandler<EmployeeUser>(
      secure: _secure,
      accessKey: 'employee_access_token',
      refreshKey: 'employee_refresh_token',
      userKey: 'employee_user',
      fromJson: EmployeeUser.fromJson,
      toJson: (user) => user.toJson(),
    );
  }

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ==================== MIGRATION ====================

  /// Migrate tokens from SharedPreferences to SecureStorage (one-time)
  Future<void> migrateToSecureStorage() async {
    final p = await prefs;
    final migrated = p.getBool(_migrationKey) ?? false;
    if (migrated) return;

    debugPrint('[StorageService] Migrating tokens to secure storage...');

    try {
      // Migrate manager tokens
      final managerAccess = p.getString(_legacyAccessTokenKey);
      final managerRefresh = p.getString(_legacyRefreshTokenKey);
      final managerUser = p.getString(_legacyUserKey);

      if (managerAccess != null && managerRefresh != null) {
        await managerTokens.saveTokens(managerAccess, managerRefresh);
        if (managerUser != null) {
          try {
            final user = User.fromJson(jsonDecode(managerUser) as Map<String, dynamic>);
            await managerTokens.saveUser(user);
          } catch (_) {}
        }
        // Clear legacy data
        await p.remove(_legacyAccessTokenKey);
        await p.remove(_legacyRefreshTokenKey);
        await p.remove(_legacyUserKey);
      }

      // Migrate client tokens
      final clientAccess = p.getString(_legacyClientAccessTokenKey);
      final clientRefresh = p.getString(_legacyClientRefreshTokenKey);
      final clientUser = p.getString(_legacyClientUserKey);

      if (clientAccess != null && clientRefresh != null) {
        await clientTokens.saveTokens(clientAccess, clientRefresh);
        if (clientUser != null) {
          try {
            final user = ClientUser.fromJson(jsonDecode(clientUser) as Map<String, dynamic>);
            await clientTokens.saveUser(user);
          } catch (_) {}
        }
        // Clear legacy data
        await p.remove(_legacyClientAccessTokenKey);
        await p.remove(_legacyClientRefreshTokenKey);
        await p.remove(_legacyClientUserKey);
      }

      // Migrate employee tokens
      final employeeAccess = p.getString(_legacyEmployeeAccessTokenKey);
      final employeeRefresh = p.getString(_legacyEmployeeRefreshTokenKey);
      final employeeUser = p.getString(_legacyEmployeeUserKey);

      if (employeeAccess != null && employeeRefresh != null) {
        await employeeTokens.saveTokens(employeeAccess, employeeRefresh);
        if (employeeUser != null) {
          try {
            final user = EmployeeUser.fromJson(jsonDecode(employeeUser) as Map<String, dynamic>);
            await employeeTokens.saveUser(user);
          } catch (_) {}
        }
        // Clear legacy data
        await p.remove(_legacyEmployeeAccessTokenKey);
        await p.remove(_legacyEmployeeRefreshTokenKey);
        await p.remove(_legacyEmployeeUserKey);
      }

      await p.setBool(_migrationKey, true);
      debugPrint('[StorageService] Migration completed');
    } catch (e) {
      debugPrint('[StorageService] Migration error: $e');
    }
  }

  // ==================== MANAGER TOKENS (backwards compatible) ====================

  Future<void> saveTokens(String accessToken, String refreshToken) =>
      managerTokens.saveTokens(accessToken, refreshToken);

  Future<String?> getAccessToken() => managerTokens.getAccessToken();

  Future<String?> getRefreshToken() => managerTokens.getRefreshToken();

  Future<void> clearTokens() => managerTokens.clearTokens();

  Future<bool> hasTokens() => managerTokens.hasTokens();

  // ==================== MANAGER USER ====================

  Future<void> saveUser(User user) => managerTokens.saveUser(user);

  Future<User?> getUser() => managerTokens.getUser();

  Future<void> clearUser() => managerTokens.clearUser();

  // ==================== CLIENT TOKENS ====================

  Future<void> saveClientTokens(String accessToken, String refreshToken) =>
      clientTokens.saveTokens(accessToken, refreshToken);

  Future<String?> getClientAccessToken() => clientTokens.getAccessToken();

  Future<String?> getClientRefreshToken() => clientTokens.getRefreshToken();

  Future<void> clearClientTokens() => clientTokens.clearTokens();

  Future<bool> hasClientTokens() => clientTokens.hasTokens();

  // ==================== CLIENT USER ====================

  Future<void> saveClientUser(ClientUser user) => clientTokens.saveUser(user);

  Future<ClientUser?> getClientUser() => clientTokens.getUser();

  // ==================== EMPLOYEE TOKENS ====================

  Future<void> saveEmployeeTokens(String accessToken, String refreshToken) =>
      employeeTokens.saveTokens(accessToken, refreshToken);

  Future<String?> getEmployeeAccessToken() => employeeTokens.getAccessToken();

  Future<String?> getEmployeeRefreshToken() => employeeTokens.getRefreshToken();

  Future<void> clearEmployeeTokens() => employeeTokens.clearTokens();

  Future<bool> hasEmployeeTokens() => employeeTokens.hasTokens();

  // ==================== EMPLOYEE USER ====================

  Future<void> saveEmployeeUser(EmployeeUser user) => employeeTokens.saveUser(user);

  Future<EmployeeUser?> getEmployeeUser() => employeeTokens.getUser();

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
    await _secure.deleteAll();
  }

  Future<void> clearManagerData() async {
    await managerTokens.clearTokens();
  }

  Future<void> clearClientData() async {
    await clientTokens.clearTokens();
  }

  Future<void> clearEmployeeData() async {
    await employeeTokens.clearTokens();
  }
}
