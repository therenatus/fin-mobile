import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:clothing_dashboard/core/services/secure_storage_service.dart';

@GenerateMocks([FlutterSecureStorage])
import 'secure_storage_service_test.mocks.dart';

void main() {
  late SecureStorageService service;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageService.withStorage(mockStorage);
  });

  group('SecureStorageService', () {
    group('read', () {
      test('returns value when key exists', () async {
        when(mockStorage.read(key: 'test_key'))
            .thenAnswer((_) async => 'test_value');

        final result = await service.read('test_key');

        expect(result, equals('test_value'));
        verify(mockStorage.read(key: 'test_key')).called(1);
      });

      test('returns null when key does not exist', () async {
        when(mockStorage.read(key: 'missing_key'))
            .thenAnswer((_) async => null);

        final result = await service.read('missing_key');

        expect(result, isNull);
      });

      test('returns null on error', () async {
        when(mockStorage.read(key: 'error_key'))
            .thenThrow(Exception('Storage error'));

        final result = await service.read('error_key');

        expect(result, isNull);
      });
    });

    group('write', () {
      test('writes value to storage', () async {
        when(mockStorage.write(key: 'test_key', value: 'test_value'))
            .thenAnswer((_) async {});

        await service.write('test_key', 'test_value');

        verify(mockStorage.write(key: 'test_key', value: 'test_value')).called(1);
      });
    });

    group('delete', () {
      test('deletes key from storage', () async {
        when(mockStorage.delete(key: 'test_key'))
            .thenAnswer((_) async {});

        await service.delete('test_key');

        verify(mockStorage.delete(key: 'test_key')).called(1);
      });
    });

    group('deleteAll', () {
      test('deletes all keys from storage', () async {
        when(mockStorage.deleteAll())
            .thenAnswer((_) async {});

        await service.deleteAll();

        verify(mockStorage.deleteAll()).called(1);
      });
    });

    group('containsKey', () {
      test('returns true when key exists', () async {
        when(mockStorage.containsKey(key: 'existing_key'))
            .thenAnswer((_) async => true);

        final result = await service.containsKey('existing_key');

        expect(result, isTrue);
      });

      test('returns false when key does not exist', () async {
        when(mockStorage.containsKey(key: 'missing_key'))
            .thenAnswer((_) async => false);

        final result = await service.containsKey('missing_key');

        expect(result, isFalse);
      });
    });
  });
}
