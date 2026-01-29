import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ez_save/core/router/app_paths.dart';
import 'package:ez_save/core/router/app_router.dart'; // if AppRouteNames is here



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // ⚠️ IMPORTANT: These must match EXACT filename case in /assets/
  static const String _bookmarkAsset = 'assets/images/splash/bookmark.png';
  static const String _logoNameAsset = 'assets/images/splash/logo_name.png';

  void _goNext() {
    if (!mounted) return;
    try {
      context.goNamed(AppRouteNames.onboarding);
    } catch (_) {
      context.go(AppPaths.onboarding.path);
    }
  }

  @override
  void didChangeDependencies() {
    // Precache (no flicker)
    precacheImage(const AssetImage(_bookmarkAsset), context);
    precacheImage(const AssetImage(_logoNameAsset), context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // Figma baseline: iPhone frame width ~428
    final size = MediaQuery.of(context).size;
    final scale = (size.width / 428.0).clamp(0.85, 1.05);

    // ✅ Figma exact numbers from your screenshot
    final bookmarkW = 372.0 * scale;
    final bookmarkH = 372.0 * scale;
    final bookmarkTop = 217.0 * scale;
    final bookmarkLeft = 29.0 * scale; // from Figma

    // Logo + tagline placement (tuned to match Figma composition)
    final logoTop = (bookmarkTop + bookmarkH) - (22.0 * scale); // slight overlap feel
    final logoW = 300.0 * scale;
    final logoH = 40.0 * scale;

    final taglineTop = logoTop + logoH + (6.0 * scale);
    final taglineFontSize = 12.5 * scale;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goNext, // ✅ Navigation ONLY after click/tap
        child: Stack(
          children: [
            // Bookmark image (exact position/size)
            Positioned(
              top: bookmarkTop,
              left: bookmarkLeft,
              width: bookmarkW,
              height: bookmarkH,
              child: Image.asset(
                _bookmarkAsset,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stack) {
                  // If you see this icon => asset path/case mismatch
                  return const Center(
                    child: Icon(Icons.broken_image_outlined, size: 48),
                  );
                },
              ),
            ),

            // Logo name (centered)
            Positioned(
              top: logoTop,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  _logoNameAsset,
                  width: logoW,
                  height: logoH,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stack) {
                    return const Icon(Icons.broken_image_outlined, size: 28);
                  },
                ),
              ),
            ),

            // Tagline (centered)
            Positioned(
              top: taglineTop,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Bookmarks, Media, files all in one spot.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: taglineFontSize,
                    height: 1.25,
                    color: Colors.black.withOpacity(0.55),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            // Optional tiny home-indicator-like hint (subtle)
            Positioned(
              bottom: 18.0 * scale,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 120.0 * scale,
                  height: 4.0 * scale,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
