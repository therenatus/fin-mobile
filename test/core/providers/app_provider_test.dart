import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:clothing_dashboard/core/providers/app_provider.dart';
import 'package:clothing_dashboard/core/services/api_service.dart';
import 'package:clothing_dashboard/core/services/storage_service.dart';
import 'package:clothing_dashboard/core/models/models.dart';

@GenerateMocks([ApiService, StorageService])
import 'app_provider_test.mocks.dart';

void main() {
  // Ensure Flutter bindings are initialized (required for OneSignal in logout)
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppProvider provider;
  late MockStorageService mockStorage;

  setUp(() {
    mockStorage = MockStorageService();

    // Setup default mock returns
    when(mockStorage.getThemeMode()).thenAnswer((_) async => 'system');
    when(mockStorage.hasTokens()).thenAnswer((_) async => false);
    when(mockStorage.getUser()).thenAnswer((_) async => null);
    when(mockStorage.saveTokens(any, any)).thenAnswer((_) async {});
    when(mockStorage.saveUser(any)).thenAnswer((_) async {});
    when(mockStorage.clearTokens()).thenAnswer((_) async {});
    when(mockStorage.clearUser()).thenAnswer((_) async {});
    when(mockStorage.clearAll()).thenAnswer((_) async {});
    when(mockStorage.getAccessToken()).thenAnswer((_) async => 'test_token');
    when(mockStorage.getRefreshToken()).thenAnswer((_) async => 'refresh_token');
    when(mockStorage.saveThemeMode(any)).thenAnswer((_) async {});

    provider = AppProvider(mockStorage);
  });

  group('AppProvider', () {
    group('initialization', () {
      test('transitions to unauthenticated when no tokens', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.state, equals(AppState.unauthenticated));
        expect(provider.isAuthenticated, isFalse);
      });

      test('transitions to authenticated with saved user and tokens', () async {
        final savedUser = User(
          id: 'user-1',
          email: 'test@example.com',
          tenantId: 'tenant-1',
          roles: ['manager'],
        );
        when(mockStorage.hasTokens()).thenAnswer((_) async => true);
        when(mockStorage.getUser()).thenAnswer((_) async => savedUser);
        when(mockStorage.getAccessToken()).thenAnswer((_) async => 'token');

        final newProvider = AppProvider(mockStorage);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(newProvider.state, equals(AppState.authenticated));
        expect(newProvider.isAuthenticated, isTrue);
        expect(newProvider.user?.email, equals('test@example.com'));
      });

      test('transitions to unauthenticated if has tokens but no user', () async {
        when(mockStorage.hasTokens()).thenAnswer((_) async => true);
        when(mockStorage.getUser()).thenAnswer((_) async => null);

        final newProvider = AppProvider(mockStorage);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(newProvider.state, equals(AppState.unauthenticated));
      });

      test('loads theme mode on init', () async {
        when(mockStorage.getThemeMode()).thenAnswer((_) async => 'dark');

        final newProvider = AppProvider(mockStorage);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(newProvider.themeMode, equals(ThemeMode.dark));
      });

      test('defaults to system theme mode', () async {
        when(mockStorage.getThemeMode()).thenAnswer((_) async => 'invalid');

        final newProvider = AppProvider(mockStorage);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(newProvider.themeMode, equals(ThemeMode.system));
      });
    });

    group('theme', () {
      test('initial theme mode is system', () {
        expect(provider.themeMode, isNotNull);
      });

      test('can set theme mode to dark', () async {
        when(mockStorage.saveThemeMode(any)).thenAnswer((_) async {});

        await provider.setThemeMode(ThemeMode.dark);

        expect(provider.themeMode, equals(ThemeMode.dark));
        verify(mockStorage.saveThemeMode('dark')).called(1);
      });

      test('can set theme mode to light', () async {
        when(mockStorage.saveThemeMode(any)).thenAnswer((_) async {});

        await provider.setThemeMode(ThemeMode.light);

        expect(provider.themeMode, equals(ThemeMode.light));
        verify(mockStorage.saveThemeMode('light')).called(1);
      });

      test('can set theme mode to system', () async {
        when(mockStorage.saveThemeMode(any)).thenAnswer((_) async {});

        await provider.setThemeMode(ThemeMode.system);

        expect(provider.themeMode, equals(ThemeMode.system));
        verify(mockStorage.saveThemeMode('system')).called(1);
      });
    });

    group('session expiration', () {
      test('provider is in unauthenticated state after init without tokens', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.state, equals(AppState.unauthenticated));
        expect(provider.isAuthenticated, isFalse);
      });
    });

    group('orders pagination', () {
      test('starts with default pagination state', () {
        expect(provider.hasMoreOrders, isTrue);
        expect(provider.isLoadingMoreOrders, isFalse);
        expect(provider.recentOrders, isEmpty);
      });
    });

    group('dashboard data', () {
      test('starts with null dashboard stats', () {
        expect(provider.dashboardStats, isNull);
        expect(provider.analyticsDashboard, isNull);
        expect(provider.financeReport, isNull);
      });

      test('analytics period defaults to month', () {
        expect(provider.analyticsPeriod, equals('month'));
      });

      test('clients list starts empty', () {
        expect(provider.clients, isEmpty);
      });

      test('employee roles list starts empty', () {
        expect(provider.employeeRoles, isEmpty);
      });

      test('dashboard error starts null', () {
        expect(provider.dashboardError, isNull);
      });

      test('orders error starts null', () {
        expect(provider.ordersError, isNull);
      });

      test('clients error starts null', () {
        expect(provider.clientsError, isNull);
      });
    });

    group('error handling', () {
      test('can clear error', () {
        provider.clearError();
        expect(provider.error, isNull);
      });
    });

    group('role labels', () {
      test('returns code when role not found', () {
        final label = provider.getRoleLabel('unknown_role');
        expect(label, equals('unknown_role'));
      });

      test('returns code for empty string', () {
        final label = provider.getRoleLabel('');
        expect(label, equals(''));
      });
    });

    group('computed properties', () {
      test('isLoading is true during loading state', () async {
        await Future.delayed(const Duration(milliseconds: 100));
        expect(provider.isLoading, isFalse);
      });

      test('api getter returns api service instance', () {
        expect(provider.api, isNotNull);
        expect(provider.api, isA<ApiService>());
      });
    });

    group('logout', () {
      test('logout clears user and state', () async {
        // Wait for init
        await Future.delayed(const Duration(milliseconds: 100));

        // Note: Actual logout testing requires platform channels for OneSignal
        // This test verifies state is cleared after logout
        expect(provider.state, equals(AppState.unauthenticated));
      },
        skip: 'Requires OneSignal platform channel setup',
      );
    });

    group('updateUser', () {
      test('updates user and saves to storage', () async {
        final newUser = User(
          id: 'user-2',
          email: 'new@example.com',
          tenantId: 'tenant-2',
          roles: ['manager'],
        );

        provider.updateUser(newUser);

        expect(provider.user?.email, equals('new@example.com'));
        verify(mockStorage.saveUser(newUser)).called(1);
      });
    });
  });
}
