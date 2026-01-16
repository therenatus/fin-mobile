import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:clothing_dashboard/core/providers/theme_provider.dart';
import '../../helpers/mock_services.mocks.dart';

void main() {
  late MockStorageService mockStorage;
  late ThemeProvider provider;

  setUp(() {
    mockStorage = MockStorageService();
  });

  group('ThemeProvider', () {
    test('initializes with system theme mode by default', () async {
      when(mockStorage.getThemeMode()).thenAnswer((_) async => 'system');

      provider = ThemeProvider(mockStorage);

      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.themeMode, equals(ThemeMode.system));
    });

    test('initializes with light theme mode from storage', () async {
      when(mockStorage.getThemeMode()).thenAnswer((_) async => 'light');

      provider = ThemeProvider(mockStorage);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.themeMode, equals(ThemeMode.light));
    });

    test('initializes with dark theme mode from storage', () async {
      when(mockStorage.getThemeMode()).thenAnswer((_) async => 'dark');

      provider = ThemeProvider(mockStorage);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.themeMode, equals(ThemeMode.dark));
    });

    test('defaults to system theme for unknown mode', () async {
      when(mockStorage.getThemeMode()).thenAnswer((_) async => 'unknown');

      provider = ThemeProvider(mockStorage);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.themeMode, equals(ThemeMode.system));
    });

    test('setThemeMode updates to light mode and saves', () async {
      when(mockStorage.getThemeMode()).thenAnswer((_) async => 'system');
      when(mockStorage.saveThemeMode(any)).thenAnswer((_) async {});

      provider = ThemeProvider(mockStorage);
      await Future.delayed(const Duration(milliseconds: 50));

      await provider.setThemeMode(ThemeMode.light);

      expect(provider.themeMode, equals(ThemeMode.light));
      verify(mockStorage.saveThemeMode('light')).called(1);
    });

    test('setThemeMode updates to dark mode and saves', () async {
      when(mockStorage.getThemeMode()).thenAnswer((_) async => 'system');
      when(mockStorage.saveThemeMode(any)).thenAnswer((_) async {});

      provider = ThemeProvider(mockStorage);
      await Future.delayed(const Duration(milliseconds: 50));

      await provider.setThemeMode(ThemeMode.dark);

      expect(provider.themeMode, equals(ThemeMode.dark));
      verify(mockStorage.saveThemeMode('dark')).called(1);
    });

    test('setThemeMode updates to system mode and saves', () async {
      when(mockStorage.getThemeMode()).thenAnswer((_) async => 'light');
      when(mockStorage.saveThemeMode(any)).thenAnswer((_) async {});

      provider = ThemeProvider(mockStorage);
      await Future.delayed(const Duration(milliseconds: 50));

      await provider.setThemeMode(ThemeMode.system);

      expect(provider.themeMode, equals(ThemeMode.system));
      verify(mockStorage.saveThemeMode('system')).called(1);
    });

    test('notifies listeners when theme mode changes', () async {
      when(mockStorage.getThemeMode()).thenAnswer((_) async => 'system');
      when(mockStorage.saveThemeMode(any)).thenAnswer((_) async {});

      provider = ThemeProvider(mockStorage);
      await Future.delayed(const Duration(milliseconds: 50));

      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setThemeMode(ThemeMode.dark);

      expect(notifyCount, greaterThan(0));
    });

    test('notifies listeners on initialization', () async {
      when(mockStorage.getThemeMode()).thenAnswer((_) async => 'light');

      provider = ThemeProvider(mockStorage);

      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifyCount, greaterThan(0));
    });
  });
}
