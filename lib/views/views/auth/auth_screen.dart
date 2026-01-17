import 'dart:io';

import 'package:ez_save/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthenticationScreen extends ConsumerWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final theme = Theme.of(context);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.savings_outlined, size: 100, color: theme.colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  'EZ Save',
                  style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Google Sign-In Button
                _SocialSignInButton(
                  onPressed: isLoading ? null : () => ref.read(authViewModelProvider.notifier).signInWithGoogle(context),
                  icon: _GoogleIcon(),
                  label: 'Continue with Google',
                  isLoading: isLoading,
                ),
                const SizedBox(height: 16),

                // Apple Sign-In Button (iOS only)
                if (Platform.isIOS) ...[
                  _SocialSignInButton(
                    onPressed: isLoading ? null : () => ref.read(authViewModelProvider.notifier).signInWithApple(context),
                    icon: Icon(Icons.apple, size: 24, color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                    label: 'Continue with Apple',
                    isLoading: isLoading,
                    backgroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                    foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const _SocialSignInButton({required this.onPressed, required this.icon, required this.label, this.isLoading = false, this.backgroundColor, this.foregroundColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: backgroundColor != null ? BorderSide.none : BorderSide(color: theme.colorScheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: foregroundColor ?? theme.colorScheme.primary))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(color: foregroundColor, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 24, height: 24, child: CustomPaint(painter: _GoogleLogoPainter()));
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Google "G" logo colors
    final Paint bluePaint = Paint()..color = const Color(0xFF4285F4);
    final Paint greenPaint = Paint()..color = const Color(0xFF34A853);
    final Paint yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final Paint redPaint = Paint()..color = const Color(0xFFEA4335);

    final center = Offset(width / 2, height / 2);
    final radius = width / 2;

    // Blue section (right part)
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -0.5, 1.2, true, bluePaint);

    // Green section (bottom right)
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0.7, 1.0, true, greenPaint);

    // Yellow section (bottom left)
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 1.7, 1.0, true, yellowPaint);

    // Red section (top)
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 2.7, 1.05, true, redPaint);

    // White inner circle
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, whitePaint);

    // Blue horizontal bar
    canvas.drawRect(Rect.fromLTWH(width * 0.48, height * 0.38, width * 0.52, height * 0.24), bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
