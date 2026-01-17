import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SharedPrefsService {
  final SharedPreferences _prefs;

  SharedPrefsService(this._prefs);

  // Theme
  static const String _themeModeKey = 'theme_mode';
  static const String _themeColorKey = 'theme_color';

  Future<bool> setThemeMode(String mode) => _prefs.setString(_themeModeKey, mode);
  String getThemeMode() => _prefs.getString(_themeModeKey) ?? 'system';

  Future<bool> setThemeColor(int colorValue) => _prefs.setInt(_themeColorKey, colorValue);
  int getThemeColor() => _prefs.getInt(_themeColorKey) ?? 0xFF6750A4; // Default purple

  // Auth
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  Future<bool> setIsLoggedIn(bool value) => _prefs.setBool(_isLoggedInKey, value);
  bool getIsLoggedIn() => _prefs.getBool(_isLoggedInKey) ?? false;

  Future<bool> setUserId(String? userId) {
    if (userId == null) {
      return _prefs.remove(_userIdKey);
    }
    return _prefs.setString(_userIdKey, userId);
  }

  String? getUserId() => _prefs.getString(_userIdKey);

  Future<bool> setOnboardingCompleted(bool value) => _prefs.setBool(_onboardingCompletedKey, value);
  bool isOnboardingCompleted() => _prefs.getBool(_onboardingCompletedKey) ?? false;

  // Generic methods
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);
  double? getDouble(String key) => _prefs.getDouble(key);

  Future<bool> setStringList(String key, List<String> value) => _prefs.setStringList(key, value);
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
}
