import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

void _log(String message) {
  debugPrint('[OrdersProvider] $message');
}

class OrdersProvider with ChangeNotifier {
  final ApiService _api;

  List<Order> _orders = [];
  int _page = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  OrdersProvider(this._api);

  // Getters
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> loadOrders({
    String? status,
    String? sortBy,
    String? sortOrder,
    int limit = 20,
  }) async {
    _isLoading = true;
    _page = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.getOrders(
        page: 1,
        limit: limit,
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      _orders = response.orders;
      _hasMore = response.meta.page < response.meta.totalPages;
    } catch (e) {
      _log('Error loading orders: $e');
      _orders = [];
      _error = e.toString();
      _hasMore = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh({
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    _page = 1;
    _hasMore = true;

    try {
      final response = await _api.getOrders(
        page: 1,
        limit: 20,
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      _orders = response.orders;
      _hasMore = response.meta.page < response.meta.totalPages;
      notifyListeners();
    } catch (e) {
      _log('Error refreshing orders: $e');
    }
  }

  Future<void> loadMore({
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _api.getOrders(
        page: _page + 1,
        limit: 20,
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      _page++;
      _orders.addAll(response.orders);
      _hasMore = response.meta.page < response.meta.totalPages;
    } catch (e) {
      _log('Error loading more orders: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void clear() {
    _orders = [];
    _page = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }
}
