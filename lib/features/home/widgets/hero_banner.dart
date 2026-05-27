import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class HeroBanner extends StatelessWidget {
  final VoidCallback? onShopTap;

  const HeroBanner({super.key,this.onShopTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 540,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(AppConstants.heroImage, fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(gradient: AppColors.darkOverlay),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EXCLUSIVE PRE-ORDER',
                  style: TextStyle(
                    color: AppColors.primary,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ).animate().fadeIn().slideX(),
                const SizedBox(height: 8),
                Text(
                  '2026 Season\'s\nGreetings',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 44,
                    height: 1.1,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onShopTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SHOP COLLECTION',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
