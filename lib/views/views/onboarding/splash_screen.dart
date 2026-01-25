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
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _SplashLogo(),
            const SizedBox(height: 28),
            Text(
              'EZ Saves',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookmarks. Media. Files all in one spot.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF8D8D8D),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(180, 190),
      painter: _BookmarkPainter(),
    );
  }
}

class _BookmarkPainter extends CustomPainter {
  static const _fillColor = Color(0xFFF4F4F4);
  static const _shadowColor = Color(0x1A000000);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final path = Path()
      ..moveTo(width * 0.2, 0)
      ..lineTo(width * 0.8, 0)
      ..quadraticBezierTo(width, 0, width, height * 0.2)
      ..lineTo(width, height * 0.7)
      ..quadraticBezierTo(width, height * 0.92, width * 0.7, height * 0.93)
      ..lineTo(width * 0.5, height * 0.78)
      ..lineTo(width * 0.3, height * 0.93)
      ..quadraticBezierTo(0, height * 0.92, 0, height * 0.7)
      ..lineTo(0, height * 0.2)
      ..quadraticBezierTo(0, 0, width * 0.2, 0)
      ..close();

    canvas.drawShadow(path, _shadowColor, 18, false);
    final paint = Paint()..color = _fillColor;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
