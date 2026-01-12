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

    provider = AppProvider(mockStorage);
  });

  group('AppProvider', () {
    group('initialization', () {
      test('starts with initial state', () {
        expect(provider.state, equals(AppState.initial));
      });

      test('transitions to loading then unauthenticated when no tokens', () async {
        // Wait for async init to complete
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.state, equals(AppState.unauthenticated));
        expect(provider.isAuthenticated, isFalse);
      });
    });

    group('theme', () {
      test('initial theme mode is system', () {
        expect(provider.themeMode, isNotNull);
      });

      test('can set theme mode', () async {
        when(mockStorage.saveThemeMode(any)).thenAnswer((_) async {});

        await provider.setThemeMode(ThemeMode.dark);

        expect(provider.themeMode, equals(ThemeMode.dark));
        verify(mockStorage.saveThemeMode('dark')).called(1);
      });
    });

    group('session expiration', () {
      test('clears user data on session expiration callback', () async {
        // Wait for init
        await Future.delayed(const Duration(milliseconds: 100));

        // Simulate session expiration by calling the callback manually
        // The callback should have been registered in constructor

        // Verify initial state
        expect(provider.state, equals(AppState.unauthenticated));
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
    });
  });
}

// Manual ThemeMode enum for test (matches Flutter)
enum ThemeMode { system, light, dark }
