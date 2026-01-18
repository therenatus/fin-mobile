import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'base_auth_state.dart';
import 'base_auth_notifier.dart';
import 'storage_provider.dart';
import 'api_provider.dart';

void _log(String message) {
  debugPrint('[AuthNotifier] $message');
}

/// Auth state enum - maps to shared AuthLoadingState for compatibility
@Deprecated('Use AuthLoadingState instead')
typedef AuthState = AuthLoadingState;

/// Auth state class with user data
class AuthStateData implements BaseAuthStateData<User> {
  @override
  final AuthLoadingState loadingState;
  @override
  final User? user;
  @override
  final String? error;

  const AuthStateData({
    this.loadingState = AuthLoadingState.initial,
    this.user,
    this.error,
  });

  /// Legacy getter for backwards compatibility
  AuthLoadingState get state => loadingState;

  @override
  bool get isAuthenticated => loadingState == AuthLoadingState.authenticated;

  @override
  bool get isLoading => loadingState == AuthLoadingState.loading;

  AuthStateData copyWith({
    AuthLoadingState? loadingState,
    AuthLoadingState? state, // Legacy parameter name
    User? user,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthStateData(
      loadingState: loadingState ?? state ?? this.loadingState,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Auth notifier for managing authentication state.
class AuthNotifier extends BaseAuthNotifier<AuthStateData, User> {
  @override
  String get authType => 'manager';

  @override
  AuthStateData get initialState =>
      const AuthStateData(loadingState: AuthLoadingState.loading);

  @override
  AuthStateData createAuthenticatedState(User user) =>
      AuthStateData(loadingState: AuthLoadingState.authenticated, user: user);

  @override
  AuthStateData createUnauthenticatedState({String? error}) =>
      AuthStateData(loadingState: AuthLoadingState.unauthenticated, error: error);

  @override
  AuthStateData createLoadingState() =>
      state.copyWith(loadingState: AuthLoadingState.loading, clearError: true);

  ApiService get _api => ref.read(apiServiceProvider);

  @override
  Future<User?> loadUserFromStorage() async {
    final storage = ref.read(storageServiceProvider);
    final hasTokens = await storage.hasTokens();
    if (hasTokens) {
      return storage.getUser();
    }
    return null;
  }

  @override
  Future<void> clearStorage() async {
    final storage = ref.read(storageServiceProvider);
    await storage.clearTokens();
    await storage.clearUser();
  }

  @override
  void onLoginSuccess(User user) {
    // Set Sentry user context for error tracking
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: user.id, email: user.email));
      scope.setTag('tenant_id', user.tenantId);
    });

    _registerPushDevice();
  }

  @override
  Future<void> onBeforeLogout() async {
    try {
      await _api.unregisterPushDevice();
      NotificationService.instance.clearUser();
    } catch (e) {
      _log('Error during logout cleanup: $e');
    }

    // Clear Sentry user context
    Sentry.configureScope((scope) {
      scope.setUser(null);
      scope.removeTag('tenant_id');
    });
  }

  Future<bool> login(String email, String password) async {
    _log('login() called with email: $email');

    return performLogin<ApiException>(
      apiCall: () async {
        _log('Calling api.login()...');
        final response = await _api.login(email, password);
        _log('Login response received, user: ${response.user.email}');
        return response.user;
      },
      getApiExceptionMessage: (e) {
        _log('ApiException: ${e.message}, code: ${e.statusCode}');
        return e.message;
      },
    );
  }

  Future<bool> register(String email, String password, String businessName) async {
    state = createLoadingState();

    try {
      final response = await _api.register(email, password, businessName);

      state = createAuthenticatedState(response.user);
      onLoginSuccess(response.user);
      return true;
    } on ApiException catch (e) {
      state = createUnauthenticatedState(error: e.message);
      return false;
    } catch (e) {
      state = createUnauthenticatedState(
        error: 'Не удалось подключиться к серверу',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await performLogout(apiLogout: () => _api.logout());
  }

  void updateUser(User user) {
    final storage = ref.read(storageServiceProvider);
    storage.saveUser(user);
    state = state.copyWith(user: user);
  }

  @override
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
