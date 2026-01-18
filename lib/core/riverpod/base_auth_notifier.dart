import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/base_api_service.dart';
import 'base_auth_state.dart';

/// Base auth notifier with generic types.
///
/// This abstract class provides common functionality for all auth notifiers
/// (Manager, Client, Employee) to reduce code duplication.
///
/// Type parameters:
/// - `TState`: The state class (must extend `BaseAuthStateData<TUser>`)
/// - `TUser`: The user model type
abstract class BaseAuthNotifier<TState extends BaseAuthStateData<TUser>, TUser>
    extends Notifier<TState> {
  /// Auth type identifier for session callback registration.
  /// Must return 'manager', 'client', or 'employee'.
  String get authType;

  /// Log tag for debug output
  String get logTag => '[${authType.substring(0, 1).toUpperCase()}${authType.substring(1)}AuthNotifier]';

  /// Initial state to return from build()
  TState get initialState;

  /// Create authenticated state with user
  TState createAuthenticatedState(TUser user);

  /// Create unauthenticated state with optional error
  TState createUnauthenticatedState({String? error});

  /// Create loading state
  TState createLoadingState();

  /// Load user from storage (if tokens exist)
  Future<TUser?> loadUserFromStorage();

  /// Clear all storage for this auth type
  Future<void> clearStorage();

  /// Hook called after successful login (for push notifications, Sentry, etc.)
  void onLoginSuccess(TUser user) {}

  /// Hook called before logout (for cleanup like push unregister)
  Future<void> onBeforeLogout() async {}

  /// Hook called after successful initialization with user
  Future<void> onInitWithUser(TUser user) async {}

  void _log(String message) {
    debugPrint('$logTag $message');
  }

  @override
  TState build() {
    // Register session expired callback
    BaseApiService.registerSessionExpiredCallback(authType, _handleSessionExpired);

    // Initialize auth state asynchronously
    _init();

    return initialState;
  }

  void _handleSessionExpired() {
    _log('Session expired - logging out');
    clearStorage();
    state = createUnauthenticatedState();
  }

  Future<void> _init() async {
    try {
      final user = await loadUserFromStorage();
      if (user != null) {
        state = createAuthenticatedState(user);
        await onInitWithUser(user);
        return;
      }
      state = createUnauthenticatedState();
    } catch (e) {
      _log('Init error: $e');
      state = createUnauthenticatedState(error: e.toString());
    }
  }

  /// Generic login wrapper.
  ///
  /// Handles the common login flow:
  /// 1. Set loading state
  /// 2. Call API
  /// 3. Handle success/error
  /// 4. Call onLoginSuccess hook
  ///
  /// [apiCall] - The API call that returns the user
  /// [getApiExceptionMessage] - Function to extract message from API exception
  Future<bool> performLogin<TApiException extends Exception>({
    required Future<TUser> Function() apiCall,
    required String Function(TApiException) getApiExceptionMessage,
  }) async {
    _log('performLogin() called');
    state = createLoadingState();

    try {
      final user = await apiCall();
      _log('Login successful');
      state = createAuthenticatedState(user);
      onLoginSuccess(user);
      return true;
    } on Exception catch (e) {
      // Check if this is the expected API exception type
      if (e is TApiException) {
        final message = getApiExceptionMessage(e);
        _log('ApiException: $message');
        state = createUnauthenticatedState(error: message);
      } else {
        _log('General error: $e');
        state = createUnauthenticatedState(
          error: 'Не удалось подключиться к серверу: $e',
        );
      }
      return false;
    }
  }

  /// Perform logout with cleanup
  Future<void> performLogout({
    required Future<void> Function() apiLogout,
  }) async {
    try {
      await onBeforeLogout();
      await apiLogout();
    } catch (e) {
      _log('Logout API error (continuing): $e');
    } finally {
      await clearStorage();
      state = createUnauthenticatedState();
    }
  }

  /// Clear error from state
  void clearError() {
    if (state.error != null) {
      state = createUnauthenticatedState();
    }
  }
}
