import 'package:flutter/services.dart';

/// Haptic feedback utility for micro-interactions
class AppHaptics {
  /// Light tap feedback - use for small buttons, toggles
  static Future<void> lightTap() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium tap feedback - use for regular buttons, list selections
  static Future<void> mediumTap() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy tap feedback - use for important actions, confirmations
  static Future<void> heavyTap() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection changed feedback - use for pickers, sliders
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibration feedback - use for errors, warnings
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  /// Success feedback - light double tap feel
  static Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error feedback - heavy tap
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }

  /// Warning feedback - medium tap
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
  }

  /// Notification feedback - light tap
  static Future<void> notification() async {
    await HapticFeedback.lightImpact();
  }

  /// Pull to refresh feedback
  static Future<void> pullToRefresh() async {
    await HapticFeedback.mediumImpact();
  }

  /// Swipe action feedback
  static Future<void> swipeAction() async {
    await HapticFeedback.lightImpact();
  }

  /// Long press feedback
  static Future<void> longPress() async {
    await HapticFeedback.mediumImpact();
  }
}
