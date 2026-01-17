import 'package:ez_save/core/services/shared_prefs_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

final sharedPrefsRepositoryProvider = Provider<SharedPrefsService>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsService(sharedPrefs);
});
