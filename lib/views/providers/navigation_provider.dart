import 'dart:async';
import 'package:ez_save/core/logging/custom_logging.dart';
import 'package:ez_save/core/router/app_paths.dart';
import 'package:ez_save/core/router/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Navigation state model
class NavigationState {
  final String currentRoute;
  final bool isNavigating;
  final String? lastNavigationRoute;
  final DateTime? lastNavigationTime;
  final String? error;

  const NavigationState({required this.currentRoute, this.isNavigating = false, this.lastNavigationRoute, this.lastNavigationTime, this.error});

  NavigationState copyWith({String? currentRoute, bool? isNavigating, String? lastNavigationRoute, DateTime? lastNavigationTime, String? error}) {
    return NavigationState(
      currentRoute: currentRoute ?? this.currentRoute,
      isNavigating: isNavigating ?? this.isNavigating,
      lastNavigationRoute: lastNavigationRoute ?? this.lastNavigationRoute,
      lastNavigationTime: lastNavigationTime ?? this.lastNavigationTime,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'NavigationState(currentRoute: $currentRoute, isNavigating: $isNavigating, lastRoute: $lastNavigationRoute)';
  }
}

/// Navigation provider that manages navigation state and prevents multiple pushes
class NavigationNotifier extends Notifier<NavigationState> {
  static const String _fileName = 'NavigationProvider';

  // Debounce configuration
  static const Duration defaultDebounceDuration = Duration(milliseconds: 300);
  Timer? _debounceTimer;

  // Global navigator key (will be set from app_router.dart)
  static GlobalKey<NavigatorState>? _navigatorKey;

  @override
  NavigationState build() {
    return const NavigationState(currentRoute: '/');
  }

  /// Set the global navigator key for context-independent navigation
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  /// Get the GoRouter instance from the navigator key
  GoRouter? get _router {
    final context = _navigatorKey?.currentContext;
    if (context != null) {
      return GoRouter.of(context);
    }
    return null;
  }

  /// Update current route (called from router)
  void updateCurrentRoute(String route) {
    if (state.currentRoute != route) {
      Log.d('Route updated: ${state.currentRoute} -> $route', fileName: _fileName, function: 'updateCurrentRoute');
      state = state.copyWith(currentRoute: route);
    }
  }

  /// Navigate to screen with debounce protection
  void navigateToScreen(
    AppPaths routePath, {
    TransitionDirection transitionDirection = TransitionDirection.horizontal,
    int transitionDurationInSeconds = 1000,
    NavigationType navigationType = NavigationType.pushReplacement,
    Object? extra,
    Duration? debounceDuration,
  }) {
    _navigateWithDebounce(
      routePath.path,
      routePath.name,
      transitionDirection: transitionDirection,
      transitionDurationInSeconds: transitionDurationInSeconds,
      navigationType: navigationType,
      extra: extra,
      debounceDuration: debounceDuration ?? defaultDebounceDuration,
    );
  }

  /// Navigate using string path (for custom routes)
  void navigateToScreenByPath(
    String routePath, {
    TransitionDirection transitionDirection = TransitionDirection.horizontal,
    int transitionDurationInSeconds = 1000,
    NavigationType navigationType = NavigationType.pushReplacement,
    Object? extra,
    Duration? debounceDuration,
  }) {
    _navigateWithDebounce(
      routePath,
      routePath,
      transitionDirection: transitionDirection,
      transitionDurationInSeconds: transitionDurationInSeconds,
      navigationType: navigationType,
      extra: extra,
      debounceDuration: debounceDuration ?? defaultDebounceDuration,
    );
  }

  /// Internal method to handle debounced navigation
  void _navigateWithDebounce(
    String routePath,
    String routeName, {
    required TransitionDirection transitionDirection,
    required int transitionDurationInSeconds,
    required NavigationType navigationType,
    Object? extra,
    required Duration debounceDuration,
  }) {
    // Check if we're already navigating to prevent rapid calls
    if (state.isNavigating) {
      Log.w('Navigation ignored - already navigating', fileName: _fileName, function: '_navigateWithDebounce');
      return;
    }

    // Check if this is a duplicate navigation within debounce window
    if (_isDuplicateNavigation(routePath, debounceDuration)) {
      Log.w('Duplicate navigation ignored: $routePath', fileName: _fileName, function: '_navigateWithDebounce');
      return;
    }

    // Check if we're already on the target route (unless it's a push)
    if (navigationType == NavigationType.pushReplacement && state.currentRoute == routePath) {
      Log.w('Navigation ignored - already on route: $routePath', fileName: _fileName, function: '_navigateWithDebounce');
      return;
    }

    // Cancel any existing debounce timer
    _debounceTimer?.cancel();

    // Set navigating state
    state = state.copyWith(isNavigating: true, error: null);

    // Start debounce timer
    _debounceTimer = Timer(debounceDuration, () {
      _performNavigation(routePath, routeName, transitionDirection: transitionDirection, transitionDurationInSeconds: transitionDurationInSeconds, navigationType: navigationType, extra: extra);
    });

    Log.i('Navigation queued: $routePath (type: ${navigationType.name}, transition: ${transitionDirection.name})', fileName: _fileName, function: '_navigateWithDebounce');
  }

  /// Check if this is a duplicate navigation within the debounce window
  bool _isDuplicateNavigation(String routePath, Duration debounceDuration) {
    final lastTime = state.lastNavigationTime;
    final lastRoute = state.lastNavigationRoute;

    if (lastTime == null || lastRoute == null) return false;

    final timeSinceLastNavigation = DateTime.now().difference(lastTime);
    return lastRoute == routePath && timeSinceLastNavigation < debounceDuration;
  }

  /// Perform the actual navigation
  void _performNavigation(
    String routePath,
    String routeName, {
    required TransitionDirection transitionDirection,
    required int transitionDurationInSeconds,
    required NavigationType navigationType,
    Object? extra,
  }) {
    try {
      final router = _router;
      if (router == null) {
        throw Exception('Router not available - navigator key not set');
      }

      final transitionData = {'transitionDirection': transitionDirection, 'transitionDurationInSeconds': transitionDurationInSeconds, if (extra != null) 'originalExtra': extra};

      // Perform navigation
      if (navigationType == NavigationType.push) {
        router.push(routePath, extra: transitionData);
        Log.i('Pushed to: $routePath', fileName: _fileName, function: '_performNavigation');
      } else {
        router.pushReplacement(routePath, extra: transitionData);
        Log.i('Replaced with: $routePath', fileName: _fileName, function: '_performNavigation');
      }

      // Update state
      state = state.copyWith(isNavigating: false, lastNavigationRoute: routePath, lastNavigationTime: DateTime.now(), error: null);
    } catch (e) {
      Log.e('Navigation failed: $routePath', fileName: _fileName, function: '_performNavigation', error: e);
      state = state.copyWith(isNavigating: false, error: e.toString());
    }
  }

  /// Go back with basic pop
  void goBack() {
    if (state.isNavigating) {
      Log.w('Go back ignored - already navigating', fileName: _fileName, function: 'goBack');
      return;
    }

    try {
      final router = _router;
      if (router == null) {
        throw Exception('Router not available - navigator key not set');
      }

      if (router.canPop()) {
        state = state.copyWith(isNavigating: true);
        router.pop();
        Log.i('Navigated back', fileName: _fileName, function: 'goBack');

        // Reset navigating state after a short delay
        Timer(const Duration(milliseconds: 100), () {
          state = state.copyWith(isNavigating: false);
        });
      } else {
        Log.w('Cannot go back - no previous route', fileName: _fileName, function: 'goBack');
        // Fallback to welcome screen
        navigateToScreen(AppPaths.welcome);
      }
    } catch (e) {
      Log.e('Go back failed', fileName: _fileName, function: 'goBack', error: e);
      state = state.copyWith(isNavigating: false, error: e.toString());
    }
  }

  /// Check if we can go back
  bool canGoBack() {
    return _router?.canPop() ?? false;
  }

  /// Get current route name
  String? getCurrentRouteName() {
    final context = _navigatorKey?.currentContext;
    if (context != null) {
      try {
        return GoRouterState.of(context).name;
      } catch (e) {
        Log.w('Could not get current route name: $e', fileName: _fileName, function: 'getCurrentRouteName');
      }
    }
    return null;
  }

  /// Clear any error state
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}

/// Provider for navigation state and service
final navigationProvider = NotifierProvider<NavigationNotifier, NavigationState>(() {
  return NavigationNotifier();
});

/// Convenience providers
final isNavigatingProvider = Provider<bool>((ref) {
  return ref.watch(navigationProvider).isNavigating;
});

final currentRouteProvider = Provider<String>((ref) {
  return ref.watch(navigationProvider).currentRoute;
});

final navigationErrorProvider = Provider<String?>((ref) {
  return ref.watch(navigationProvider).error;
});

/// Navigation service for easy access
class NavigationService {
  static NavigationNotifier? _instance;

  /// Get the navigation service instance
  static NavigationNotifier getInstance(WidgetRef ref) {
    _instance = ref.read(navigationProvider.notifier);
    return _instance!;
  }

  /// Quick navigation methods (still require ref from widget)
  static void toHome(WidgetRef ref, {TransitionDirection? direction}) {
    getInstance(ref).navigateToScreen(AppPaths.home, transitionDirection: direction ?? TransitionDirection.horizontal);
  }

  static void toAuth(WidgetRef ref, {TransitionDirection? direction}) {
    getInstance(ref).navigateToScreen(AppPaths.auth, transitionDirection: direction ?? TransitionDirection.horizontal);
  }

  static void toWelcome(WidgetRef ref, {TransitionDirection? direction}) {
    getInstance(ref).navigateToScreen(AppPaths.welcome, transitionDirection: direction ?? TransitionDirection.vertical);
  }
}

/// Bottom navigation bar index notifier
class BottomNavigationIndexNotifier extends Notifier<int> {
  @override
  int build() {
    return 0; // Default to first tab (Home)
  }

  void setIndex(int index) {
    state = index;
  }
}

/// Provider for bottom navigation bar selected index
final bottomNavigationIndexProvider = NotifierProvider<BottomNavigationIndexNotifier, int>(() {
  return BottomNavigationIndexNotifier();
});
