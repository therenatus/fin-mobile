import 'package:json_annotation/json_annotation.dart';

part 'in_app_notification.g.dart';

// ==================== NOTIFICATION TYPE ENUM ====================

enum NotificationType {
  qcCompleted('qc_completed', 'QC проверка'),
  defectCreated('defect_created', 'Новый дефект'),
  defectAssigned('defect_assigned', 'Назначен дефект'),
  taskAssigned('task_assigned', 'Назначена задача'),
  taskCompleted('task_completed', 'Задача выполнена'),
  orderDeadline('order_deadline', 'Дедлайн заказа'),
  overdueOrders('overdue_orders', 'Просроченные заказы'),
  trialEnding('trial_ending', 'Пробный период'),
  subscriptionExpiring('subscription_expiring', 'Истекает подписка'),
  other('other', 'Уведомление');

  final String value;
  final String label;
  const NotificationType(this.value, this.label);

  static NotificationType fromString(String type) {
    return NotificationType.values.firstWhere(
      (e) => e.value == type,
      orElse: () => NotificationType.other,
    );
  }
}

class NotificationTypeConverter
    implements JsonConverter<NotificationType, String> {
  const NotificationTypeConverter();

  @override
  NotificationType fromJson(String json) => NotificationType.fromString(json);

  @override
  String toJson(NotificationType type) => type.value;
}

// ==================== IN-APP NOTIFICATION ====================

@JsonSerializable()
class InAppNotification {
  final String id;
  final String tenantId;
  final String? userId;
  final String? employeeId;
  final String? clientUserId;
  @NotificationTypeConverter()
  final NotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime createdAt;

  InAppNotification({
    required this.id,
    required this.tenantId,
    this.userId,
    this.employeeId,
    this.clientUserId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.read,
    required this.createdAt,
  });

  factory InAppNotification.fromJson(Map<String, dynamic> json) =>
      _$InAppNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$InAppNotificationToJson(this);

  /// Get the icon name based on notification type
  String get iconName {
    switch (type) {
      case NotificationType.qcCompleted:
        return 'check_circle';
      case NotificationType.defectCreated:
      case NotificationType.defectAssigned:
        return 'bug_report';
      case NotificationType.taskAssigned:
      case NotificationType.taskCompleted:
        return 'assignment';
      case NotificationType.orderDeadline:
      case NotificationType.overdueOrders:
        return 'schedule';
      case NotificationType.trialEnding:
      case NotificationType.subscriptionExpiring:
        return 'payment';
      case NotificationType.other:
        return 'notifications';
    }
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин. назад';
    if (diff.inHours < 24) return '${diff.inHours} ч. назад';
    if (diff.inDays < 7) return '${diff.inDays} дн. назад';
    return '${createdAt.day}.${createdAt.month}.${createdAt.year}';
  }

  /// Create a copy with updated read status
  InAppNotification copyWith({bool? read}) {
    return InAppNotification(
      id: id,
      tenantId: tenantId,
      userId: userId,
      employeeId: employeeId,
      clientUserId: clientUserId,
      type: type,
      title: title,
      message: message,
      data: data,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }
}

// ==================== NOTIFICATION HISTORY RESPONSE ====================

@JsonSerializable()
class NotificationHistoryResponse {
  final List<InAppNotification> data;
  final NotificationMeta meta;
  final int unreadCount;

  NotificationHistoryResponse({
    required this.data,
    required this.meta,
    required this.unreadCount,
  });

  factory NotificationHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationHistoryResponseToJson(this);
}

@JsonSerializable()
class NotificationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  NotificationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory NotificationMeta.fromJson(Map<String, dynamic> json) =>
      _$NotificationMetaFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationMetaToJson(this);

  bool get hasNextPage => page < totalPages;
}

// ==================== NOTIFICATION PREFERENCES ====================

@JsonSerializable()
class NotificationPreferences {
  final bool pushEnabled;

  NotificationPreferences({required this.pushEnabled});

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPreferencesToJson(this);
}

// ==================== UNREAD COUNT RESPONSE ====================

@JsonSerializable()
class UnreadCountResponse {
  final int unreadCount;

  UnreadCountResponse({required this.unreadCount});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadCountResponseToJson(this);
}
