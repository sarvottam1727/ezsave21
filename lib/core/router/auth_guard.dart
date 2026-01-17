import 'package:ez_save/core/logging/custom_logging.dart';
import 'package:ez_save/core/router/app_paths.dart';
import 'package:ez_save/views/providers/shared_prefs_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AuthGuard {
  static String? _lastRedirect;
  static String? _lastLocation;

  static Future<String?> redirect(BuildContext context, GoRouterState state) async {
    // Get the current user directly from FirebaseAuth instead of the stream

    final currentUser = FirebaseAuth.instance.currentUser;
    final currentPath = state.matchedLocation;
    final isPublicScreen = ScreenGroups.isPublicScreen(currentPath);

    // Skip logging if we're processing the same location repeatedly
    if (_lastLocation != currentPath) {
      // Log.d('currentUser=${currentUser?.email}, isPublic=$isPublicScreen, location=$currentPath', fileName: 'AuthGuard', function: 'redirect');
      _lastLocation = currentPath;
    }

    // Check onboarding status if we have context
    try {
      final container = ProviderScope.containerOf(context);
      final sharedPrefsService = container.read(sharedPrefsRepositoryProvider);
      // final remoteConfigService = container.read(remoteConfigProvider);
      // // await remoteConfigService.initialize();

      // final update = await remoteConfigService.updateAppVersion();
      // if (update != null) {
      //   return update;
      // }

      final isOnboardingCompleted = sharedPrefsService.isOnboardingCompleted();
      // sharedPrefsService.setOnboardingCompleted(false); // TEMP: Force onboarding for testing
      String? redirectPath = AppPaths.auth.path;

      // 1. If not logged in, send them to welcome screen
      if (currentUser == null && !isPublicScreen) {
        redirectPath = AppPaths.auth.path;
      }
      // 2. If logged in and onboarding not complete, send them to onboarding screen
      else if (currentUser != null && !isOnboardingCompleted && !currentPath.startsWith('/onboarding')) {
        redirectPath = AppPaths.onboarding.path;
      }
      // 3. If logged in and onboarding complete, send them to home screen (unless already on a valid screen)
      else if (currentUser != null && isOnboardingCompleted && currentPath == AppPaths.welcome.path) {
        redirectPath = AppPaths.home.path;
      }

      // Only log and redirect if we have a different redirect than last time
      if (redirectPath != null && redirectPath != _lastRedirect) {
        _lastRedirect = redirectPath;
        Log.i('Redirecting to $redirectPath', fileName: 'AuthGuard', function: 'redirect');
        return redirectPath;
      }
    } catch (e) {
      Log.e('Error checking onboarding status', fileName: 'AuthGuard', function: 'redirect', error: e);
      // If we can't check onboarding status, send unauthenticated users to welcome
      if (currentUser == null && !isPublicScreen) {
        return AppPaths.welcome.path;
      }
    }

    // Reset last redirect if no redirect is needed
    if (_lastRedirect != null) {
      _lastRedirect = null;
      Log.d('No redirect needed', fileName: 'AuthGuard', function: 'redirect');
    }
    return null; // No redirect needed
  }
}
