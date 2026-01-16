import 'dart:convert';
import 'package:flutter/foundation.dart';

/// HTTP Logger for debugging API requests.
///
/// Provides structured logging of HTTP request/response cycles with timing,
/// body truncation, and header sanitization (hides auth tokens).
class HttpLogger {
  /// Enable/disable logging (defaults to debug mode only)
  static bool enabled = kDebugMode;

  /// Whether to log request/response headers
  static bool logHeaders = false;

  /// Whether to log request/response body
  static bool logBody = true;

  /// Maximum body length before truncation
  static int maxBodyLength = 1000;

  /// Log an outgoing HTTP request
  static void logRequest({
    required String method,
    required Uri url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    if (!enabled) return;

    final buffer = StringBuffer();
    buffer.writeln('┌─────────────────────────────────────────');
    buffer.writeln('│ → $method ${url.path}');
    if (url.queryParameters.isNotEmpty) {
      buffer.writeln('│   Query: ${url.queryParameters}');
    }
    if (logHeaders && headers != null) {
      buffer.writeln('│   Headers: ${_sanitizeHeaders(headers)}');
    }
    if (logBody && body != null) {
      buffer.writeln('│   Body: ${_truncate(_formatBody(body))}');
    }
    debugPrint(buffer.toString());
  }

  /// Log an incoming HTTP response
  static void logResponse({
    required String method,
    required Uri url,
    required int statusCode,
    required Duration duration,
    dynamic body,
  }) {
    if (!enabled) return;

    final buffer = StringBuffer();
    final statusEmoji = statusCode >= 200 && statusCode < 300 ? '✓' : '✗';
    buffer.writeln('│ ← $statusEmoji $statusCode (${duration.inMilliseconds}ms)');
    if (logBody && body != null) {
      buffer.writeln('│   Response: ${_truncate(_formatBody(body))}');
    }
    buffer.writeln('└─────────────────────────────────────────');
    debugPrint(buffer.toString());
  }

  /// Log an HTTP error
  static void logError({
    required String method,
    required Uri url,
    required Object error,
    Duration? duration,
  }) {
    if (!enabled) return;

    final buffer = StringBuffer();
    buffer.writeln('│ ✗ ERROR ${duration != null ? "(${duration.inMilliseconds}ms)" : ""}');
    buffer.writeln('│   $error');
    buffer.writeln('└─────────────────────────────────────────');
    debugPrint(buffer.toString());
  }

  /// Sanitize headers to hide sensitive data (Authorization tokens)
  static Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    return headers.map((key, value) {
      if (key.toLowerCase() == 'authorization') {
        return MapEntry(key, 'Bearer ***');
      }
      return MapEntry(key, value);
    });
  }

  /// Format body for logging (handles String, Map, List)
  static String _formatBody(dynamic body) {
    if (body == null) return 'null';
    if (body is String) {
      if (body.isEmpty) return '(empty)';
      try {
        final json = jsonDecode(body);
        return jsonEncode(json);
      } catch (_) {
        return body;
      }
    }
    if (body is Map || body is List) {
      return jsonEncode(body);
    }
    return body.toString();
  }

  /// Truncate text if it exceeds maxBodyLength
  static String _truncate(String text) {
    if (text.length <= maxBodyLength) return text;
    return '${text.substring(0, maxBodyLength)}... [truncated]';
  }
}
