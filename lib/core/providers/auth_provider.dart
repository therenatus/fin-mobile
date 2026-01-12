import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

void _log(String message) {
  debugPrint('[AuthProvider] $message');
}

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final StorageService _storage;
  late final ApiService _api;

  AuthState _state = AuthState.initial;
  User? _user;
  String? _error;

  AuthProvider(this._storage) {
    _api = ApiService(_storage);
    ApiService.onSessionExpired = _handleSessionExpired;
    _init();
  }

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  ApiService get api => _api;

  void _handleSessionExpired() {
    _log('Session expired - logging out');
    _storage.clearTokens();
    _storage.clearUser();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  Future<void> _init() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final hasTokens = await _storage.hasTokens();
      if (hasTokens) {
        _user = await _storage.getUser();
        if (_user != null) {
          _state = AuthState.authenticated;
          // Refresh user profile from server
          _refreshUserProfile();
        } else {
          _state = AuthState.unauthenticated;
        }
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.unauthenticated;
      _error = e.toString();
    }

    notifyListeners();
  }

  Future<void> _refreshUserProfile() async {
    try {
      final profileData = await _api.getProfile();
      _log('Profile data refreshed');
      _user = User.fromJson(profileData);
      _storage.saveUser(_user!);
      notifyListeners();
    } catch (e) {
      _log('Failed to refresh user profile: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _log('login() called with email: $email');
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      _log('Calling api.login()...');
      final response = await _api.login(email, password);
      _log('Login response received, user: ${response.user.email}');
      _user = response.user;
      _state = AuthState.authenticated;
      notifyListeners();

      _registerPushDevice();

      return true;
    } on ApiException catch (e) {
      _log('ApiException: ${e.message}, code: ${e.statusCode}');
      _error = e.message;
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      _log('General error: $e');
      _log('Stack trace: $stackTrace');
      _error = 'Не удалось подключиться к серверу: $e';
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String businessName) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.register(email, password, businessName);
      _user = response.user;
      _state = AuthState.authenticated;
      notifyListeners();

      _registerPushDevice();

      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Не удалось подключиться к серверу';
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.unregisterPushDevice();
      NotificationService.instance.clearUser();
      await _api.logout();
    } finally {
      _user = null;
      _state = AuthState.unauthenticated;
      notifyListeners();
    }
  }

  void updateUser(User user) {
    _user = user;
    _storage.saveUser(user);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _registerPushDevice() async {
    try {
      final playerId = await NotificationService.instance.getPlayerId();
      if (playerId != null && _user != null) {
        await _api.registerPushDevice(playerId);
        NotificationService.instance.setExternalUserId(_user!.id);
        NotificationService.instance.setTenantTag(_user!.tenantId);
        NotificationService.instance.setRoleTag('manager');
        _log('Push device registered successfully');
      }
    } catch (e) {
      _log('Failed to register push device: $e');
    }
  }
}
