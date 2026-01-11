import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// OneSignal push notification service
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  bool _isInitialized = false;
  Function(String orderId)? onOrderTap;

  /// Initialize OneSignal with app ID
  Future<void> init(String appId) async {
    if (_isInitialized) return;

    try {
      // Initialize OneSignal
      OneSignal.initialize(appId);

      // Request notification permission
      await OneSignal.Notifications.requestPermission(true);

      // Set up notification click handler
      OneSignal.Notifications.addClickListener(_handleNotificationClick);

      // Set up foreground notification handler
      OneSignal.Notifications.addForegroundWillDisplayListener(_handleForegroundNotification);

      _isInitialized = true;
      debugPrint('NotificationService: OneSignal initialized');
    } catch (e) {
      debugPrint('NotificationService: Failed to initialize OneSignal: $e');
    }
  }

  /// Get the OneSignal player/subscription ID
  Future<String?> getPlayerId() async {
    try {
      final subscriptionId = OneSignal.User.pushSubscription.id;
      debugPrint('NotificationService: Player ID = $subscriptionId');
      return subscriptionId;
    } catch (e) {
      debugPrint('NotificationService: Failed to get player ID: $e');
      return null;
    }
  }

  /// Set tenant tag for filtering notifications
  void setTenantTag(String tenantId) {
    OneSignal.User.addTagWithKey('tenantId', tenantId);
    debugPrint('NotificationService: Set tenant tag = $tenantId');
  }

  /// Set user role tag
  void setRoleTag(String role) {
    OneSignal.User.addTagWithKey('role', role);
    debugPrint('NotificationService: Set role tag = $role');
  }

  /// Set user ID for OneSignal
  void setExternalUserId(String userId) {
    OneSignal.login(userId);
    debugPrint('NotificationService: Set external user ID = $userId');
  }

  /// Clear user data on logout
  void clearUser() {
    OneSignal.logout();
    debugPrint('NotificationService: Cleared user');
  }

  /// Handle notification clicks
  void _handleNotificationClick(OSNotificationClickEvent event) {
    debugPrint('NotificationService: Notification clicked');

    final data = event.notification.additionalData;
    if (data != null) {
      final type = data['type'] as String?;
      final orderId = data['orderId'] as String?;

      debugPrint('NotificationService: type=$type, orderId=$orderId');

      if (orderId != null && onOrderTap != null) {
        onOrderTap!(orderId);
      }
    }
  }

  /// Handle foreground notifications
  void _handleForegroundNotification(OSNotificationWillDisplayEvent event) {
    debugPrint('NotificationService: Foreground notification received');
    // Show the notification in foreground
    event.notification.display();
  }

  /// Check if push notifications are enabled
  Future<bool> isPushEnabled() async {
    return OneSignal.Notifications.permission;
  }

  /// Request push notification permission
  Future<bool> requestPermission() async {
    return await OneSignal.Notifications.requestPermission(true);
  }
}
