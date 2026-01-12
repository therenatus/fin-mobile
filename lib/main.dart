import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/client_provider.dart';
import 'core/providers/employee_provider.dart';
import 'core/providers/subscription_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/dashboard_provider.dart';
import 'core/providers/orders_provider.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/local_notification_service.dart';

import 'features/auth/login_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/client_mode/shell/client_app_shell.dart';
import 'features/employee_mode/shell/employee_app_shell.dart';

// OneSignal App ID - replace with your actual app ID from OneSignal dashboard
const String kOneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';

// Sentry DSN - configure via flutter build --dart-define=SENTRY_DSN=...
const String kSentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

// Maintenance mode - set to true when backend is down
const bool kMaintenanceMode = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initializeDateFormatting('ru_RU', null);

  // Initialize notification services
  await NotificationService.instance.init(kOneSignalAppId);
  await LocalNotificationService.instance.init();

  final storageService = StorageService();

  // Initialize Sentry if DSN is configured
  if (kSentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = kSentryDsn;
        options.environment = const String.fromEnvironment('ENV', defaultValue: 'development');
        options.tracesSampleRate = 0.1;
      },
      appRunner: () => _runApp(storageService),
    );
  } else {
    _runApp(storageService);
  }
}

void _runApp(StorageService storageService) {
  runApp(
    MultiProvider(
      providers: [
        // Core services
        Provider<StorageService>.value(value: storageService),

        // Theme provider (standalone)
        ChangeNotifierProvider(create: (_) => ThemeProvider(storageService)),

        // Main app provider (backward compatible)
        ChangeNotifierProvider(create: (_) => AppProvider(storageService)),

        // Mode-specific providers
        ChangeNotifierProvider(create: (_) => ClientProvider(storageService)..init()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider(storageService)..init()),

        // Providers that depend on AppProvider.api
        ChangeNotifierProxyProvider<AppProvider, SubscriptionProvider>(
          create: (context) => SubscriptionProvider(
            context.read<AppProvider>().api,
          ),
          update: (context, appProvider, previous) =>
              previous ?? SubscriptionProvider(appProvider.api),
        ),
        ChangeNotifierProxyProvider<AppProvider, DashboardProvider>(
          create: (context) => DashboardProvider(
            context.read<AppProvider>().api,
          ),
          update: (context, appProvider, previous) =>
              previous ?? DashboardProvider(appProvider.api),
        ),
        ChangeNotifierProxyProvider<AppProvider, OrdersProvider>(
          create: (context) => OrdersProvider(
            context.read<AppProvider>().api,
          ),
          update: (context, appProvider, previous) =>
              previous ?? OrdersProvider(appProvider.api),
        ),
      ],
      child: const AtelieProApp(),
    ),
  );
}

class AtelieProApp extends StatefulWidget {
  const AtelieProApp({super.key});

  @override
  State<AtelieProApp> createState() => _AtelieProAppState();
}

class _AtelieProAppState extends State<AtelieProApp> {
  String? _appMode;
  bool _isCheckingMode = true;

  @override
  void initState() {
    super.initState();
    _checkAppMode();
  }

  Future<void> _checkAppMode() async {
    final storage = StorageService();
    final mode = await storage.getAppMode();
    setState(() {
      _appMode = mode;
      _isCheckingMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return MaterialApp(
          title: 'AteliePro',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: appProvider.themeMode,
          locale: const Locale('ru', 'RU'),
          supportedLocales: const [
            Locale('ru', 'RU'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: _buildHome(appProvider),
        );
      },
    );
  }

  Widget _buildHome(AppProvider appProvider) {
    // Show maintenance screen if backend is down
    if (kMaintenanceMode) {
      return const MaintenanceScreen();
    }

    if (_isCheckingMode) {
      return const SplashScreen();
    }

    // Client mode - check if authenticated
    if (_appMode == 'client') {
      return Consumer<ClientProvider>(
        builder: (context, clientProvider, _) {
          if (clientProvider.isAuthenticated) {
            return const ClientAppShell();
          }
          return const LoginScreen();
        },
      );
    }

    // Employee mode - check if authenticated
    if (_appMode == 'employee') {
      return Consumer<EmployeeProvider>(
        builder: (context, employeeProvider, _) {
          if (employeeProvider.isAuthenticated) {
            return const EmployeeAppShell();
          }
          return const LoginScreen();
        },
      );
    }

    // Manager mode - check if authenticated
    if (_appMode == 'manager') {
      switch (appProvider.state) {
        case AppState.initial:
        case AppState.loading:
          return const SplashScreen();
        case AppState.authenticated:
          return const AppShell();
        case AppState.unauthenticated:
        case AppState.error:
          return const LoginScreen();
      }
    }

    // No mode - show login with tabs
    switch (appProvider.state) {
      case AppState.initial:
      case AppState.loading:
        return const SplashScreen();
      case AppState.authenticated:
        return const AppShell();
      case AppState.unauthenticated:
      case AppState.error:
        return const LoginScreen();
    }
  }
}

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.construction,
                    size: 50,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Приложение временно недоступно',
                  style: AppTypography.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ведутся технические работы.\nПожалуйста, попробуйте позже.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white.withAlpha(204),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.white.withAlpha(180),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Скоро вернёмся',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.content_cut,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'AteliePro',
                style: AppTypography.h1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Управление ателье',
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.white.withAlpha(204),
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
