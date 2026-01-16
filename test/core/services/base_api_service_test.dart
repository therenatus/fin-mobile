import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/services/base_api_service.dart';

void main() {
  group('BaseApiService', () {
    setUp(() {
      // Clear callbacks before each test
      BaseApiService.unregisterSessionExpiredCallback('test1');
      BaseApiService.unregisterSessionExpiredCallback('test2');
    });

    group('session callback registry', () {
      test('registerSessionExpiredCallback adds callback', () {
        var called = false;
        BaseApiService.registerSessionExpiredCallback('test1', () {
          called = true;
        });

        BaseApiService.notifySessionExpired();

        expect(called, isTrue);
      });

      test('unregisterSessionExpiredCallback removes callback', () {
        var called = false;
        BaseApiService.registerSessionExpiredCallback('test1', () {
          called = true;
        });
        BaseApiService.unregisterSessionExpiredCallback('test1');

        BaseApiService.notifySessionExpired();

        expect(called, isFalse);
      });

      test('multiple callbacks are all notified', () {
        var call1 = false;
        var call2 = false;
        BaseApiService.registerSessionExpiredCallback('test1', () {
          call1 = true;
        });
        BaseApiService.registerSessionExpiredCallback('test2', () {
          call2 = true;
        });

        BaseApiService.notifySessionExpired();

        expect(call1, isTrue);
        expect(call2, isTrue);
      });

      test('registering same key overwrites previous callback', () {
        var call1 = false;
        var call2 = false;
        BaseApiService.registerSessionExpiredCallback('test1', () {
          call1 = true;
        });
        BaseApiService.registerSessionExpiredCallback('test1', () {
          call2 = true;
        });

        BaseApiService.notifySessionExpired();

        expect(call1, isFalse);
        expect(call2, isTrue);
      });
    });

    group('BaseApiException', () {
      test('stores message and statusCode', () {
        final exception = BaseApiException(
          'Test error',
          statusCode: 404,
        );

        expect(exception.message, equals('Test error'));
        expect(exception.statusCode, equals(404));
        expect(exception.isNetworkError, isFalse);
      });

      test('stores network error flag', () {
        final exception = BaseApiException(
          'Network error',
          isNetworkError: true,
        );

        expect(exception.isNetworkError, isTrue);
      });

      test('toString returns message', () {
        final exception = BaseApiException('My error message');

        expect(exception.toString(), equals('My error message'));
      });

      test('stores additional data', () {
        final exception = BaseApiException(
          'Error with data',
          data: {'field': 'value'},
        );

        expect(exception.data, isA<Map>());
        expect(exception.data['field'], equals('value'));
      });
    });

    group('baseUrl', () {
      test('returns valid URL', () {
        final url = BaseApiService.baseUrl;

        expect(url, isNotEmpty);
        expect(url, startsWith('http'));
        expect(url, contains('api/v1'));
      });
    });
  });
}
