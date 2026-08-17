import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';

class SharedSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<bool>? onFocus;
  final bool autofocus;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilters;
  final String hintText;
  final EdgeInsetsGeometry padding;

  const SharedSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onFocus,
    this.autofocus = false,
    this.onFilterTap,
    this.hasActiveFilters = false,
    this.hintText = 'Search...',
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Focus(
              onFocusChange: onFocus,
              child: TextField(
                controller: controller,
                autofocus: autofocus,
                onChanged: onChanged,
                style: const TextStyle(color: AppColors.onBackground, fontSize: 14),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    color: AppColors.onSurfaceVariant,
                    size: 18,
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (_, value, __) => value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              LucideIcons.x,
                              size: 16,
                              color: AppColors.onSurfaceVariant,
                            ),
                            onPressed: () {
                              controller.clear();
                              onChanged('');
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1),
                  ),
                ),
              ),
            ),
          ),
          if (onFilterTap != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onFilterTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: hasActiveFilters
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: hasActiveFilters
                          ? Border.all(color: AppColors.primary, width: 1)
                          : null,
                    ),
                    child: Icon(
                      LucideIcons.slidersHorizontal,
                      color: hasActiveFilters ? AppColors.primary : AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
