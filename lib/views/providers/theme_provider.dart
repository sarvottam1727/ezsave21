import 'package:ez_save/views/providers/shared_prefs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/services/shared_prefs_service.dart';

enum AppThemeMode { light, dark, system }

class ThemeState {
  final AppThemeMode themeMode;
  final Color seedColor;

  const ThemeState({this.themeMode = AppThemeMode.system, this.seedColor = const Color(0xFF6750A4)});

  ThemeState copyWith({AppThemeMode? themeMode, Color? seedColor}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode, seedColor: seedColor ?? this.seedColor);
  }

  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  final SharedPrefsService _prefs;

  ThemeNotifier(this._prefs) : super(const ThemeState()) {
    _loadTheme();
  }

  void _loadTheme() {
    final modeString = _prefs.getThemeMode();
    final colorValue = _prefs.getThemeColor();

    final mode = AppThemeMode.values.firstWhere((e) => e.name == modeString, orElse: () => AppThemeMode.system);

    state = ThemeState(themeMode: mode, seedColor: Color(colorValue));
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await _prefs.setThemeMode(mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setSeedColor(Color color) async {
    await _prefs.setThemeColor(color.value);
    state = state.copyWith(seedColor: color);
  }

  void toggleTheme() {
    final newMode = state.themeMode == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
    setThemeMode(newMode);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final prefs = ref.watch(sharedPrefsRepositoryProvider);
  return ThemeNotifier(prefs);
});
