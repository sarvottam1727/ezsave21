import 'package:ez_save/core/router/app_paths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Simple splash delay (AuthGuard will redirect if needed)
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      context.go(AppPaths.onboarding.path); // temporary for UI work
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.savings_outlined,
                size: 84, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'EZ Save',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
