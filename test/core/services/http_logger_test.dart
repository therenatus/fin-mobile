import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/services/http_logger.dart';

void main() {
  setUp(() {
    // Reset HttpLogger settings before each test
    HttpLogger.enabled = true;
    HttpLogger.logHeaders = false;
    HttpLogger.logBody = true;
    HttpLogger.maxBodyLength = 1000;
  });

  group('HttpLogger', () {
    test('default settings are correct', () {
      // Note: enabled defaults to kDebugMode, but in test mode it's true
      expect(HttpLogger.logHeaders, isFalse);
      expect(HttpLogger.logBody, isTrue);
      expect(HttpLogger.maxBodyLength, equals(1000));
    });

    test('can change enabled setting', () {
      HttpLogger.enabled = false;
      expect(HttpLogger.enabled, isFalse);

      HttpLogger.enabled = true;
      expect(HttpLogger.enabled, isTrue);
    });

    test('can change logHeaders setting', () {
      HttpLogger.logHeaders = true;
      expect(HttpLogger.logHeaders, isTrue);

      HttpLogger.logHeaders = false;
      expect(HttpLogger.logHeaders, isFalse);
    });

    test('can change logBody setting', () {
      HttpLogger.logBody = false;
      expect(HttpLogger.logBody, isFalse);

      HttpLogger.logBody = true;
      expect(HttpLogger.logBody, isTrue);
    });

    test('can change maxBodyLength setting', () {
      HttpLogger.maxBodyLength = 500;
      expect(HttpLogger.maxBodyLength, equals(500));

      HttpLogger.maxBodyLength = 2000;
      expect(HttpLogger.maxBodyLength, equals(2000));
    });

    group('logRequest', () {
      test('does not throw when enabled', () {
        expect(
          () => HttpLogger.logRequest(
            method: 'GET',
            url: Uri.parse('https://example.com/api/test'),
          ),
          returnsNormally,
        );
      });

      test('does not throw when disabled', () {
        HttpLogger.enabled = false;

        expect(
          () => HttpLogger.logRequest(
            method: 'GET',
            url: Uri.parse('https://example.com/api/test'),
          ),
          returnsNormally,
        );
      });

      test('handles URL with query parameters', () {
        expect(
          () => HttpLogger.logRequest(
            method: 'GET',
            url: Uri.parse('https://example.com/api/test?page=1&limit=10'),
          ),
          returnsNormally,
        );
      });

      test('handles headers when logHeaders is true', () {
        HttpLogger.logHeaders = true;

        expect(
          () => HttpLogger.logRequest(
            method: 'POST',
            url: Uri.parse('https://example.com/api/test'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer token123',
            },
          ),
          returnsNormally,
        );
      });

      test('handles body when logBody is true', () {
        expect(
          () => HttpLogger.logRequest(
            method: 'POST',
            url: Uri.parse('https://example.com/api/test'),
            body: '{"name": "test"}',
          ),
          returnsNormally,
        );
      });

      test('handles Map body', () {
        expect(
          () => HttpLogger.logRequest(
            method: 'POST',
            url: Uri.parse('https://example.com/api/test'),
            body: {'name': 'test', 'value': 123},
          ),
          returnsNormally,
        );
      });

      test('handles List body', () {
        expect(
          () => HttpLogger.logRequest(
            method: 'POST',
            url: Uri.parse('https://example.com/api/test'),
            body: [1, 2, 3],
          ),
          returnsNormally,
        );
      });
    });

    group('logResponse', () {
      test('does not throw for successful response', () {
        expect(
          () => HttpLogger.logResponse(
            method: 'GET',
            url: Uri.parse('https://example.com/api/test'),
            statusCode: 200,
            duration: const Duration(milliseconds: 150),
            body: '{"success": true}',
          ),
          returnsNormally,
        );
      });

      test('does not throw for error response', () {
        expect(
          () => HttpLogger.logResponse(
            method: 'POST',
            url: Uri.parse('https://example.com/api/test'),
            statusCode: 400,
            duration: const Duration(milliseconds: 50),
            body: '{"error": "Bad request"}',
          ),
          returnsNormally,
        );
      });

      test('does not throw when disabled', () {
        HttpLogger.enabled = false;

        expect(
          () => HttpLogger.logResponse(
            method: 'GET',
            url: Uri.parse('https://example.com/api/test'),
            statusCode: 200,
            duration: const Duration(milliseconds: 100),
          ),
          returnsNormally,
        );
      });

      test('handles null body', () {
        expect(
          () => HttpLogger.logResponse(
            method: 'DELETE',
            url: Uri.parse('https://example.com/api/test'),
            statusCode: 204,
            duration: const Duration(milliseconds: 100),
            body: null,
          ),
          returnsNormally,
        );
      });
    });

    group('logError', () {
      test('does not throw for exception', () {
        expect(
          () => HttpLogger.logError(
            method: 'GET',
            url: Uri.parse('https://example.com/api/test'),
            error: Exception('Network error'),
          ),
          returnsNormally,
        );
      });

      test('does not throw with duration', () {
        expect(
          () => HttpLogger.logError(
            method: 'POST',
            url: Uri.parse('https://example.com/api/test'),
            error: Exception('Timeout'),
            duration: const Duration(seconds: 30),
          ),
          returnsNormally,
        );
      });

      test('does not throw when disabled', () {
        HttpLogger.enabled = false;

        expect(
          () => HttpLogger.logError(
            method: 'GET',
            url: Uri.parse('https://example.com/api/test'),
            error: Exception('Error'),
          ),
          returnsNormally,
        );
      });

      test('handles string error', () {
        expect(
          () => HttpLogger.logError(
            method: 'GET',
            url: Uri.parse('https://example.com/api/test'),
            error: 'Connection refused',
          ),
          returnsNormally,
        );
      });
    });
  });
}
