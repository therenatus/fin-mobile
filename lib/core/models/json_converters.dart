import 'package:json_annotation/json_annotation.dart';
import 'order.dart';
import 'transaction.dart';

/// Converter for OrderStatus enum
class OrderStatusConverter implements JsonConverter<OrderStatus, String> {
  const OrderStatusConverter();

  @override
  OrderStatus fromJson(String json) => OrderStatus.fromString(json);

  @override
  String toJson(OrderStatus status) => status.value;
}

/// Converter for TransactionType enum
class TransactionTypeConverter implements JsonConverter<TransactionType, String> {
  const TransactionTypeConverter();

  @override
  TransactionType fromJson(String json) => TransactionType.fromString(json);

  @override
  String toJson(TransactionType type) => type.value;
}

/// Helper for reading id field that may come as 'id' or '_id' from MongoDB
String? readId(Map<dynamic, dynamic> json, String key) {
  return json['id'] as String? ?? json['_id'] as String?;
}

/// Converter for nullable DateTime from ISO8601 string
class NullableDateTimeConverter implements JsonConverter<DateTime?, String?> {
  const NullableDateTimeConverter();

  @override
  DateTime? fromJson(String? json) => json != null ? DateTime.parse(json) : null;

  @override
  String? toJson(DateTime? date) => date?.toIso8601String();
}

/// Converter for required DateTime from ISO8601 string
class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime date) => date.toIso8601String();
}

// ============ Helper Functions for @JsonKey(fromJson:, toJson:) ============

/// Parse DateTime from ISO8601 string
DateTime dateTimeFromJson(String json) => DateTime.parse(json);

/// Convert DateTime to ISO8601 string
String dateTimeToJson(DateTime date) => date.toIso8601String();

/// Parse nullable DateTime from ISO8601 string
DateTime? nullableDateTimeFromJson(String? json) =>
    json != null ? DateTime.parse(json) : null;

/// Convert nullable DateTime to ISO8601 string
String? nullableDateTimeToJson(DateTime? date) => date?.toIso8601String();
