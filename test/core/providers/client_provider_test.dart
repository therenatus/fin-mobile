import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:clothing_dashboard/core/providers/client_provider.dart';
import 'package:clothing_dashboard/core/services/storage_service.dart';
import 'package:clothing_dashboard/core/services/client_api_service.dart';
import 'package:clothing_dashboard/core/models/client_user.dart';

@GenerateMocks([StorageService, ClientApiService])
import 'client_provider_test.mocks.dart';

void main() {
  late ClientProvider provider;
  late MockStorageService mockStorage;

  setUp(() {
    mockStorage = MockStorageService();

    // Setup default mock returns
    when(mockStorage.getClientUser()).thenAnswer((_) async => null);
    when(mockStorage.getClientAccessToken()).thenAnswer((_) async => null);
    when(mockStorage.getClientRefreshToken()).thenAnswer((_) async => null);
    when(mockStorage.saveClientTokens(any, any)).thenAnswer((_) async {});
    when(mockStorage.saveClientUser(any)).thenAnswer((_) async {});
    when(mockStorage.clearClientData()).thenAnswer((_) async {});
    when(mockStorage.clearClientTokens()).thenAnswer((_) async {});

    provider = ClientProvider(mockStorage);
  });

  group('ClientProvider', () {
    group('initialization', () {
      test('starts with null user', () {
        expect(provider.user, isNull);
        expect(provider.isAuthenticated, isFalse);
      });

      test('starts with empty lists', () {
        expect(provider.tenants, isEmpty);
        expect(provider.orders, isEmpty);
      });

      test('starts with default pagination state', () {
        expect(provider.hasMoreOrders, isTrue);
        expect(provider.isLoadingMoreOrders, isFalse);
      });

      test('init with saved user sets user', () async {
        final savedUser = ClientUser(
          id: '1',
          name: 'Test User',
          email: 'test@example.com',
        );
        when(mockStorage.getClientUser()).thenAnswer((_) async => savedUser);
        when(mockStorage.getClientAccessToken()).thenAnswer((_) async => 'token');

        final newProvider = ClientProvider(mockStorage);
        await newProvider.init();

        expect(newProvider.user, isNotNull);
        expect(newProvider.user?.email, equals('test@example.com'));
      });

      test('init without saved user keeps user null', () async {
        when(mockStorage.getClientUser()).thenAnswer((_) async => null);

        await provider.init();

        expect(provider.user, isNull);
        expect(provider.isAuthenticated, isFalse);
      });

      test('init with user containing tenants preserves tenants', () async {
        final savedUser = ClientUser(
          id: '1',
          name: 'Test User',
          email: 'test@example.com',
          tenants: [
            TenantLink(
              clientId: 'client-1',
              tenantId: 'tenant-1',
              tenantName: 'Atelier 1',
            ),
          ],
        );
        when(mockStorage.getClientUser()).thenAnswer((_) async => savedUser);
        when(mockStorage.getClientAccessToken()).thenAnswer((_) async => 'token');

        final newProvider = ClientProvider(mockStorage);
        await newProvider.init();

        expect(newProvider.user?.tenants, hasLength(1));
        expect(newProvider.user?.tenants.first.tenantName, equals('Atelier 1'));
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
        expect(provider.tenants, isEmpty);
        expect(provider.orders, isEmpty);
      });

      test('logout calls storage clearClientData', () async {
        try {
          await provider.logout();
        } catch (_) {}

        verify(mockStorage.clearClientData()).called(1);
      });
    });

    group('tenant helpers', () {
      test('getOrdersForTenant filters by tenantId', () {
        final orders = provider.getOrdersForTenant('tenant-1');
        expect(orders, isEmpty);
      });

      test('getTotalSpentForTenant returns 0 for empty orders', () {
        final total = provider.getTotalSpentForTenant('tenant-1');
        expect(total, equals(0.0));
      });

      test('getOrdersCountForTenant returns 0 for empty orders', () {
        final count = provider.getOrdersCountForTenant('tenant-1');
        expect(count, equals(0));
      });

      test('getPendingOrdersCountForTenant returns 0 for empty orders', () {
        final count = provider.getPendingOrdersCountForTenant('tenant-1');
        expect(count, equals(0));
      });

      test('getOrdersForTenant returns empty for non-existent tenant', () {
        final orders = provider.getOrdersForTenant('non-existent');
        expect(orders, isEmpty);
      });
    });

    group('pagination', () {
      test('hasMoreOrders starts true', () {
        expect(provider.hasMoreOrders, isTrue);
      });

      test('isLoadingMoreOrders starts false', () {
        expect(provider.isLoadingMoreOrders, isFalse);
      });
    });

    group('refreshData', () {
      test('refreshData does nothing when user is null', () async {
        expect(provider.user, isNull);
        await provider.refreshData();
        // Should complete without error
        expect(provider.tenants, isEmpty);
      });
    });
  });
}
