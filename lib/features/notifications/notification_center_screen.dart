import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/riverpod/providers.dart';
import '../../core/riverpod/notifications_provider.dart';
import '../../core/models/in_app_notification.dart';
import '../../core/services/deep_link_service.dart';
import 'widgets/notification_card.dart';
import 'notification_settings_screen.dart';

/// Notification center screen showing all in-app notifications
class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsNotifierProvider.notifier).refreshNotifications();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(notificationsNotifierProvider);
      if (!state.isLoading && state.hasMore) {
        ref.read(notificationsNotifierProvider.notifier).loadNotifications();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () => _markAllAsRead(),
              child: const Text('Прочитать все'),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationSettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsNotifierProvider.notifier).refreshNotifications(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(NotificationsStateData state) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(notificationsNotifierProvider.notifier).refreshNotifications(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Нет уведомлений',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Уведомления появятся здесь',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.notifications.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final notification = state.notifications[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: NotificationCard(
            notification: notification,
            onTap: () => _onNotificationTap(notification),
          ),
        );
      },
    );
  }

  Future<void> _onNotificationTap(InAppNotification notification) async {
    // Mark as read if not already
    if (!notification.read) {
      await ref
          .read(notificationsNotifierProvider.notifier)
          .markAsRead(notification.id);
    }

    // Navigate based on notification type and data
    _handleDeepLink(notification);
  }

  void _handleDeepLink(InAppNotification notification) {
    // Use DeepLinkService for navigation based on notification type
    DeepLinkService.instance.handleNotification(notification);
  }

  Future<void> _markAllAsRead() async {
    try {
      await ref.read(notificationsNotifierProvider.notifier).markAllAsRead();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Все уведомления отмечены как прочитанные')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }
}
