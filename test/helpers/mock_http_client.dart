import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

/// Generate mocks for HTTP Client.
///
/// After modifying this file, run:
/// flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([http.Client])
// ignore: unused_import
import 'mock_http_client.mocks.dart';

/// Helper class for creating common HTTP responses in tests
class MockHttpResponses {
  /// Create a successful JSON response
  static http.Response success(String body, {int statusCode = 200}) {
    return http.Response(
      body,
      statusCode,
      headers: {'content-type': 'application/json'},
    );
  }

  /// Create an error response
  static http.Response error(String message, {int statusCode = 400}) {
    return http.Response(
      '{"error": {"message": "$message"}}',
      statusCode,
      headers: {'content-type': 'application/json'},
    );
  }

  /// Create an unauthorized response (401)
  static http.Response unauthorized({String message = 'Unauthorized'}) {
    return http.Response(
      '{"error": {"message": "$message"}}',
      401,
      headers: {'content-type': 'application/json'},
    );
  }

  /// Create a not found response (404)
  static http.Response notFound({String message = 'Not found'}) {
    return http.Response(
      '{"error": {"message": "$message"}}',
      404,
      headers: {'content-type': 'application/json'},
    );
  }

  /// Create a server error response (500)
  static http.Response serverError({String message = 'Internal server error'}) {
    return http.Response(
      '{"error": {"message": "$message"}}',
      500,
      headers: {'content-type': 'application/json'},
    );
  }

  /// Create a paginated list response
  static http.Response paginatedList(
    String key,
    List<Map<String, dynamic>> items, {
    int page = 1,
    int perPage = 20,
    int? total,
    int? totalPages,
  }) {
    final actualTotal = total ?? items.length;
    final actualTotalPages = totalPages ?? (actualTotal / perPage).ceil();
    return http.Response(
      '''
      {
        "success": true,
        "data": {
          "$key": ${_jsonEncode(items)},
          "meta": {
            "page": $page,
            "perPage": $perPage,
            "total": $actualTotal,
            "totalPages": $actualTotalPages
          }
        }
      }
      ''',
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  /// Create a single item response wrapped in data
  static http.Response singleItem(Map<String, dynamic> item) {
    return http.Response(
      '{"success": true, "data": ${_jsonEncode(item)}}',
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  static String _jsonEncode(dynamic data) {
    if (data is List) {
      final items = data.map((e) => _jsonEncode(e)).join(',');
      return '[$items]';
    }
    if (data is Map) {
      final entries = data.entries.map((e) {
        final value = e.value is String ? '"${e.value}"' : _jsonEncode(e.value);
        return '"${e.key}": $value';
      }).join(',');
      return '{$entries}';
    }
    if (data is String) return '"$data"';
    if (data == null) return 'null';
    return data.toString();
  }
}
