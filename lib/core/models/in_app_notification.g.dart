// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InAppNotification _$InAppNotificationFromJson(Map<String, dynamic> json) =>
    InAppNotification(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      userId: json['userId'] as String?,
      employeeId: json['employeeId'] as String?,
      clientUserId: json['clientUserId'] as String?,
      type: const NotificationTypeConverter().fromJson(json['type'] as String),
      title: json['title'] as String,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
      read: json['read'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$InAppNotificationToJson(InAppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      if (instance.userId case final value?) 'userId': value,
      if (instance.employeeId case final value?) 'employeeId': value,
      if (instance.clientUserId case final value?) 'clientUserId': value,
      'type': const NotificationTypeConverter().toJson(instance.type),
      'title': instance.title,
      'message': instance.message,
      if (instance.data case final value?) 'data': value,
      'read': instance.read,
      'createdAt': instance.createdAt.toIso8601String(),
    };

NotificationHistoryResponse _$NotificationHistoryResponseFromJson(
  Map<String, dynamic> json,
) => NotificationHistoryResponse(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => InAppNotification.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  meta: NotificationMeta.fromJson(json['meta'] as Map<String, dynamic>),
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$NotificationHistoryResponseToJson(
  NotificationHistoryResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
  'unreadCount': instance.unreadCount,
};

NotificationMeta _$NotificationMetaFromJson(Map<String, dynamic> json) =>
    NotificationMeta(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$NotificationMetaToJson(NotificationMeta instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
      'totalPages': instance.totalPages,
    };

NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => NotificationPreferences(pushEnabled: json['pushEnabled'] as bool);

Map<String, dynamic> _$NotificationPreferencesToJson(
  NotificationPreferences instance,
) => <String, dynamic>{'pushEnabled': instance.pushEnabled};

UnreadCountResponse _$UnreadCountResponseFromJson(Map<String, dynamic> json) =>
    UnreadCountResponse(
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UnreadCountResponseToJson(
  UnreadCountResponse instance,
) => <String, dynamic>{'unreadCount': instance.unreadCount};
