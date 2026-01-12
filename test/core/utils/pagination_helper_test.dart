import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/utils/pagination_helper.dart';

void main() {
  group('PaginationMeta', () {
    test('fromTotalPages calculates hasNextPage correctly', () {
      final meta1 = PaginationMeta.fromTotalPages(1, 3);
      expect(meta1.hasNextPage, isTrue);
      expect(meta1.page, equals(1));
      expect(meta1.totalPages, equals(3));

      final meta2 = PaginationMeta.fromTotalPages(3, 3);
      expect(meta2.hasNextPage, isFalse);

      final meta3 = PaginationMeta.fromTotalPages(1, 1);
      expect(meta3.hasNextPage, isFalse);
    });

    test('fromHasNextPage creates correct meta', () {
      final meta1 = PaginationMeta.fromHasNextPage(1, true);
      expect(meta1.hasNextPage, isTrue);
      expect(meta1.page, equals(1));

      final meta2 = PaginationMeta.fromHasNextPage(5, false);
      expect(meta2.hasNextPage, isFalse);
      expect(meta2.page, equals(5));
    });
  });

  group('PaginationState', () {
    late PaginationState<String> state;

    setUp(() {
      state = PaginationState<String>(limit: 10, logPrefix: 'Test');
    });

    test('starts with default values', () {
      expect(state.items, isEmpty);
      expect(state.page, equals(1));
      expect(state.isLoadingMore, isFalse);
      expect(state.hasMore, isTrue);
      expect(state.limit, equals(10));
    });

    test('refresh loads first page', () async {
      var updateCalled = false;

      await state.refresh(
        fetcher: (page, limit) async {
          expect(page, equals(1));
          expect(limit, equals(10));
          return PaginatedResult(
            items: ['a', 'b', 'c'],
            meta: PaginationMeta.fromTotalPages(1, 2),
          );
        },
        onUpdate: () => updateCalled = true,
      );

      expect(state.items, equals(['a', 'b', 'c']));
      expect(state.page, equals(1));
      expect(state.hasMore, isTrue);
      expect(updateCalled, isTrue);
    });

    test('refresh resets state before loading', () async {
      // First load some data
      await state.refresh(
        fetcher: (page, limit) async => PaginatedResult(
          items: ['a', 'b'],
          meta: PaginationMeta.fromTotalPages(1, 2),
        ),
        onUpdate: () {},
      );

      // Simulate loading more
      await state.loadMore(
        fetcher: (page, limit) async => PaginatedResult(
          items: ['c', 'd'],
          meta: PaginationMeta.fromTotalPages(2, 2),
        ),
        onUpdate: () {},
      );

      expect(state.page, equals(2));
      expect(state.items.length, equals(4));

      // Refresh should reset
      await state.refresh(
        fetcher: (page, limit) async => PaginatedResult(
          items: ['x', 'y'],
          meta: PaginationMeta.fromTotalPages(1, 1),
        ),
        onUpdate: () {},
      );

      expect(state.page, equals(1));
      expect(state.items, equals(['x', 'y']));
      expect(state.hasMore, isFalse);
    });

    test('loadMore appends items and increments page', () async {
      // First load
      await state.refresh(
        fetcher: (page, limit) async => PaginatedResult(
          items: ['a', 'b'],
          meta: PaginationMeta.fromTotalPages(1, 3),
        ),
        onUpdate: () {},
      );

      // Load more
      await state.loadMore(
        fetcher: (page, limit) async {
          expect(page, equals(2));
          return PaginatedResult(
            items: ['c', 'd'],
            meta: PaginationMeta.fromTotalPages(2, 3),
          );
        },
        onUpdate: () {},
      );

      expect(state.items, equals(['a', 'b', 'c', 'd']));
      expect(state.page, equals(2));
      expect(state.hasMore, isTrue);
    });

    test('loadMore does nothing when already loading', () async {
      // First load
      await state.refresh(
        fetcher: (page, limit) async => PaginatedResult(
          items: ['a'],
          meta: PaginationMeta.fromTotalPages(1, 3),
        ),
        onUpdate: () {},
      );

      var fetchCount = 0;

      // Start two loadMore calls simultaneously
      final future1 = state.loadMore(
        fetcher: (page, limit) async {
          fetchCount++;
          await Future.delayed(const Duration(milliseconds: 50));
          return PaginatedResult(
            items: ['b'],
            meta: PaginationMeta.fromTotalPages(2, 3),
          );
        },
        onUpdate: () {},
      );

      // This should be ignored because isLoadingMore is true
      final future2 = state.loadMore(
        fetcher: (page, limit) async {
          fetchCount++;
          return PaginatedResult(
            items: ['c'],
            meta: PaginationMeta.fromTotalPages(2, 3),
          );
        },
        onUpdate: () {},
      );

      await Future.wait([future1, future2]);

      // Only the first fetch should have been called
      expect(fetchCount, equals(1));
    });

    test('loadMore does nothing when hasMore is false', () async {
      // Load with no more pages
      await state.refresh(
        fetcher: (page, limit) async => PaginatedResult(
          items: ['a'],
          meta: PaginationMeta.fromTotalPages(1, 1),
        ),
        onUpdate: () {},
      );

      expect(state.hasMore, isFalse);

      var fetchCalled = false;
      await state.loadMore(
        fetcher: (page, limit) async {
          fetchCalled = true;
          return PaginatedResult(
            items: ['b'],
            meta: PaginationMeta.fromTotalPages(2, 2),
          );
        },
        onUpdate: () {},
      );

      expect(fetchCalled, isFalse);
      expect(state.items, equals(['a']));
    });

    test('clear resets all state', () async {
      // Load some data
      await state.refresh(
        fetcher: (page, limit) async => PaginatedResult(
          items: ['a', 'b', 'c'],
          meta: PaginationMeta.fromTotalPages(1, 1),
        ),
        onUpdate: () {},
      );

      expect(state.items.isNotEmpty, isTrue);
      expect(state.hasMore, isFalse);

      state.clear();

      expect(state.items, isEmpty);
      expect(state.page, equals(1));
      expect(state.hasMore, isTrue);
      expect(state.isLoadingMore, isFalse);
    });

    test('handles fetch errors gracefully', () async {
      await state.refresh(
        fetcher: (page, limit) async {
          throw Exception('Network error');
        },
        onUpdate: () {},
      );

      // Should not crash, items should remain empty
      expect(state.items, isEmpty);
    });
  });

  group('PaginatedResult', () {
    test('stores items and meta correctly', () {
      final result = PaginatedResult(
        items: [1, 2, 3],
        meta: PaginationMeta(page: 1, totalPages: 5, hasNextPage: true),
      );

      expect(result.items, equals([1, 2, 3]));
      expect(result.meta.page, equals(1));
      expect(result.meta.totalPages, equals(5));
      expect(result.meta.hasNextPage, isTrue);
    });
  });
}
