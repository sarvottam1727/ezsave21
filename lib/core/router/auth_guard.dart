import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'app_paths.dart';

class AuthGuard {
  static String? redirect(BuildContext context, GoRouterState state) {
    // ✅ Extra safety: if Firebase isn't ready for some reason, don't crash.
    bool loggedIn = false;
    try {
      loggedIn = FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      loggedIn = false;
    }

    final loc = state.matchedLocation;

    final isSplash = loc == AppPaths.splash.path;
    final isOnboarding = loc == AppPaths.onboarding.path;
    final isAuth = loc == AppPaths.auth.path;

    // ✅ Allow these always (so splash can show + onboarding/auth can work)
    if (isSplash || isOnboarding || isAuth) return null;

    // ✅ If not logged in, send everything else to splash (which then routes)
    if (!loggedIn) return AppPaths.splash.path;

    // ✅ Logged in -> allow normal navigation
    return null;
  }
}
