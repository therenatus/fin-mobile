# AteliePro Mobile

Flutter mobile application for the AteliePro platform. Designed for employees to manage orders, track work, and access client information on the go.

## Tech Stack

- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Riverpod** - State management
- **Dio** - HTTP client
- **Syncfusion** - Charts and data visualization

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK
- Android Studio or VS Code
- iOS Simulator or Android Emulator

### Installation

```bash
flutter pub get
```

### Configuration

Update API URL in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://localhost:3000/api/v1';
```

### Running

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device_id>
```

## Project Structure

```
lib/
├── main.dart              # Entry point
├── providers/             # Riverpod state providers
│   ├── auth_provider.dart
│   ├── orders_provider.dart
│   └── ...
├── screens/               # App screens
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── orders_screen.dart
│   ├── clients_screen.dart
│   └── ...
├── services/              # API and business logic
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── ...
├── models/                # Data models
│   ├── order.dart
│   ├── client.dart
│   └── ...
├── widgets/               # Reusable UI components
│   ├── order_card.dart
│   ├── status_badge.dart
│   └── ...
└── utils/                 # Utility functions
    ├── constants.dart
    └── helpers.dart
```

## Features

### Screens

- **Login** - Employee authentication
- **Dashboard** - Overview with today's tasks
- **Orders** - Order list and details
- **Clients** - Client information and measurements
- **Work Logs** - Track work time and progress
- **Finance** - View transactions
- **Analytics** - Business metrics
- **Settings** - Profile and preferences

### State Management

Using Riverpod for reactive state:

```dart
final ordersProvider = FutureProvider<List<Order>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getOrders();
});
```

### Authentication

JWT-based with secure token storage:

```dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
```

## Building

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle
```

### iOS

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

## Development

### Adding New Screens

1. Create screen in `lib/screens/`
2. Add route in `lib/main.dart`
3. Create provider if needed in `lib/providers/`

### Code Style

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/
```

## Scripts

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run on device/emulator |
| `flutter build apk` | Build Android APK |
| `flutter build ios` | Build iOS app |
| `flutter test` | Run tests |
| `flutter analyze` | Analyze code |
