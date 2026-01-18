import 'package:flutter/material.dart';
import '../models/in_app_notification.dart';

// Import screens for navigation
import '../../features/qc/qc_screen.dart';
import '../../features/production/production_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/subscription/subscription_screen.dart';

/// Service for handling deep link navigation from notifications
class DeepLinkService {
  static final DeepLinkService instance = DeepLinkService._();
  DeepLinkService._();

  /// Global navigator key for navigation without context
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Get the current navigator state
  NavigatorState? get _navigator => navigatorKey.currentState;

  /// Navigate based on notification type and data
  void handleNotification(InAppNotification notification) {
    _navigateByType(notification.type, notification.data);
  }

  /// Navigate based on push notification data
  void handlePushNotification(Map<String, dynamic> data) {
    final typeString = data['type'] as String?;
    if (typeString == null) return;

    final type = NotificationType.fromString(typeString);
    _navigateByType(type, data);
  }

  /// Navigate to appropriate screen based on notification type
  void _navigateByType(NotificationType type, Map<String, dynamic>? data) {
    if (_navigator == null) {
      debugPrint('DeepLinkService: Navigator not available');
      return;
    }

    switch (type) {
      case NotificationType.qcCompleted:
        _navigateToQcScreen(tabIndex: 0, checkId: data?['checkId']);
        break;

      case NotificationType.defectCreated:
      case NotificationType.defectAssigned:
        _navigateToQcScreen(tabIndex: 2, defectId: data?['defectId']);
        break;

      case NotificationType.taskAssigned:
      case NotificationType.taskCompleted:
        _navigateToProductionScreen(taskId: data?['taskId']);
        break;

      case NotificationType.orderDeadline:
      case NotificationType.overdueOrders:
        // Navigate to orders screen - order details can be accessed from there
        // TODO: In the future, could add orderId highlight/search functionality
        _navigateToOrdersScreen();
        break;

      case NotificationType.trialEnding:
      case NotificationType.subscriptionExpiring:
        _navigateToSubscriptionScreen();
        break;

      case NotificationType.other:
        // No specific navigation for generic notifications
        debugPrint('DeepLinkService: No navigation for type "other"');
        break;
    }
  }

  /// Navigate to QC screen with specific tab
  void _navigateToQcScreen({int tabIndex = 0, String? checkId, String? defectId}) {
    _navigator!.push(
      MaterialPageRoute(
        builder: (_) => QcScreen(
          initialTabIndex: tabIndex,
          highlightCheckId: checkId,
          highlightDefectId: defectId,
        ),
      ),
    );
    debugPrint('DeepLinkService: Navigated to QcScreen (tab: $tabIndex)');
  }

  /// Navigate to Production screen
  void _navigateToProductionScreen({String? taskId}) {
    _navigator!.push(
      MaterialPageRoute(
        builder: (_) => ProductionScreen(highlightTaskId: taskId),
      ),
    );
    debugPrint('DeepLinkService: Navigated to ProductionScreen');
  }

  /// Navigate to Orders list screen
  void _navigateToOrdersScreen() {
    _navigator!.push(
      MaterialPageRoute(
        builder: (_) => const OrdersScreen(),
      ),
    );
    debugPrint('DeepLinkService: Navigated to OrdersScreen');
  }

  /// Navigate to Subscription screen
  void _navigateToSubscriptionScreen() {
    _navigator!.push(
      MaterialPageRoute(
        builder: (_) => const SubscriptionScreen(),
      ),
    );
    debugPrint('DeepLinkService: Navigated to SubscriptionScreen');
  }
}
