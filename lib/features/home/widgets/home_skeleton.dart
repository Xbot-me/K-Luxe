import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Shimmer.fromColors(
        baseColor: AppColors.surface,
        highlightColor: AppColors.surface.withValues(alpha: 0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 540, width: double.infinity, color: Colors.white),
            const SizedBox(height: 20),
            _skeletonBox(height: 48, horizontalPadding: 24, radius: 16),
            const SizedBox(height: 20),
            _skeletonBox(height: 72, horizontalPadding: 24, radius: 16),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: List.generate(
                  4,
                  (i) => Container(
                    height: 20,
                    width: 60,
                    margin: const EdgeInsets.only(right: 28),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 24, width: 160, color: Colors.white),
                  Container(height: 14, width: 60, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 320,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 3,
                itemBuilder: (_, i) => Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _skeletonBox({
    required double height,
    required double horizontalPadding,
    required double radius,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}