import 'package:flutter/foundation.dart';
import '../../utils/pagination_helper.dart';

export '../../utils/pagination_helper.dart' show PaginationState, PaginatedResult, PaginationMeta;

/// Mixin for managing multiple pagination states in providers.
///
/// Provides standardized methods for creating, refreshing, and clearing
/// pagination controllers. Uses the existing PaginationState class.
///
/// Usage:
/// ```dart
/// class MyProvider extends ChangeNotifier with PaginationMixin {
///   late final PaginationState<Order> ordersPagination;
///
///   MyProvider() {
///     ordersPagination = createPaginationController<Order>(logPrefix: 'Orders');
///   }
///
///   List<Order> get orders => ordersPagination.items;
///   bool get isLoadingMoreOrders => ordersPagination.isLoadingMore;
///   bool get hasMoreOrders => ordersPagination.hasMore;
///
///   Future<void> refreshOrders() async {
///     await ordersPagination.refresh(
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
mixin PaginationMixin on ChangeNotifier {
  final List<PaginationState> _paginationControllers = [];

  /// Create a new pagination controller and track it for cleanup.
  @protected
  PaginationState<T> createPaginationController<T>({
    int limit = 20,
    String logPrefix = 'Pagination',
  }) {
    final controller = PaginationState<T>(
      limit: limit,
      logPrefix: logPrefix,
    );
    _paginationControllers.add(controller);
    return controller;
  }

  /// Clear all pagination controllers (call on logout/reset).
  @protected
  void clearAllPagination() {
    for (final controller in _paginationControllers) {
      controller.clear();
    }
  }
}
