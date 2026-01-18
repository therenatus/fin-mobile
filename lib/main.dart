import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/l10n/l10n.dart';

import 'core/theme/app_theme.dart';
// Client is now managed by Riverpod - see core/riverpod/client_auth_provider.dart
// Employee is now managed by Riverpod - see core/riverpod/employee_auth_provider.dart
// Subscription is now managed by Riverpod - see core/riverpod/subscription_provider.dart
// Theme is now managed by Riverpod - see core/riverpod/theme_provider.dart
// BOM is now managed by Riverpod - see core/riverpod/bom_provider.dart
// Materials is now managed by Riverpod - see core/riverpod/materials_provider.dart
// Production is now managed by Riverpod - see core/riverpod/production_provider.dart
// AppProvider (auth) is now managed by Riverpod - see core/riverpod/auth_provider.dart
import 'core/riverpod/providers.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/deep_link_service.dart';

import 'features/auth/login_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/client_mode/shell/client_app_shell.dart';
import 'features/employee_mode/shell/employee_app_shell.dart';

// OneSignal App ID - configure via flutter build --dart-define=ONESIGNAL_APP_ID=...
const String kOneSignalAppId = String.fromEnvironment(
  'ONESIGNAL_APP_ID',
  defaultValue: '',
);

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
  if (kOneSignalAppId.isNotEmpty && !kOneSignalAppId.startsWith('YOUR_')) {
    await NotificationService.instance.init(kOneSignalAppId);
  } else {
    debugPrint('[Main] OneSignal not configured - push notifications disabled');
  }
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
    // Riverpod ProviderScope wraps everything
    // All state management is now handled by Riverpod:
    // - Storage: storageServiceProvider
    // - Theme: themeNotifierProvider
    // - Auth: authNotifierProvider
    // - Client: clientAuthNotifierProvider
    // - Employee: employeeAuthNotifierProvider
    // - Subscription: subscriptionNotifierProvider
    // - Production: productionNotifierProvider
    // - BOM: bomNotifierProvider
    // - Materials: materialsNotifierProvider
    ProviderScope(
      overrides: [
        // Override storage provider with actual instance
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const AtelieProApp(),
    ),
  );
}

class AtelieProApp extends ConsumerStatefulWidget {
  const AtelieProApp({super.key});

  @override
  ConsumerState<AtelieProApp> createState() => _AtelieProAppState();
}

class _AtelieProAppState extends ConsumerState<AtelieProApp> {
  String? _appMode;
  bool _isCheckingMode = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _checkAppMode();
    }
  }

  Future<void> _checkAppMode() async {
    final storage = ref.read(storageServiceProvider);
    // Migrate tokens to secure storage if needed (one-time)
    await storage.migrateToSecureStorage();
    final mode = await storage.getAppMode();
    setState(() {
      _appMode = mode;
      _isCheckingMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use Riverpod for theme mode
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'AteliePro',
      debugShowCheckedModeBanner: false,
      navigatorKey: DeepLinkService.navigatorKey, // For deep linking
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode, // Now using Riverpod
      locale: const Locale('ru', 'RU'),
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    // Show maintenance screen if backend is down
    if (kMaintenanceMode) {
      return const MaintenanceScreen();
    }

    if (_isCheckingMode) {
      return const SplashScreen();
    }

    // Client mode - check if authenticated (using Riverpod)
    if (_appMode == 'client') {
      final clientAuthState = ref.watch(clientAuthNotifierProvider);
      switch (clientAuthState.state) {
        case ClientAuthState.initial:
        case ClientAuthState.loading:
          return const SplashScreen();
        case ClientAuthState.authenticated:
          return const ClientAppShell();
        case ClientAuthState.unauthenticated:
        case ClientAuthState.error:
          return const LoginScreen();
      }
    }

    // Employee mode - check if authenticated (using Riverpod)
    if (_appMode == 'employee') {
      final employeeAuthState = ref.watch(employeeAuthNotifierProvider);
      switch (employeeAuthState.state) {
        case EmployeeAuthState.initial:
        case EmployeeAuthState.loading:
          return const SplashScreen();
        case EmployeeAuthState.authenticated:
          return const EmployeeAppShell();
        case EmployeeAuthState.unauthenticated:
        case EmployeeAuthState.error:
          return const LoginScreen();
      }
    }

    // Manager mode - check if authenticated (using Riverpod)
    if (_appMode == 'manager') {
      final authState = ref.watch(authNotifierProvider);
      switch (authState.state) {
        case AuthState.initial:
        case AuthState.loading:
          return const SplashScreen();
        case AuthState.authenticated:
          return const AppShell();
        case AuthState.unauthenticated:
        case AuthState.error:
          return const LoginScreen();
      }
    }

    // No mode - show login with tabs (using Riverpod for auth)
    final authState = ref.watch(authNotifierProvider);
    switch (authState.state) {
      case AuthState.initial:
      case AuthState.loading:
        return const SplashScreen();
      case AuthState.authenticated:
        return const AppShell();
      case AuthState.unauthenticated:
      case AuthState.error:
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
