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
            const SizedBox(height: 32),
            Text(
              'EZ Saves',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bookmarks. Media. Files all in one spot.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF8C8C8C),
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
    return SizedBox(
      height: 210,
      width: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
              borderRadius: BorderRadius.circular(56),
            ),
            child: ClipPath(
              clipper: _BookmarkClipper(),
              child: Container(color: const Color(0xFFF4F4F4)),
            ),
          ),
          CustomPaint(
            size: const Size(140, 150),
            painter: _BookmarkOutlinePainter(),
          ),
        ],
      ),
    );
  }
}

class _BookmarkClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;

    return Path()
      ..moveTo(width * 0.18, 0)
      ..lineTo(width * 0.82, 0)
      ..quadraticBezierTo(width, 0, width, height * 0.18)
      ..lineTo(width, height * 0.72)
      ..quadraticBezierTo(width, height * 0.96, width * 0.72, height * 0.96)
      ..lineTo(width * 0.5, height * 0.82)
      ..lineTo(width * 0.28, height * 0.96)
      ..quadraticBezierTo(0, height * 0.96, 0, height * 0.72)
      ..lineTo(0, height * 0.18)
      ..quadraticBezierTo(0, 0, width * 0.18, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _BookmarkOutlinePainter extends CustomPainter {
  static const _outlineColor = Color(0xFF111111);

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

    final paint = Paint()
      ..color = _outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
