import 'package:ez_save/core/logging/custom_logging.dart';
import 'package:ez_save/core/router/app_paths.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthGuard {
  static String? _lastRedirect;
  static String? _lastLocation;

  // Public routes that don't require login
  static const List<String> _publicPrefixes = [
    '/splash',
    '/onboarding',
    '/auth',
  ];

  static bool _isPublic(String path) {
    return _publicPrefixes.any((p) => path.startsWith(p));
  }

  static Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentPath = state.matchedLocation;
    final isPublicScreen = _isPublic(currentPath);

    // Reduce noisy logs
    if (_lastLocation != currentPath) {
      _lastLocation = currentPath;
    }

    String? redirectPath;

    // 1) Not logged in -> allow only public screens, otherwise go to auth
    if (currentUser == null && !isPublicScreen) {
      redirectPath = AppPaths.auth.path;
    }

    // 2) Logged in -> prevent going back to auth screens
    if (currentUser != null && currentPath.startsWith(AppPaths.auth.path)) {
      redirectPath = AppPaths.home.path;
    }

    // Only redirect if changed
    if (redirectPath != null && redirectPath != _lastRedirect) {
      _lastRedirect = redirectPath;
      Log.i('Redirecting to $redirectPath', fileName: 'AuthGuard', function: 'redirect');
      return redirectPath;
    }

    // Reset last redirect if no redirect needed
    if (_lastRedirect != null) {
      _lastRedirect = null;
      Log.d('No redirect needed', fileName: 'AuthGuard', function: 'redirect');
    }

    return null;
  }
}
