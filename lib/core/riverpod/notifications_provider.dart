import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/in_app_notification.dart';
import '../services/api_service.dart';
import 'api_provider.dart';

void _log(String message) {
  debugPrint('[NotificationsNotifier] $message');
}

/// State enum for Notifications operations
enum NotificationsLoadingState {
  initial,
  loading,
  loaded,
  error,
}

/// Notifications state data
class NotificationsStateData {
  final NotificationsLoadingState loadingState;
  final List<InAppNotification> notifications;
  final int unreadCount;
  final NotificationPreferences? preferences;
  final String? error;

  // Pagination
  final int page;
  final int totalPages;
  final bool hasMore;

  const NotificationsStateData({
    this.loadingState = NotificationsLoadingState.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.preferences,
    this.error,
    this.page = 1,
    this.totalPages = 1,
    this.hasMore = true,
  });

  bool get isLoading => loadingState == NotificationsLoadingState.loading;

  NotificationsStateData copyWith({
    NotificationsLoadingState? loadingState,
    List<InAppNotification>? notifications,
    int? unreadCount,
    NotificationPreferences? preferences,
    String? error,
    int? page,
    int? totalPages,
    bool? hasMore,
    bool clearError = false,
    bool clearPreferences = false,
  }) {
    return NotificationsStateData(
      loadingState: loadingState ?? this.loadingState,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      preferences: clearPreferences ? null : (preferences ?? this.preferences),
      error: clearError ? null : (error ?? this.error),
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Notifications Notifier for managing in-app notifications
class NotificationsNotifier extends Notifier<NotificationsStateData> {
  @override
  NotificationsStateData build() {
    return const NotificationsStateData();
  }

  ApiService get _api => ref.read(apiServiceProvider);

  // ==================== NOTIFICATIONS ====================

  /// Load notifications
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        page: 1,
        notifications: [],
        hasMore: true,
      );
    }

    if (!state.hasMore && !refresh) return;

    state = state.copyWith(
      loadingState: NotificationsLoadingState.loading,
      clearError: true,
    );

    try {
      final response = await _api.getNotificationHistory(
        page: refresh ? 1 : state.page,
        limit: 20,
      );

      final newNotifications = refresh
          ? response.data
          : [...state.notifications, ...response.data];

      state = state.copyWith(
        notifications: newNotifications,
        unreadCount: response.unreadCount,
        totalPages: response.meta.totalPages,
        hasMore: (refresh ? 1 : state.page) < response.meta.totalPages,
        page: (refresh ? 1 : state.page) + 1,
        loadingState: NotificationsLoadingState.loaded,
      );
    } catch (e) {
      _log('loadNotifications error: $e');
      state = state.copyWith(
        error: e.toString(),
        loadingState: NotificationsLoadingState.error,
      );
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await loadNotifications(refresh: true);
  }

  /// Refresh unread count only
  Future<void> refreshUnreadCount() async {
    try {
      final count = await _api.getUnreadNotificationCount();
      state = state.copyWith(unreadCount: count);
    } catch (e) {
      _log('refreshUnreadCount error: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _api.markNotificationAsRead(notificationId);

      // Update local state
      final notifications = List<InAppNotification>.from(state.notifications);
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !notifications[index].read) {
        notifications[index] = notifications[index].copyWith(read: true);
        state = state.copyWith(
          notifications: notifications,
          unreadCount: (state.unreadCount - 1).clamp(0, state.unreadCount),
        );
      }
    } catch (e) {
      _log('markAsRead error: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _api.markAllNotificationsAsRead();

      // Update local state
      final notifications = state.notifications
          .map((n) => n.read ? n : n.copyWith(read: true))
          .toList();
      state = state.copyWith(
        notifications: notifications,
        unreadCount: 0,
      );
    } catch (e) {
      _log('markAllAsRead error: $e');
      rethrow;
    }
  }

  // ==================== PREFERENCES ====================

  /// Load notification preferences
  Future<void> loadPreferences() async {
    try {
      final prefs = await _api.getNotificationPreferences();
      state = state.copyWith(preferences: prefs);
    } catch (e) {
      _log('loadPreferences error: $e');
    }
  }

  /// Update push enabled preference
  Future<void> updatePushEnabled(bool enabled) async {
    try {
      await _api.updateNotificationPreferences(pushEnabled: enabled);
      state = state.copyWith(
        preferences: NotificationPreferences(pushEnabled: enabled),
      );
    } catch (e) {
      _log('updatePushEnabled error: $e');
      rethrow;
    }
  }

  // ==================== HELPERS ====================

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset state
  void reset() {
    state = const NotificationsStateData();
  }
}

/// Provider for Notifications state
final notificationsNotifierProvider =
    NotifierProvider<NotificationsNotifier, NotificationsStateData>(
  NotificationsNotifier.new,
);

// ============ Convenience Providers ============

/// Provider for notifications list
final notificationsListProvider = Provider<List<InAppNotification>>((ref) {
  return ref.watch(notificationsNotifierProvider).notifications;
});

/// Provider for notifications loading state
final notificationsLoadingStateProvider =
    Provider<NotificationsLoadingState>((ref) {
  return ref.watch(notificationsNotifierProvider).loadingState;
});

/// Provider for unread notification count
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsNotifierProvider).unreadCount;
});

/// Provider for notification preferences
final notificationPreferencesProvider =
    Provider<NotificationPreferences?>((ref) {
  return ref.watch(notificationsNotifierProvider).preferences;
});

/// Provider for notifications error
final notificationsErrorProvider = Provider<String?>((ref) {
  return ref.watch(notificationsNotifierProvider).error;
});

/// Provider for is notifications loading
final isNotificationsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(notificationsNotifierProvider).isLoading;
});

/// Provider for has more notifications
final hasMoreNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(notificationsNotifierProvider).hasMore;
});
