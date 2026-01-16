import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:clothing_dashboard/core/providers/employee_provider.dart';
import 'package:clothing_dashboard/core/services/storage_service.dart';
import 'package:clothing_dashboard/core/services/employee_api_service.dart';
import 'package:clothing_dashboard/core/models/employee_user.dart';

@GenerateMocks([StorageService, EmployeeApiService])
import 'employee_provider_test.mocks.dart';

void main() {
  late EmployeeProvider provider;
  late MockStorageService mockStorage;

  setUp(() {
    mockStorage = MockStorageService();

    // Setup default mock returns
    when(mockStorage.getEmployeeUser()).thenAnswer((_) async => null);
    when(mockStorage.getEmployeeAccessToken()).thenAnswer((_) async => null);
    when(mockStorage.getEmployeeRefreshToken()).thenAnswer((_) async => null);
    when(mockStorage.saveEmployeeTokens(any, any)).thenAnswer((_) async {});
    when(mockStorage.saveEmployeeUser(any)).thenAnswer((_) async {});
    when(mockStorage.clearEmployeeData()).thenAnswer((_) async {});
    when(mockStorage.clearEmployeeTokens()).thenAnswer((_) async {});

    provider = EmployeeProvider(mockStorage);
  });

  group('EmployeeProvider', () {
    group('initialization', () {
      test('starts with null user', () {
        expect(provider.user, isNull);
        expect(provider.isAuthenticated, isFalse);
      });

      test('starts with empty lists', () {
        expect(provider.assignments, isEmpty);
        expect(provider.workLogs, isEmpty);
        expect(provider.payrolls, isEmpty);
      });

      test('starts with default pagination state', () {
        expect(provider.hasMoreAssignments, isTrue);
        expect(provider.isLoadingMoreAssignments, isFalse);
      });

      test('init with saved user sets user', () async {
        final savedUser = EmployeeUser(
          id: '1',
          name: 'Test Employee',
          email: 'employee@example.com',
          role: 'tailor',
          tenantId: 'tenant-1',
          tenantName: 'Test Atelier',
        );
        when(mockStorage.getEmployeeUser()).thenAnswer((_) async => savedUser);
        when(mockStorage.getEmployeeAccessToken()).thenAnswer((_) async => 'token');

        final newProvider = EmployeeProvider(mockStorage);
        await newProvider.init();

        expect(newProvider.user, isNotNull);
        expect(newProvider.user?.email, equals('employee@example.com'));
      });

      test('init without saved user keeps user null', () async {
        when(mockStorage.getEmployeeUser()).thenAnswer((_) async => null);

        await provider.init();

        expect(provider.user, isNull);
        expect(provider.isAuthenticated, isFalse);
      });

      test('init with user preserves role and tenant info', () async {
        final savedUser = EmployeeUser(
          id: '1',
          name: 'Test Employee',
          email: 'employee@example.com',
          role: 'cutter',
          tenantId: 'tenant-1',
          tenantName: 'Premium Atelier',
        );
        when(mockStorage.getEmployeeUser()).thenAnswer((_) async => savedUser);
        when(mockStorage.getEmployeeAccessToken()).thenAnswer((_) async => 'token');

        final newProvider = EmployeeProvider(mockStorage);
        await newProvider.init();

        expect(newProvider.user?.role, equals('cutter'));
        expect(newProvider.user?.tenantName, equals('Premium Atelier'));
      });
    });

    group('state', () {
      test('isLoading starts false', () {
        expect(provider.isLoading, isFalse);
      });

      test('error starts null', () {
        expect(provider.error, isNull);
      });

      test('clearError clears error state', () {
        provider.clearError();
        expect(provider.error, isNull);
      });
    });

    group('authentication', () {
      test('isAuthenticated returns false when user is null', () {
        expect(provider.isAuthenticated, isFalse);
      });
    });

    group('logout', () {
      test('logout clears state even if API fails', () async {
        try {
          await provider.logout();
        } catch (_) {
          // Expected - no real API server
        }

        expect(provider.user, isNull);
        expect(provider.assignments, isEmpty);
        expect(provider.workLogs, isEmpty);
        expect(provider.payrolls, isEmpty);
      });

      test('logout calls storage clearEmployeeData', () async {
        try {
          await provider.logout();
        } catch (_) {}

        verify(mockStorage.clearEmployeeData()).called(1);
      });
    });

    group('role labels', () {
      test('returns Russian label for tailor', () {
        expect(provider.getRoleLabel('tailor'), equals('Портной'));
      });

      test('returns Russian label for cutter', () {
        expect(provider.getRoleLabel('cutter'), equals('Раскройщик'));
      });

      test('returns Russian label for seamstress', () {
        expect(provider.getRoleLabel('seamstress'), equals('Швея'));
      });

      test('returns Russian label for designer', () {
        expect(provider.getRoleLabel('designer'), equals('Дизайнер'));
      });

      test('returns Russian label for fitter', () {
        expect(provider.getRoleLabel('fitter'), equals('Закройщик'));
      });

      test('returns code for unknown roles', () {
        expect(provider.getRoleLabel('unknown_role'), equals('unknown_role'));
        expect(provider.getRoleLabel('custom'), equals('custom'));
      });

      test('returns empty string for empty role', () {
        expect(provider.getRoleLabel(''), equals(''));
      });
    });

    group('pagination', () {
      test('hasMoreAssignments starts true', () {
        expect(provider.hasMoreAssignments, isTrue);
      });

      test('isLoadingMoreAssignments starts false', () {
        expect(provider.isLoadingMoreAssignments, isFalse);
      });
    });

    group('refreshData', () {
      test('refreshData does nothing when user is null', () async {
        expect(provider.user, isNull);
        await provider.refreshData();
        // Should complete without error
        expect(provider.assignments, isEmpty);
        expect(provider.workLogs, isEmpty);
        expect(provider.payrolls, isEmpty);
      });
    });

    group('workLogs', () {
      test('workLogs list starts empty', () {
        expect(provider.workLogs, isEmpty);
      });
    });

    group('payrolls', () {
      test('payrolls list starts empty', () {
        expect(provider.payrolls, isEmpty);
      });
    });
  });
}
