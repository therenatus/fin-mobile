import 'package:clothing_dashboard/core/models/models.dart';
import 'package:clothing_dashboard/core/models/client_user.dart';
import 'package:clothing_dashboard/core/models/employee_user.dart';
import 'package:clothing_dashboard/core/models/pagination_meta.dart' as api;

/// Test fixtures for creating mock data in tests.
///
/// These fixtures help create consistent test data across test files.
/// For complex models with many required fields, prefer using real
/// model constructors directly in tests.
class TestFixtures {
  // ==================== Users ====================

  static User createUser({
    String id = 'user-1',
    String email = 'test@example.com',
    String tenantId = 'tenant-1',
    String? name,
    List<String> roles = const ['manager'],
  }) {
    return User(
      id: id,
      email: email,
      tenantId: tenantId,
      name: name,
      roles: roles,
    );
  }

  static ClientUser createClientUser({
    String id = 'client-user-1',
    String? email = 'client@example.com',
    String? phone,
    String name = 'Test Client',
    bool isVerified = false,
    List<TenantLink> tenants = const [],
  }) {
    return ClientUser(
      id: id,
      email: email,
      phone: phone,
      name: name,
      isVerified: isVerified,
      tenants: tenants,
    );
  }

  static EmployeeUser createEmployeeUser({
    String id = 'employee-user-1',
    String email = 'employee@example.com',
    String name = 'Test Employee',
    String role = 'tailor',
    String tenantId = 'tenant-1',
    String tenantName = 'Test Atelier',
  }) {
    return EmployeeUser(
      id: id,
      email: email,
      name: name,
      role: role,
      tenantId: tenantId,
      tenantName: tenantName,
    );
  }

  // ==================== Auth Responses ====================

  static AuthResponse createAuthResponse({
    String accessToken = 'test-access-token',
    String refreshToken = 'test-refresh-token',
    User? user,
  }) {
    return AuthResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user ?? createUser(),
    );
  }

  static ClientAuthResponse createClientAuthResponse({
    String accessToken = 'test-access-token',
    String refreshToken = 'test-refresh-token',
    ClientUser? user,
  }) {
    return ClientAuthResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user ?? createClientUser(),
    );
  }

  static EmployeeAuthResponse createEmployeeAuthResponse({
    String accessToken = 'test-access-token',
    String refreshToken = 'test-refresh-token',
    EmployeeUser? user,
  }) {
    return EmployeeAuthResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user ?? createEmployeeUser(),
    );
  }

  // ==================== Client Data ====================

  static ClientOrder createClientOrder({
    String id = 'order-1',
    String tenantId = 'tenant-1',
    String tenantName = 'Test Atelier',
    String status = 'pending',
    int quantity = 1,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return ClientOrder(
      id: id,
      tenantId: tenantId,
      tenantName: tenantName,
      model: createClientOrderModel(),
      quantity: quantity,
      status: status,
      dueDate: dueDate,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  static ClientOrderModel createClientOrderModel({
    String id = 'model-1',
    String name = 'Test Model',
    String? category,
    String? imageUrl,
    double? basePrice,
  }) {
    return ClientOrderModel(
      id: id,
      name: name,
      category: category,
      imageUrl: imageUrl,
      basePrice: basePrice,
    );
  }

  static TenantLink createTenantLink({
    String clientId = 'client-1',
    String tenantId = 'tenant-1',
    String tenantName = 'Test Atelier',
    String? tenantDomain,
  }) {
    return TenantLink(
      clientId: clientId,
      tenantId: tenantId,
      tenantName: tenantName,
      tenantDomain: tenantDomain,
    );
  }

  // ==================== Pagination ====================

  static api.PaginationMeta createPaginationMeta({
    int page = 1,
    int perPage = 20,
    int total = 100,
    int totalPages = 5,
  }) {
    return api.PaginationMeta(
      page: page,
      perPage: perPage,
      total: total,
      totalPages: totalPages,
    );
  }

  static ClientOrdersResponse createClientOrdersResponse({
    List<ClientOrder>? orders,
    api.PaginationMeta? meta,
  }) {
    return ClientOrdersResponse(
      orders: orders ?? [createClientOrder()],
      meta: meta ?? createPaginationMeta(),
    );
  }
}
