import 'package:flutter/foundation.dart';
import '../services/base_api_service.dart';
import '../services/storage_service.dart';
import 'mixins/authentication_mixin.dart';
import 'mixins/pagination_mixin.dart';

/// Base class for user providers (Client, Employee) that handles common
/// session management patterns:
/// - Initialization with saved user loading
/// - Session expiration handling
/// - Logout with cleanup
///
/// Type parameters:
/// - [TUser] - The user model type (e.g., ClientUser, EmployeeUser)
/// - [TApi] - The API service type (e.g., ClientApiService, EmployeeApiService)
///
/// Subclasses must implement:
/// - [loadSavedUser] - Load user from storage
/// - [clearUserData] - Clear user data from storage
/// - [clearDomainData] - Clear domain-specific data (orders, assignments, etc.)
/// - [refreshData] - Refresh data after login/init
abstract class BaseUserProvider<TUser, TApi extends BaseApiService>
    extends ChangeNotifier with AuthenticationMixin, PaginationMixin {
  @protected
  final StorageService storage;

  @protected
  final TApi api;

  final String modeName;

  TUser? _user;

  TUser? get user => _user;
  bool get isAuthenticated => _user != null;

  BaseUserProvider({
    required this.storage,
    required this.api,
    required this.modeName,
  }) {
    BaseApiService.registerSessionExpiredCallback(modeName, _handleSessionExpired);
  }

  // ==================== Abstract Methods ====================

  /// Load saved user from storage.
  /// Returns null if no user is saved.
  Future<TUser?> loadSavedUser();

  /// Clear user data from storage (tokens, user info).
  Future<void> clearUserData();

  /// Clear domain-specific data (orders, tenants, assignments, etc.).
  /// Called during logout and session expiration.
  @protected
  void clearDomainData();

  /// Refresh all data after login or initialization.
  Future<void> refreshData();

  // ==================== Common Implementations ====================

  /// Initialize the provider by loading saved user and refreshing data.
  Future<void> init() async {
    final savedUser = await loadSavedUser();
    if (savedUser != null) {
      _user = savedUser;
      notifyListeners();
      await refreshData();
    }
  }

  /// Logout the user and clear all data.
  /// Subclasses should override this to call their specific API logout method.
  @mustCallSuper
  Future<void> logout() async {
    _user = null;
    clearDomainData();
    clearAllPagination();
    await clearUserData();
    notifyListeners();
  }

  /// Set the user (protected for subclass use during login).
  @protected
  void setUser(TUser? user) {
    _user = user;
  }

  /// Handle session expiration.
  void _handleSessionExpired() {
    _log('Session expired - logging out');
    _user = null;
    clearDomainData();
    clearAllPagination();
    clearUserData();
    notifyListeners();
  }

  void _log(String message) {
    debugPrint('[$modeName] $message');
  }
}
