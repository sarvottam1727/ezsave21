import 'package:ez_save/core/router/app_paths.dart';
import 'package:ez_save/core/router/auth_guard.dart';
import 'package:ez_save/core/router/page_transition.dart';
import 'package:ez_save/views/providers/navigation_provider.dart';
import 'package:ez_save/views/views/auth/auth_screen.dart';
import 'package:ez_save/views/views/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ Create these files in Step 2
import 'package:ez_save/views/views/onboarding/splash_screen.dart';
import 'package:ez_save/views/views/onboarding/onboarding_screen.dart';

// Global navigator key for context-independent navigation
final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'AppNavigator');

/// Helper function to extract arguments from GoRouterState
T? getArg<T>(GoRouterState state, String key, [T? defaultValue]) {
  final args = state.originalExtra as Map<String, dynamic>?;
  return (args?[key] as T?) ?? defaultValue;
}

/// Initialize the navigation system - call this in main()
void initializeNavigation() {
  NavigationNotifier.setNavigatorKey(navigatorKey);
}

final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,

  // ✅ Splash is "/" (welcome)
  initialLocation: FirebaseAuth.instance.currentUser != null
      ? AppPaths.home.path
      : AppPaths.welcome.path,

  redirect: AuthGuard.redirect,

  routes: [
    // ✅ Splash ("/")
    GoRouteExtension.createRoute(
      path: AppPaths.welcome,
      name: AppRouteNames.welcome,
      widgetBuilder: (_) => const SplashScreen(),
      transitionDirection: TransitionDirection.horizontal, // keep existing enum
    ),

    // ✅ Onboarding
    GoRouteExtension.createRoute(
      path: AppPaths.onboarding,
      name: AppRouteNames.onboarding,
      widgetBuilder: (_) => const OnboardingScreen(),
    ),

    // ✅ Auth
    GoRouteExtension.createRoute(
      path: AppPaths.auth,
      name: AppRouteNames.authentication,
      widgetBuilder: (_) => const AuthenticationScreen(),
    ),

    // ✅ Home
    GoRouteExtension.createRoute(
      path: AppPaths.home,
      name: AppRouteNames.home,
      widgetBuilder: (_) => const HomeView(),
    ),
  ],
  errorBuilder: (context, state) => const PageNotFound(),
);

extension GoRouteExtension on GoRoute {
  static GoRoute createRoute({
    required AppPaths path,
    required String name,
    required Widget Function(GoRouterState state) widgetBuilder,
    List<GoRoute> routes = const [],
    TransitionDirection transitionDirection = TransitionDirection.horizontal,
  }) {
    return GoRoute(
      path: path.path,
      name: name,
      pageBuilder: (context, state) => PageTransitions.buildTransitionPage(
        child: widgetBuilder(state),
        name: name,
        pageKey: state.pageKey,
        transitionDirection: transitionDirection,
        transitionDurationInSeconds: state.transitionDurationInSeconds,
      ),
      routes: routes,
    );
  }
}

class PageNotFound extends StatelessWidget {
  const PageNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppPaths.home.path),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
