import 'package:ez_save/core/router/app_paths.dart';
import 'package:ez_save/views/providers/shared_prefs_provider.dart';
import 'package:ez_save/views/views/onboarding/widgets/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _controller;

  int _index = 0;

  // Prevent double navigation / double writes
  bool _finishing = false;

  // Prevent re-precaching multiple times (didChangeDependencies can run again)
  bool _precacheDone = false;

  static const String _statusBar = 'assets/images/splash/status_bar.png';
  static const String _bottomBg = 'assets/images/splash/bottom_sheet_bg.png';
  static const String _phoneFrame = 'assets/images/splash/phone_frame.png';

  static const List<_PageAssets> _pages = [
    _PageAssets(
      phone: 'assets/images/splash/screen1.png',
      card: 'assets/images/splash/vp1_card.png',
    ),
    _PageAssets(
      phone: 'assets/images/splash/phone_frame.png',
      card: 'assets/images/splash/vp2_card.png',
    ),
    _PageAssets(
      phone: 'assets/images/splash/phone_frame.png',
      card: 'assets/images/splash/vp3_card.png',
    ),
    _PageAssets(
      phone: 'assets/images/splash/phone_frame.png',
      card: 'assets/images/splash/vp4_card.png',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Keep neighbor pages alive to reduce jank during swipe
    _controller = PageController(
      initialPage: 0,
      viewportFraction: 1.0,
      keepPage: true,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ run precache only once per widget lifetime
    if (_precacheDone) return;
    _precacheDone = true;

    // ✅ Precache all assets used in onboarding (zero flicker)
    // Note: caching too many huge images can increase memory.
    // This is ok for 4 pages, but keep assets optimized (compressed PNG/WebP).
    for (final p in _pages) {
      precacheImage(AssetImage(p.phone), context);
      precacheImage(AssetImage(p.card), context);
    }
    precacheImage(const AssetImage(_statusBar), context);
    precacheImage(const AssetImage(_bottomBg), context);

    // If used inside OnboardingPage (not shown), precache it too:
    precacheImage(const AssetImage(_phoneFrame), context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_finishing) return; // ✅ prevent double call
    _finishing = true;

    try {
      final prefs = ref.read(sharedPrefsRepositoryProvider);
      await prefs.setOnboardingCompleted(true);
    } catch (_) {
      // ignore write failures, still allow navigation
    }

    if (!mounted) return;
    context.go(AppPaths.auth.path);
  }

  void _skip() => _finish();

  void _continue() {
    final lastIndex = _pages.length - 1;

    if (_index < lastIndex) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280), // slightly snappier
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _onPageChanged(int i) {
    if (i == _index) return; // ✅ avoid redundant rebuild
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: _pages.length,
      physics: const BouncingScrollPhysics(),
      onPageChanged: _onPageChanged,
      itemBuilder: (context, i) {
        final p = _pages[i];

        // RepaintBoundary is fine, but only helps if the child is complex.
        // Keep it, but don’t nest too many.
        return RepaintBoundary(
          child: OnboardingPage(
            phoneAsset: p.phone,
            cardOverlay: p.card,
            statusBar: _statusBar,

            // ✅ tappable actions
            onSkip: _skip,
            onContinue: _continue,

            // ✅ indicator values
            index: _index,
            total: _pages.length,
          ),
        );
      },
    );
  }
}

class _PageAssets {
  final String phone;
  final String card;
  const _PageAssets({required this.phone, required this.card});
}
