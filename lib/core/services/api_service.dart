import 'storage_service.dart';
import 'base_api_service.dart';
import 'api/auth_api.dart';
import 'api/orders_api.dart';
import 'api/clients_api.dart';
import 'api/models_api.dart';
import 'api/employees_api.dart';
import 'api/payroll_api.dart';
import 'api/analytics_api.dart';
import 'api/finance_api.dart';
import 'api/ml_api.dart';
import 'api/billing_api.dart';
import 'api/notifications_api.dart';
import 'api/assignments_api.dart';
import 'api/materials_api.dart';
import 'api/suppliers_api.dart';
import 'api/purchases_api.dart';
import 'api/bom_api.dart';
import 'api/costing_api.dart';
import 'api/production_api.dart';
import 'api/qc_api.dart';

/// Exception class for ApiService
class ApiException extends BaseApiException {
  ApiException(
    super.message, {
    super.statusCode,
    super.data,
    super.isNetworkError,
  });
}

/// Main API service for manager mode.
///
/// Uses mixins to organize endpoints by domain:
/// - AuthApiMixin: authentication (login, register, logout, profile)
/// - OrdersApiMixin: order management
/// - ClientsApiMixin: client management and model assignments
/// - ModelsApiMixin: models and process steps
/// - EmployeesApiMixin: employee management and worklogs
/// - PayrollApiMixin: payroll management
/// - AnalyticsApiMixin: dashboard and workload analytics
/// - FinanceApiMixin: transactions and reports
/// - MlApiMixin: ML forecasts and insights
/// - BillingApiMixin: subscriptions and purchases
/// - NotificationsApiMixin: push notifications
/// - AssignmentsApiMixin: order assignments
/// - MaterialsApiMixin: materials and stock management
/// - SuppliersApiMixin: suppliers management
/// - PurchasesApiMixin: purchases management
/// - BomApiMixin: bill of materials
/// - CostingApiMixin: costing, pricing and profitability
/// - ProductionApiMixin: production planning and workload
/// - QcApiMixin: quality control templates, checks and defects
class ApiService extends BaseApiService
    with
        AuthApiMixin,
        OrdersApiMixin,
        ClientsApiMixin,
        ModelsApiMixin,
        EmployeesApiMixin,
        PayrollApiMixin,
        AnalyticsApiMixin,
        FinanceApiMixin,
        MlApiMixin,
        BillingApiMixin,
        NotificationsApiMixin,
        AssignmentsApiMixin,
        MaterialsApiMixin,
        SuppliersApiMixin,
        PurchasesApiMixin,
        BomApiMixin,
        CostingApiMixin,
        ProductionApiMixin,
        QcApiMixin {
  ApiService(StorageService storage) : super(storage);

  @override
  String get logPrefix => '[ApiService]';

  @override
  String get authRefreshEndpoint => '/auth/refresh';

  @override
  Future<String?> getAccessToken() => storage.getAccessToken();

  @override
  Future<String?> getRefreshToken() => storage.getRefreshToken();

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) =>
      storage.saveTokens(accessToken, refreshToken);

  @override
  Future<void> clearTokens() => storage.clearTokens();

  @override
  ApiException createException(
    String message, {
    int? statusCode,
    dynamic data,
    bool isNetworkError = false,
  }) =>
      ApiException(
        message,
        statusCode: statusCode,
        data: data,
        isNetworkError: isNetworkError,
      );
}
