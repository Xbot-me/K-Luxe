import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ).animate().fadeIn(duration: 2.seconds).scale(begin: const Offset(0.5, 0.5)),
          ),
          
          Center(
            child: Text(
              'K-LUXE',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 64,
                    letterSpacing: 8.0,
                    shadows: [
                      Shadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
            )
            .animate()
            .fadeIn(duration: 1.seconds)
            .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack)
            .shimmer(delay: 1.seconds, duration: 2.seconds, color: AppColors.secondary),
          ),
          
          Positioned(
            bottom: 60,
            child: Text(
              'EXPERIENCE THE LUXE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ).animate().fadeIn(delay: 1.5.seconds),
          ),
        ],
      ),
    );
  }
}
