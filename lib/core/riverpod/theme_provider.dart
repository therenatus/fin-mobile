import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_provider.dart';

/// Theme state managed by Riverpod.
/// Replaces the old ThemeProvider (ChangeNotifier).
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _init();
    return ThemeMode.system;
  }

  Future<void> _init() async {
    final storage = ref.read(storageServiceProvider);
    final themeModeStr = await storage.getThemeMode();
    state = _parseThemeMode(themeModeStr);
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final modeStr = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    final storage = ref.read(storageServiceProvider);
    await storage.saveThemeMode(modeStr);
  }
}

/// Provider for theme mode.
final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
