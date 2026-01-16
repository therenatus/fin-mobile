import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:clothing_dashboard/core/services/storage_service.dart';
import 'package:clothing_dashboard/core/services/secure_storage_service.dart';

@GenerateMocks([SecureStorageService])
import 'storage_service_test.mocks.dart';

void main() {
  // Ensure Flutter bindings are initialized for SharedPreferences
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService service;
  late MockSecureStorageService mockSecure;

  setUp(() {
    mockSecure = MockSecureStorageService();
    service = StorageService.withSecureStorage(mockSecure);

    // Default stubs for secure storage
    when(mockSecure.read(any)).thenAnswer((_) async => null);
    when(mockSecure.write(any, any)).thenAnswer((_) async {});
    when(mockSecure.delete(any)).thenAnswer((_) async {});
    when(mockSecure.deleteAll()).thenAnswer((_) async {});
  });

  group('StorageService', () {
    group('TokenHandler - Manager', () {
      test('saveTokens writes both tokens', () async {
        await service.saveTokens('access123', 'refresh123');

        verify(mockSecure.write('manager_access_token', 'access123')).called(1);
        verify(mockSecure.write('manager_refresh_token', 'refresh123')).called(1);
      });

      test('getAccessToken reads from secure storage', () async {
        when(mockSecure.read('manager_access_token'))
            .thenAnswer((_) async => 'test_access');

        final result = await service.getAccessToken();

        expect(result, equals('test_access'));
      });

      test('getRefreshToken reads from secure storage', () async {
        when(mockSecure.read('manager_refresh_token'))
            .thenAnswer((_) async => 'test_refresh');

        final result = await service.getRefreshToken();

        expect(result, equals('test_refresh'));
      });

      test('hasTokens returns true when access token exists', () async {
        when(mockSecure.read('manager_access_token'))
            .thenAnswer((_) async => 'token');

        final result = await service.hasTokens();

        expect(result, isTrue);
      });

      test('hasTokens returns false when access token is null', () async {
        when(mockSecure.read('manager_access_token'))
            .thenAnswer((_) async => null);

        final result = await service.hasTokens();

        expect(result, isFalse);
      });

      test('hasTokens returns false when access token is empty', () async {
        when(mockSecure.read('manager_access_token'))
            .thenAnswer((_) async => '');

        final result = await service.hasTokens();

        expect(result, isFalse);
      });

      test('clearTokens deletes all manager tokens', () async {
        await service.clearTokens();

        verify(mockSecure.delete('manager_access_token')).called(1);
        verify(mockSecure.delete('manager_refresh_token')).called(1);
        verify(mockSecure.delete('manager_user')).called(1);
      });
    });

    group('TokenHandler - Client', () {
      test('saveClientTokens writes both tokens', () async {
        await service.saveClientTokens('access456', 'refresh456');

        verify(mockSecure.write('client_access_token', 'access456')).called(1);
        verify(mockSecure.write('client_refresh_token', 'refresh456')).called(1);
      });

      test('getClientAccessToken reads from secure storage', () async {
        when(mockSecure.read('client_access_token'))
            .thenAnswer((_) async => 'client_access');

        final result = await service.getClientAccessToken();

        expect(result, equals('client_access'));
      });

      test('hasClientTokens returns true when access token exists', () async {
        when(mockSecure.read('client_access_token'))
            .thenAnswer((_) async => 'token');

        final result = await service.hasClientTokens();

        expect(result, isTrue);
      });

      test('clearClientTokens deletes all client tokens', () async {
        await service.clearClientTokens();

        verify(mockSecure.delete('client_access_token')).called(1);
        verify(mockSecure.delete('client_refresh_token')).called(1);
        verify(mockSecure.delete('client_user')).called(1);
      });
    });

    group('TokenHandler - Employee', () {
      test('saveEmployeeTokens writes both tokens', () async {
        await service.saveEmployeeTokens('access789', 'refresh789');

        verify(mockSecure.write('employee_access_token', 'access789')).called(1);
        verify(mockSecure.write('employee_refresh_token', 'refresh789')).called(1);
      });

      test('getEmployeeAccessToken reads from secure storage', () async {
        when(mockSecure.read('employee_access_token'))
            .thenAnswer((_) async => 'employee_access');

        final result = await service.getEmployeeAccessToken();

        expect(result, equals('employee_access'));
      });

      test('hasEmployeeTokens returns true when access token exists', () async {
        when(mockSecure.read('employee_access_token'))
            .thenAnswer((_) async => 'token');

        final result = await service.hasEmployeeTokens();

        expect(result, isTrue);
      });

      test('clearEmployeeTokens deletes all employee tokens', () async {
        await service.clearEmployeeTokens();

        verify(mockSecure.delete('employee_access_token')).called(1);
        verify(mockSecure.delete('employee_refresh_token')).called(1);
        verify(mockSecure.delete('employee_user')).called(1);
      });
    });

    group('clearAll', () {
      test('clears secure storage', () async {
        // Note: clearAll also clears SharedPreferences, which requires
        // real binding. We only verify secure storage part here.
        // Skip: SharedPreferences.getInstance() requires platform channels
      },
        skip: 'Requires SharedPreferences platform channel setup',
      );
    });

    group('clearManagerData', () {
      test('clears manager tokens', () async {
        await service.clearManagerData();

        verify(mockSecure.delete('manager_access_token')).called(1);
        verify(mockSecure.delete('manager_refresh_token')).called(1);
        verify(mockSecure.delete('manager_user')).called(1);
      });
    });

    group('clearClientData', () {
      test('clears client tokens', () async {
        await service.clearClientData();

        verify(mockSecure.delete('client_access_token')).called(1);
        verify(mockSecure.delete('client_refresh_token')).called(1);
        verify(mockSecure.delete('client_user')).called(1);
      });
    });

    group('clearEmployeeData', () {
      test('clears employee tokens', () async {
        await service.clearEmployeeData();

        verify(mockSecure.delete('employee_access_token')).called(1);
        verify(mockSecure.delete('employee_refresh_token')).called(1);
        verify(mockSecure.delete('employee_user')).called(1);
      });
    });
  });
}
