import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/theme_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    final branding = ref.watch(tenantBrandingProvider);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final background = theme.scaffoldBackgroundColor;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Dynamic Background Glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.12),
              ),
            ).animate().fadeIn(duration: 2.seconds).scale(begin: const Offset(0.5, 0.5)),
          ),
          
          Center(
            child: Text(
              branding.appTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    letterSpacing: 6.0,
                    shadows: [
                      Shadow(
                        color: primary.withValues(alpha: 0.5),
                        blurRadius: 24,
                      ),
                    ],
                  ),
            )
            .animate()
            .fadeIn(duration: 1.seconds)
            .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack)
            .shimmer(delay: 1.seconds, duration: 2.seconds, color: secondary),
          ),
          
          Positioned(
            bottom: 60,
            child: Text(
              branding.tagline.isNotEmpty ? branding.tagline.toUpperCase() : 'EXPERIENCE THE LUXE',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: onSurface.withValues(alpha: 0.6),
                letterSpacing: 2.5,
              ),
            ).animate().fadeIn(delay: 1.5.seconds),
          ),
        ],
      ),
    );
  }
}
