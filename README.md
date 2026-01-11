# Clothing Dashboard - Flutter Mobile App

A mobile dashboard application built with Flutter that mirrors the functionality of the React dashboard located at [/Users/s312/Desktop/start/clothing/dashboard-react](/Users/s312/Desktop/start/clothing/dashboard-react).

## Features

This Flutter mobile app includes screens for:

- Login
- Dashboard Overview
- Orders Management
- Clients Management
- Finance Tracking
- Analytics & Reports
- Team Management
- Payroll
- Position Management
- Billing & Subscriptions
- Reporting with AI
- Workflows
- Templates
- Product Management
- CRM
- Settings

## Screenshots

![Dashboard](assets/dashboard.png)
_Dashboard Overview_

![Orders](assets/orders.png)
_Orders Management_

![Team](assets/team.png)
_Team Management_

## Tech Stack

- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language
- **Provider**: State management
- **HTTP**: API communication
- **Syncfusion**: Charts and data visualization

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio or VS Code
- iOS Simulator or Android Emulator

### Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   ```

2. Navigate to the project directory:

   ```bash
   cd mobile_flutter
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # Entry point
├── providers/                # State management providers
├── screens/                  # All screen widgets
├── widgets/                  # Reusable UI components
├── services/                 # API and business logic
├── models/                   # Data models
└── utils/                    # Utility functions
```

## Development

To add new features:

1. Create a new screen in `lib/screens/`
2. Add the route in `lib/main.dart`
3. Add navigation in the bottom navigation bar

## Building for Production

```bash
# Build for Android
flutter build apk

# Build for iOS
flutter build ios
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a pull request

## License

This project is licensed under the MIT License.
# fin-mobile
