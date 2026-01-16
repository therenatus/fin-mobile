import 'package:flutter/foundation.dart';

/// Lightweight pagination metadata for internal state management.
///
/// This is separate from `models/pagination_meta.dart` which is used
/// for parsing API responses. This class is for internal state tracking
/// in the pagination helper.
class PaginationMeta {
  final int page;
  final int totalPages;
  final bool hasNextPage;

  const PaginationMeta({
    required this.page,
    required this.totalPages,
    required this.hasNextPage,
  });

  /// Create from page and totalPages (e.g., from OrdersResponse.meta)
  factory PaginationMeta.fromTotalPages(int page, int totalPages) {
    return PaginationMeta(
      page: page,
      totalPages: totalPages,
      hasNextPage: page < totalPages,
    );
  }

  /// Create from page and hasNextPage flag (e.g., from ClientOrdersResponse.meta)
  factory PaginationMeta.fromHasNextPage(int page, bool hasNextPage) {
    return PaginationMeta(
      page: page,
      totalPages: hasNextPage ? page + 1 : page,
      hasNextPage: hasNextPage,
    );
  }

  /// Create from a models/pagination_meta.dart PaginationMeta
  factory PaginationMeta.fromApiMeta(dynamic apiMeta) {
    // Works with models/pagination_meta.dart which has page, totalPages, hasNextPage
    return PaginationMeta(
      page: apiMeta.page as int,
      totalPages: apiMeta.totalPages as int,
      hasNextPage: apiMeta.hasNextPage as bool,
    );
  }
}

/// Generic pagination state manager for providers
///
/// Usage:
/// ```dart
/// class MyProvider extends ChangeNotifier {
///   final _ordersPagination = PaginationState<Order>();
///
///   List<Order> get orders => _ordersPagination.items;
///   bool get isLoadingMore => _ordersPagination.isLoadingMore;
///   bool get hasMore => _ordersPagination.hasMore;
///
///   Future<void> refreshOrders() async {
///     await _ordersPagination.refresh(
///       fetcher: (page, limit) async {
///         final response = await _api.getOrders(page: page, limit: limit);
///         return PaginatedResult(
///           items: response.orders,
///           meta: PaginationMeta.fromTotalPages(response.meta.page, response.meta.totalPages),
///         );
///       },
///       onUpdate: notifyListeners,
///     );
///   }
///
///   Future<void> loadMoreOrders() async {
///     await _ordersPagination.loadMore(
///       fetcher: (page, limit) async {
///         final response = await _api.getOrders(page: page, limit: limit);
///         return PaginatedResult(
///           items: response.orders,
///           meta: PaginationMeta.fromTotalPages(response.meta.page, response.meta.totalPages),
///         );
///       },
///       onUpdate: notifyListeners,
///     );
///   }
/// }
/// ```
class PaginationState<T> {
  List<T> _items = [];
  int _page = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final int _limit;
  final String _logPrefix;

  PaginationState({
    int limit = 20,
    String logPrefix = 'Pagination',
  })  : _limit = limit,
        _logPrefix = logPrefix;

  // Getters
  List<T> get items => _items;
  int get page => _page;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  int get limit => _limit;

  void _log(String message) {
    debugPrint('[$_logPrefix] $message');
  }

  /// Refresh the list (reset to page 1)
  Future<void> refresh({
    required Future<PaginatedResult<T>> Function(int page, int limit) fetcher,
    required VoidCallback onUpdate,
  }) async {
    _page = 1;
    _hasMore = true;

    try {
      final result = await fetcher(1, _limit);
      _items = result.items;
      _hasMore = result.meta.hasNextPage;
      onUpdate();
    } catch (e) {
      _log('Error refreshing: $e');
    }
  }

  /// Load more items (next page)
  Future<void> loadMore({
    required Future<PaginatedResult<T>> Function(int page, int limit) fetcher,
    required VoidCallback onUpdate,
  }) async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    onUpdate();

    try {
      final result = await fetcher(_page + 1, _limit);
      _page++;
      _items.addAll(result.items);
      _hasMore = result.meta.hasNextPage;
    } catch (e) {
      _log('Error loading more: $e');
    } finally {
      _isLoadingMore = false;
      onUpdate();
    }
  }

  /// Clear all items and reset state
  void clear() {
    _items = [];
    _page = 1;
    _isLoadingMore = false;
    _hasMore = true;
  }
}

/// Result wrapper for paginated API responses
class PaginatedResult<T> {
  final List<T> items;
  final PaginationMeta meta;

  const PaginatedResult({
    required this.items,
    required this.meta,
  });
}
