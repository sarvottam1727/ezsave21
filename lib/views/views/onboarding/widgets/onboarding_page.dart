import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.phoneAsset,
    required this.cardOverlay,
    required this.statusBar,
    required this.onSkip,
    required this.onContinue,
    this.index,
    this.total,
    this.paginationDotsAsset,

    // ✅ Provide the card aspect ratio to avoid runtime image resolving.
    // If your export is 428w x 451h => 428/451
    this.cardAspectRatio = 428 / 451,
  });

  final String phoneAsset;
  final String cardOverlay;
  final String statusBar;

  final VoidCallback onSkip;
  final VoidCallback onContinue;

  final int? index;
  final int? total;
  final String? paginationDotsAsset;

  final double cardAspectRatio;

  static const Color _bg = Color(0xFFF7F7F7);
  static const double _figmaW = 428.0;

  // Tap-zones relative to card png
  static const _RelRect _skipRect =
      _RelRect(left: 0.17, top: 0.73, width: 0.16, height: 0.14);

  static const _RelRect _continueRect =
      _RelRect(left: 0.56, top: 0.69, width: 0.34, height: 0.18);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final paddingTop = mq.padding.top;

    // ✅ one scale value for pixel consistency
    final s = (size.width / _figmaW).clamp(0.85, 1.20);

    final phoneTop = (paddingTop + 70) * s;
    final phoneWidth = 360 * s;
    final cardWidth = _figmaW * s;
    final cardHeight = cardWidth / cardAspectRatio;

    // ✅ decode hint sizes (reduces decode time + memory for large images)
    final devicePixelRatio = mq.devicePixelRatio;
    int? cw(double logicalW) => (logicalW * devicePixelRatio).round();
    int? ch(double logicalH) => (logicalH * devicePixelRatio).round();

    return Stack(
      children: [
        const ColoredBox(color: _bg),

        // Status bar (static) -> keep out of repaints
        Positioned(
          top: paddingTop + 8 * s,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: RepaintBoundary(
              child: Image.asset(
                statusBar,
                height: 22 * s,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.low,
                cacheHeight: ch(22 * s),
              ),
            ),
          ),
        ),

        // Pagination dots (small, cheap)
        Positioned(
          top: paddingTop + 34 * s,
          left: 0,
          right: 0,
          child: Center(
            child: _PaginationDots(
              index: index,
              total: total,
              asset: paginationDotsAsset,
            ),
          ),
        ),

        // Phone mock (expensive image) -> isolate in RepaintBoundary
        Positioned(
          top: phoneTop,
          left: 0,
          right: 0,
          child: Center(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: Image.asset(
                  phoneAsset,
                  width: phoneWidth,
                  fit: BoxFit.contain,
                  // High quality is expensive; use medium/low unless you see jaggies.
                  filterQuality: FilterQuality.medium,
                  cacheWidth: cw(phoneWidth),
                ),
              ),
            ),
          ),
        ),

        // Bottom card overlay + tappable zones
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(
            child: SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: Stack(
                children: [
                  // Card image (expensive) -> isolate
                  IgnorePointer(
                    child: RepaintBoundary(
                      child: Image.asset(
                        cardOverlay,
                        width: cardWidth,
                        height: cardHeight,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                        cacheWidth: cw(cardWidth),
                        cacheHeight: ch(cardHeight),
                      ),
                    ),
                  ),

                  // Tap zones
                  Positioned.fromRect(
                    rect: _skipRect.toRect(cardWidth, cardHeight),
                    child: _TapArea(onTap: onSkip, semanticsLabel: 'Skip'),
                  ),
                  Positioned.fromRect(
                    rect: _continueRect.toRect(cardWidth, cardHeight),
                    child:
                        _TapArea(onTap: onContinue, semanticsLabel: 'Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TapArea extends StatelessWidget {
  const _TapArea({required this.onTap, required this.semanticsLabel});
  final VoidCallback onTap;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: onTap,
          containedInkWell: true,
          highlightShape: BoxShape.rectangle,
        ),
      ),
    );
  }
}

class _RelRect {
  final double left, top, width, height;
  const _RelRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  Rect toRect(double parentW, double parentH) {
    return Rect.fromLTWH(
      parentW * left,
      parentH * top,
      parentW * width,
      parentH * height,
    );
  }
}

class _PaginationDots extends StatelessWidget {
  const _PaginationDots({this.index, this.total, this.asset});
  final int? index;
  final int? total;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    final idx = index;
    final tot = total;

    if (idx != null && tot != null && tot > 1) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            height: 26,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(tot, (i) {
                final active = i == idx;
                return Padding(
                  padding: EdgeInsets.only(right: i == tot - 1 ? 0 : 7),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: active ? 10 : 8,
                    height: active ? 10 : 8,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.black
                          : Colors.black.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    }

    if (asset != null) {
      return Image.asset(asset!, height: 26, filterQuality: FilterQuality.low);
    }
    return const SizedBox.shrink();
  }
}
