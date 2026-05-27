import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<bool> onFocus;
  final bool autofocus;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFocus,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Focus(
        onFocusChange: onFocus,
        child: TextField(
          controller: controller,
          autofocus: autofocus,
          onChanged: onChanged,
          style: const TextStyle(color: AppColors.onBackground, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search albums, merch, artists...',
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
    );
  }
}