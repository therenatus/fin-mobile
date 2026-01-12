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

  OrdersProvider(this._api);

  // Getters
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  Future<void> loadOrders({
    String? status,
    String? sortBy,
    String? sortOrder,
    int limit = 20,
  }) async {
    _isLoading = true;
    _page = 1;
    _hasMore = true;
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
      _orders = _getMockOrders();
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
    notifyListeners();
  }

  List<Order> _getMockOrders() {
    final now = DateTime.now();
    return [
      Order(
        id: '1',
        clientId: '1',
        modelId: '1',
        quantity: 2,
        status: OrderStatus.inProgress,
        dueDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
        client: Client(
          id: '1',
          name: 'Анна Петрова',
          contacts: ClientContact(phone: '+7 999 123-45-67'),
          createdAt: now,
          updatedAt: now,
        ),
        model: OrderModel(
          id: '1',
          name: 'Вечернее платье',
          basePrice: 25000,
        ),
      ),
      Order(
        id: '2',
        clientId: '2',
        modelId: '2',
        quantity: 1,
        status: OrderStatus.pending,
        dueDate: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
        client: Client(
          id: '2',
          name: 'Мария Сидорова',
          contacts: ClientContact(phone: '+7 999 765-43-21'),
          createdAt: now,
          updatedAt: now,
        ),
        model: OrderModel(
          id: '2',
          name: 'Деловой костюм',
          basePrice: 35000,
        ),
      ),
      Order(
        id: '3',
        clientId: '3',
        modelId: '3',
        quantity: 3,
        status: OrderStatus.completed,
        dueDate: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
        client: Client(
          id: '3',
          name: 'Елена Козлова',
          contacts: ClientContact(phone: '+7 999 111-22-33'),
          createdAt: now,
          updatedAt: now,
        ),
        model: OrderModel(
          id: '3',
          name: 'Свадебное платье',
          basePrice: 85000,
        ),
      ),
    ];
  }
}
