import 'package:flutter/material.dart';
import '../../../core/models/in_app_notification.dart';

/// Card widget for displaying a notification
class NotificationCard extends StatelessWidget {
  final InAppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: notification.read
          ? null
          : theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getIconColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(notification.type),
                  color: _getIconColor(notification.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: notification.read
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notification.timeAgo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          notification.type.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getIconColor(notification.type),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.qcCompleted:
        return Icons.check_circle;
      case NotificationType.defectCreated:
      case NotificationType.defectAssigned:
        return Icons.bug_report;
      case NotificationType.taskAssigned:
      case NotificationType.taskCompleted:
        return Icons.assignment;
      case NotificationType.orderDeadline:
      case NotificationType.overdueOrders:
        return Icons.schedule;
      case NotificationType.trialEnding:
      case NotificationType.subscriptionExpiring:
        return Icons.payment;
      case NotificationType.other:
        return Icons.notifications;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.qcCompleted:
        return Colors.green;
      case NotificationType.defectCreated:
      case NotificationType.defectAssigned:
        return Colors.red;
      case NotificationType.taskAssigned:
        return Colors.blue;
      case NotificationType.taskCompleted:
        return Colors.green;
      case NotificationType.orderDeadline:
      case NotificationType.overdueOrders:
        return Colors.orange;
      case NotificationType.trialEnding:
      case NotificationType.subscriptionExpiring:
        return Colors.purple;
      case NotificationType.other:
        return Colors.grey;
    }
  }
}
