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
/// Screen groups for auth management
class ScreenGroups {
  /// Screens accessible without authentication (when not logged in)
  static const Set<String> publicScreens = {
    '/',
    '/onboarding',
    '/auth',
    '/terms_of_use',
    '/privacy_policy',
    '/choose_language',
  };

  /// Screens that require authentication
  static const Set<String> protectedScreens = {'/home'};

  static bool isProtectedScreen(String path) => protectedScreens.contains(path);
  static bool isPublicScreen(String path) => publicScreens.contains(path);
}
