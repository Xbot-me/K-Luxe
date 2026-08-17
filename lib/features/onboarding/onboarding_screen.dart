import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_container.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCgAh6srr2TJKmEqWs1bj3Bavsjb31eZ1UkTpaj_3AyasZmjBpnZOYUcK7aI6FOd8TRcxmWmsYSQkX99C3cLLtXDfCMADn4bm_2PXPCkekycspEhapqKp-BWPBYpGSfArih4NZiqDzuCAheKx6f4mMyeD804bzKdDxxYH-cpBQVVptK6N9yVMlob1otef9hDKy955nBUp9eO2AOB8f7FkGzEf7OUT-nw35n0L8ShYq_RX3Zb_nnI_HyYXX8mG0eVM_KlYrDXSpGj_4',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.6),
            ),
          ),
          
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.background],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassContainer(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Exclusive Collections',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 36,
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          'Access limited edition albums and rare photocards from your favorite idols.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ).animate().fadeIn(delay: 200.ms),
                        
                        const SizedBox(height: 48),
                        
                        // Page Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(radius: 3, backgroundColor: Colors.white.withValues(alpha: 0.2)),
                            const SizedBox(width: 8),
                            CircleAvatar(radius: 3, backgroundColor: Colors.white.withValues(alpha: 0.2)),
                          ],
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // Next Button
                        GestureDetector(
                          onTap: () => context.go('/home'),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'NEXT',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(LucideIcons.arrowRight, size: 16, color: AppColors.onPrimary),
                              ],
                            ),
                          ),
                        ).animate()
                        .fadeIn(delay: 500.ms)
                        .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
