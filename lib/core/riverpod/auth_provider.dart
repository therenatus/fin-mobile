import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/base_api_service.dart';
import '../services/notification_service.dart';
import 'storage_provider.dart';
import 'api_provider.dart';

void _log(String message) {
  debugPrint('[AuthNotifier] $message');
}

/// Auth state enum
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Auth state class with user data
class AuthStateData {
  final AuthState state;
  final User? user;
  final String? error;

  const AuthStateData({
    this.state = AuthState.initial,
    this.user,
    this.error,
  });

  bool get isAuthenticated => state == AuthState.authenticated;
  bool get isLoading => state == AuthState.loading;

  AuthStateData copyWith({
    AuthState? state,
    User? user,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthStateData(
      state: state ?? this.state,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Auth notifier for managing authentication state.
class AuthNotifier extends Notifier<AuthStateData> {
  @override
  AuthStateData build() {
    // Register session expired callback
    BaseApiService.registerSessionExpiredCallback('manager', _handleSessionExpired);

    // Initialize auth state asynchronously
    _init();

    return const AuthStateData(state: AuthState.loading);
  }

  ApiService get _api => ref.read(apiServiceProvider);

  void _handleSessionExpired() {
    _log('Session expired - logging out');
    final storage = ref.read(storageServiceProvider);
    storage.clearTokens();
    storage.clearUser();
    state = const AuthStateData(state: AuthState.unauthenticated);
  }

  Future<void> _init() async {
    final storage = ref.read(storageServiceProvider);

    try {
      final hasTokens = await storage.hasTokens();
      if (hasTokens) {
        final user = await storage.getUser();
        if (user != null) {
          state = AuthStateData(state: AuthState.authenticated, user: user);
          return;
        }
      }
      state = const AuthStateData(state: AuthState.unauthenticated);
    } catch (e) {
      state = AuthStateData(
        state: AuthState.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<bool> login(String email, String password) async {
    _log('login() called with email: $email');
    state = state.copyWith(state: AuthState.loading, clearError: true);

    try {
      _log('Calling api.login()...');
      final response = await _api.login(email, password);
      _log('Login response received, user: ${response.user.email}');

      state = AuthStateData(
        state: AuthState.authenticated,
        user: response.user,
      );

      // Set Sentry user context for error tracking
      Sentry.configureScope((scope) {
        scope.setUser(SentryUser(id: response.user.id, email: response.user.email));
        scope.setTag('tenant_id', response.user.tenantId);
      });

      _registerPushDevice();
      return true;
    } on ApiException catch (e) {
      _log('ApiException: ${e.message}, code: ${e.statusCode}');
      state = AuthStateData(
        state: AuthState.unauthenticated,
        error: e.message,
      );
      return false;
    } catch (e, stackTrace) {
      _log('General error: $e');
      _log('Stack trace: $stackTrace');
      state = AuthStateData(
        state: AuthState.unauthenticated,
        error: 'Не удалось подключиться к серверу: $e',
      );
      return false;
    }
  }

  Future<bool> register(String email, String password, String businessName) async {
    state = state.copyWith(state: AuthState.loading, clearError: true);

    try {
      final response = await _api.register(email, password, businessName);

      state = AuthStateData(
        state: AuthState.authenticated,
        user: response.user,
      );

      _registerPushDevice();
      return true;
    } on ApiException catch (e) {
      state = AuthStateData(
        state: AuthState.unauthenticated,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = AuthStateData(
        state: AuthState.unauthenticated,
        error: 'Не удалось подключиться к серверу',
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.unregisterPushDevice();
      NotificationService.instance.clearUser();
      await _api.logout();
    } finally {
      // Clear Sentry user context
      Sentry.configureScope((scope) {
        scope.setUser(null);
        scope.removeTag('tenant_id');
      });

      state = const AuthStateData(state: AuthState.unauthenticated);
    }
  }

  void updateUser(User user) {
    final storage = ref.read(storageServiceProvider);
    storage.saveUser(user);
    state = state.copyWith(user: user);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> _registerPushDevice() async {
    try {
      final playerId = await NotificationService.instance.getPlayerId();
      final user = state.user;
      if (playerId != null && user != null) {
        await _api.registerPushDevice(playerId);
        NotificationService.instance.setExternalUserId(user.id);
        NotificationService.instance.setTenantTag(user.tenantId);
        NotificationService.instance.setRoleTag('manager');
        _log('Push device registered successfully');
      }
    } catch (e) {
      _log('Failed to register push device: $e');
    }
  }
}

/// Provider for auth state.
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthStateData>(
  AuthNotifier.new,
);

/// Convenience provider for checking if user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

/// Convenience provider for current user.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authNotifierProvider).user;
});
