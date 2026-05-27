import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CategoryFilterBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = selectedCategory == cat;
          return GestureDetector(
            onTap: () => onCategorySelected(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 28),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                cat.toUpperCase(),
                style: TextStyle(
                  color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}