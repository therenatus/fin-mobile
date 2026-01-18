// Base auth state classes for auth providers.
//
// This file contains the shared enum and interface used by all auth providers
// (Manager, Client, Employee) to reduce code duplication.

/// Unified auth loading state enum for all auth providers.
enum AuthLoadingState {
  /// Initial state before checking stored credentials
  initial,

  /// Loading/checking authentication
  loading,

  /// User is authenticated
  authenticated,

  /// User is not authenticated
  unauthenticated,

  /// Error state (kept for compatibility)
  error,
}

/// Base interface for auth state data.
/// All auth state classes must implement this interface.
abstract class BaseAuthStateData<TUser> {
  /// Current loading/auth state
  AuthLoadingState get loadingState;

  /// Current user (null if not authenticated)
  TUser? get user;

  /// Error message (null if no error)
  String? get error;

  /// Whether user is authenticated
  bool get isAuthenticated => loadingState == AuthLoadingState.authenticated;

  /// Whether auth state is loading
  bool get isLoading => loadingState == AuthLoadingState.loading;
}
