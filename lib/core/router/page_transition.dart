import 'package:ez_save/core/router/app_paths.dart';
import 'package:ez_save/views/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum TransitionDirection { horizontal, vertical, horizontalReverse, verticalReverse }

enum NavigationType {
  push, // Keeps current screen in stack
  pushReplacement, // Replaces current screen
}

class PageTransitions {
  /// Simple navigation with custom transitions for GoRouter
  static Page<T> buildTransitionPage<T extends Object?>({
    required Widget child,
    required String name,
    TransitionDirection transitionDirection = TransitionDirection.horizontal,
    int transitionDurationInSeconds = 1000,
    Color? fillColor,
    LocalKey? pageKey, // Supply GoRouterState.pageKey to avoid duplicate keys
  }) {
    return CustomTransitionPage<T>(
      key: pageKey ?? ValueKey(name),
      transitionDuration: Duration(milliseconds: transitionDurationInSeconds),
      reverseTransitionDuration: Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(parent: animation, curve: Interval(0, 1));

        final theme = Theme.of(context);
        final backgroundColor = fillColor ?? theme.scaffoldBackgroundColor;

        SharedAxisTransitionType transitionType;

        switch (transitionDirection) {
          case TransitionDirection.vertical:
          case TransitionDirection.verticalReverse:
            transitionType = SharedAxisTransitionType.vertical;
            break;
          case TransitionDirection.horizontal:
          case TransitionDirection.horizontalReverse:
            transitionType = SharedAxisTransitionType.horizontal;
            break;
        }

        return SharedAxisTransition(animation: curvedAnimation, transitionType: transitionType, secondaryAnimation: secondaryAnimation, fillColor: backgroundColor, child: child);
      },
      child: child,
    );
  }
}

/// Extension to make Riverpod navigation easier from any WidgetRef
extension RiverpodNavigation on WidgetRef {
  /// Navigate to a route using enum with custom transition and debounce protection
  void navigateToScreen(
    AppPaths routePath, {
    TransitionDirection transitionDirection = TransitionDirection.horizontal,
    int transitionDurationInSeconds = 1000,
    NavigationType navigationType = NavigationType.push,
    Object? extra,
    Duration? debounceDuration,
  }) {
    read(navigationProvider.notifier).navigateToScreen(
      routePath,
      transitionDirection: transitionDirection,
      transitionDurationInSeconds: transitionDurationInSeconds,
      navigationType: navigationType,
      extra: extra,
      debounceDuration: debounceDuration,
    );
  }

  /// Navigate using string path (for custom routes not in AppPaths)
  void navigateToScreenByPath(
    String routePath, {
    TransitionDirection transitionDirection = TransitionDirection.horizontal,
    int transitionDurationInSeconds = 1000,
    NavigationType navigationType = NavigationType.push,
    Object? extra,
    Duration? debounceDuration,
  }) {
    read(navigationProvider.notifier).navigateToScreenByPath(
      routePath,
      transitionDirection: transitionDirection,
      transitionDurationInSeconds: transitionDurationInSeconds,
      navigationType: navigationType,
      extra: extra,
      debounceDuration: debounceDuration,
    );
  }

  /// Go back with protection
  void goBack() {
    read(navigationProvider.notifier).goBack();
  }

  /// Check if can go back
  bool get canGoBack {
    return read(navigationProvider.notifier).canGoBack();
  }

  /// Get navigation state
  NavigationState get navigationState {
    return read(navigationProvider);
  }

  /// Check if currently navigating
  bool get isNavigating {
    return read(isNavigatingProvider);
  }
}

/// Legacy extension for BuildContext (still requires ref access)
/// @deprecated Use RiverpodNavigation extension with WidgetRef instead
extension SimpleNavigation on BuildContext {
  /// Navigate to a route using enum with custom transition
  /// Note: This requires access to WidgetRef. Use RiverpodNavigation extension instead.
  @Deprecated('Use ref.navigateToScreen() instead')
  void navigateToScreen(
    AppPaths routePath, {
    TransitionDirection transitionDirection = TransitionDirection.horizontal,
    int transitionDurationInSeconds = 1000,
    NavigationType navigationType = NavigationType.push,
    Object? extra,
  }) {
    final transitionData = {'transitionDirection': transitionDirection, 'transitionDurationInSeconds': transitionDurationInSeconds, if (extra != null) 'originalExtra': extra};

    if (navigationType == NavigationType.push) {
      push(routePath.path, extra: transitionData);
    } else {
      pushReplacement(routePath.path, extra: transitionData);
    }
  }
}

/// Helper extension to extract transition data from GoRouterState
extension GoRouterStateTransition on GoRouterState {
  TransitionDirection get transitionDirection {
    if (extra is Map) {
      final extraMap = extra as Map;
      final direction = extraMap['transitionDirection'];
      if (direction is TransitionDirection) {
        return direction;
      }
    }
    return TransitionDirection.horizontal;
  }

  int get transitionDurationInSeconds {
    if (extra is Map) {
      final extraMap = extra as Map;
      return extraMap['transitionDurationInSeconds'] as int? ?? 1000;
    }
    return 1000;
  }

  Object? get originalExtra {
    if (extra is Map) {
      final extraMap = extra as Map;
      return extraMap['originalExtra'];
    }
    return extra;
  }
}
