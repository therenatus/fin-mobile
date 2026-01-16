import 'package:flutter/foundation.dart';
import '../../services/base_api_service.dart';

/// Mixin for common authentication patterns in providers.
///
/// Provides standardized error handling, loading state management,
/// and authenticated action execution.
mixin AuthenticationMixin on ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Perform an authenticated action with standardized error handling.
  ///
  /// Sets loading state, clears previous error, handles exceptions,
  /// and notifies listeners appropriately.
  ///
  /// Returns the result of [onSuccess] or false on failure.
  Future<bool> performAuthenticatedAction<T>({
    required Future<T> Function() action,
    required Future<void> Function(T result) onSuccess,
    String defaultError = 'Не удалось подключиться к серверу',
    void Function(String log)? log,
    String? actionName,
  }) async {
    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      if (log != null && actionName != null) {
        log('Attempting $actionName...');
      }

      final result = await action();

      if (log != null && actionName != null) {
        log('$actionName successful');
      }

      await onSuccess(result);
      return true;
    } on BaseApiException catch (e) {
      if (log != null) {
        log('API error: ${e.message}, code: ${e.statusCode}');
      }
      _error = e.message;
      return false;
    } catch (e) {
      if (log != null) {
        log('Unexpected error: $e');
      }
      _error = defaultError;
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Clear the current error message.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Set loading state (internal use).
  void _setLoading(bool value) {
    _isLoading = value;
  }

  /// Set loading state (protected for subclass use).
  @protected
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message (protected for subclass use).
  @protected
  void setError(String? value) {
    _error = value;
    notifyListeners();
  }
}
