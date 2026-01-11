# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AteliePro is a Flutter mobile app for clothing/tailoring business management. It's part of a monorepo with a NestJS backend server. The app supports three user modes: Manager, Employee, and Client.

## Commands

```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d ios
flutter run -d android

# Analyze code for errors
flutter analyze

# Build for production
flutter build apk      # Android
flutter build ios      # iOS
```

## Architecture

### Directory Structure

```
lib/
├── main.dart              # App entry point, providers setup, mode routing
├── core/                  # Shared infrastructure
│   ├── models/            # Data models (Order, Client, Employee, etc.)
│   ├── providers/         # State management (AppProvider, ClientProvider, EmployeeProvider)
│   ├── services/          # API services and storage
│   ├── theme/             # AppTheme, AppColors, AppTypography
│   └── widgets/           # Reusable UI components
└── features/              # Feature modules
    ├── shell/             # AppShell - main navigation shell for managers
    ├── employee_mode/     # Employee-specific screens and shell
    ├── client_mode/       # Client-specific screens and shell
    ├── orders/            # Order management screens
    ├── employees/         # Employee management
    ├── clients/           # Client management
    └── ...                # Other feature modules
```

### Multi-Mode Architecture

The app has three user modes determined at login, each with its own shell:
- **Manager mode** (`AppShell`): Full access to all features via bottom nav + drawer
- **Employee mode** (`EmployeeAppShell`): Task-focused interface for workers
- **Client mode** (`ClientAppShell`): Order tracking for clients

Mode is stored via `StorageService.getAppMode()` and checked in `main.dart`.

### State Management

Uses Provider pattern with three main providers:
- `AppProvider`: Manager auth state, dashboard data, theme
- `EmployeeProvider`: Employee auth and assignments
- `ClientProvider`: Client auth and order tracking

### API Layer

- `ApiService`: Main API client for manager mode (connects to NestJS backend at port 4000)
- `EmployeeApiService`: Employee-specific endpoints
- `ClientApiService`: Client-specific endpoints

API base URL is configured in `api_service.dart`:
- Localhost for simulator: `http://localhost:4000/api/v1`
- Real device: Update IP in `ApiService.baseUrl` getter

### Theme System

`core/theme/app_theme.dart` provides:
- `AppColors`: Color constants including dark mode variants
- `AppTypography`: Text styles (h1-h4, body, labels)
- `AppSpacing`, `AppRadius`: Layout constants
- `ThemeColors` extension on `BuildContext` for theme-aware colors

Usage: `context.backgroundColor`, `context.textPrimaryColor`, etc.

### Widgets

Common widgets exported from `core/widgets/widgets.dart`:
- `AppSearchBar`, `EmptyState`, `LoadingState`
- `OrderCard`, `ClientCard`, `StatusBadge`
- `DateRangePickerButton` for date filtering

## Key Patterns

### Screen Structure

Screens typically follow this pattern:
```dart
class SomeScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;  // For drawer toggle
  // ...
}
```

### Navigation

- Bottom navigation controlled by `AppShell` (5 main destinations)
- Additional screens accessed via Drawer menu using `Navigator.push`
- Each screen receives `onMenuPressed` callback to open drawer

### Data Loading

Screens load data from API in `initState()` or use `Consumer<AppProvider>` for cached data:
```dart
Consumer<AppProvider>(
  builder: (context, provider, _) {
    return _buildList(provider.recentOrders);
  },
)
```

## Language

The app UI is in Russian. All user-facing strings are in Russian.
