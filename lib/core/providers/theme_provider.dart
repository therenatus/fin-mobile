import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider with ChangeNotifier {
  final StorageService _storage;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider(this._storage) {
    _init();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _init() async {
    final themeModeStr = await _storage.getThemeMode();
    _themeMode = _parseThemeMode(themeModeStr);
    notifyListeners();
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
    _themeMode = mode;
    final modeStr = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await _storage.saveThemeMode(modeStr);
    notifyListeners();
  }
}
