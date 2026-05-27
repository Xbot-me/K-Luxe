import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Use InkWell with a larger hit target instead of GestureDetector on Text
          GestureDetector(
            onTap: onViewAll,
            behavior: HitTestBehavior.opaque, // ← this is the key fix
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8, // enlarged tap area
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'VIEW ALL',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: AppColors.primary,
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