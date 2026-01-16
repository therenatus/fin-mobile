import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:clothing_dashboard/core/models/models.dart';
import 'package:clothing_dashboard/core/models/client_user.dart';
import 'package:clothing_dashboard/core/providers/app_provider.dart';
import 'package:clothing_dashboard/core/theme/app_theme.dart';

/// Wrapper widget for testing individual widgets with proper theme and locale.
class TestWrapper extends StatelessWidget {
  final Widget child;
  final ThemeMode themeMode;
  final Size screenSize;

  const TestWrapper({
    super.key,
    required this.child,
    this.themeMode = ThemeMode.light,
    this.screenSize = const Size(390, 844), // iPhone 14 Pro
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: const Locale('ru', 'RU'),
      home: MediaQuery(
        data: MediaQueryData(size: screenSize),
        child: Scaffold(body: child),
      ),
    );
  }
}

/// Wrapper with Provider support for testing widgets that depend on providers.
class TestProviderWrapper extends StatelessWidget {
  final Widget child;
  final AppProvider? appProvider;
  final ThemeMode themeMode;

  const TestProviderWrapper({
    super.key,
    required this.child,
    this.appProvider,
    this.themeMode = ThemeMode.light,
  });

  @override
  Widget build(BuildContext context) {
    Widget wrappedChild = child;

    if (appProvider != null) {
      wrappedChild = ChangeNotifierProvider<AppProvider>.value(
        value: appProvider!,
        child: child,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: const Locale('ru', 'RU'),
      home: Scaffold(body: wrappedChild),
    );
  }
}

/// Factory methods for creating test models
class TestModels {
  /// Create a test Order
  static Order createOrder({
    String id = 'order-1',
    String clientId = 'client-1',
    String modelId = 'model-1',
    int quantity = 1,
    OrderStatus status = OrderStatus.pending,
    DateTime? dueDate,
    Client? client,
    OrderModel? model,
  }) {
    return Order(
      id: id,
      clientId: clientId,
      modelId: modelId,
      quantity: quantity,
      status: status,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      client: client ?? createClient(),
      model: model ?? createOrderModel(),
    );
  }

  /// Create a test OrderModel
  static OrderModel createOrderModel({
    String id = 'model-1',
    String name = 'Платье',
    String? category = 'Женская одежда',
    double basePrice = 5000,
    String? imageUrl,
  }) {
    return OrderModel(
      id: id,
      name: name,
      category: category,
      basePrice: basePrice,
      imageUrl: imageUrl,
    );
  }

  /// Create a test Client
  static Client createClient({
    String id = 'client-1',
    String name = 'Анна Иванова',
    String? email = 'anna@example.com',
    String? phone = '+79001234567',
    int? ordersCount = 5,
    double? totalSpent = 25000,
  }) {
    return Client(
      id: id,
      name: name,
      contacts: ClientContact(
        email: email,
        phone: phone,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ordersCount: ordersCount,
      totalSpent: totalSpent,
    );
  }

  /// Create a VIP test Client
  static Client createVipClient({
    String id = 'vip-client-1',
    String name = 'VIP Клиент',
  }) {
    return createClient(
      id: id,
      name: name,
      ordersCount: 15,
      totalSpent: 75000,
    );
  }

  /// Create a test User
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

  /// Create a test ClientUser
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

  /// Create an overdue test Order
  static Order createOverdueOrder({
    String id = 'overdue-1',
    int daysOverdue = 3,
  }) {
    return createOrder(
      id: id,
      status: OrderStatus.inProgress,
      dueDate: DateTime.now().subtract(Duration(days: daysOverdue)),
    );
  }
}

/// Extension methods for WidgetTester
extension WidgetTesterExtensions on WidgetTester {
  /// Pump widget wrapped in TestWrapper and let animations settle
  Future<void> pumpTestWidget(Widget widget, {
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await pumpWidget(TestWrapper(
      themeMode: themeMode,
      child: widget,
    ));
    await pumpAndSettle();
  }

  /// Find a widget by key and tap it
  Future<void> tapByKey(Key key) async {
    await tap(find.byKey(key));
    await pump();
  }

  /// Find a widget by text and tap it
  Future<void> tapByText(String text) async {
    await tap(find.text(text));
    await pump();
  }

  /// Verify that a widget with specific text exists
  void expectText(String text, {bool exists = true}) {
    if (exists) {
      expect(find.text(text), findsWidgets);
    } else {
      expect(find.text(text), findsNothing);
    }
  }

  /// Verify that a widget with specific key exists
  void expectKey(Key key, {bool exists = true}) {
    if (exists) {
      expect(find.byKey(key), findsOneWidget);
    } else {
      expect(find.byKey(key), findsNothing);
    }
  }
}

/// Common widget finders
class TestFinders {
  /// Find loading indicator
  static Finder loadingIndicator() => find.byType(CircularProgressIndicator);

  /// Find error icon
  static Finder errorIcon() => find.byIcon(Icons.error_outline_rounded);

  /// Find refresh icon
  static Finder refreshIcon() => find.byIcon(Icons.refresh);

  /// Find back button
  static Finder backButton() => find.byIcon(Icons.arrow_back);

  /// Find chevron (navigation indicator)
  static Finder chevronRight() => find.byIcon(Icons.chevron_right);
}
