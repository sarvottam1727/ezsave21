enum AppPaths {
  welcome('/'),
  chooseLanguage('/choose_language'),
  termsOfUse('/terms_of_use'),
  privacyPolicy('/privacy_policy'),
  auth('/auth'),
  onboarding('/onboarding'),
  home("/home");

  const AppPaths(this.path);

  final String path;

  @override
  String toString() => path;
}

class AppRouteNames {
  static const String welcome = 'welcome';
  static const String authentication = 'authentication';
  static const String onboarding = 'onboarding';

  static const String home = 'home';
  static const String forceUpdate = 'force_update';
  static const String maintance = 'maintance';
  static const String termsOfUse = 'terms_of_use';
  static const String privacyPolicy = 'privacy_policy';
}

/// Screen groups for auth management
class ScreenGroups {
  /// Screens accessible without authentication (when not logged in)
  static const Set<String> publicScreens = {'/', '/auth', '/terms_of_use', '/privacy_policy'};

  /// Screens that require authentication (when logged in, users can access both public and these screens)
  static const Set<String> protectedScreens = {'/home'};

  /// Check if a screen requires authentication
  static bool isProtectedScreen(String path) => protectedScreens.contains(path);

  /// Check if a screen is publicly accessible
  static bool isPublicScreen(String path) => publicScreens.contains(path);
}
