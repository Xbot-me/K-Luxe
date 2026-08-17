import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../models/shop_filter_state.dart';

class ActiveFilterChips extends StatelessWidget {
  final ShopFilterState filters;
  final VoidCallback onClearAll;
  final ValueChanged<ShopFilterState> onRemove;

  const ActiveFilterChips({
    super.key,
    required this.filters,
    required this.onClearAll,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (!filters.hasActiveFilters) return const SizedBox.shrink();

    final chips = <Widget>[];

    if (filters.category != 'ALL') {
      chips.add(_Chip(
        label: filters.category,
        onRemove: () => onRemove(filters.copyWith(category: 'ALL')),
      ));
    }

    if (filters.sort != SortOption.newest) {
      chips.add(_Chip(
        label: filters.sort.label,
        onRemove: () => onRemove(filters.copyWith(sort: SortOption.newest)),
      ));
    }

    if (filters.minPrice > 0 || filters.maxPrice < 500) {
      final label =
          '\$${filters.minPrice.toInt()} – \$${filters.maxPrice.toInt()}${filters.maxPrice >= 500 ? '+' : ''}';
      chips.add(_Chip(
        label: label,
        onRemove: () => onRemove(filters.copyWith(minPrice: 0, maxPrice: 500)),
      ));
    }

    if (filters.inStockOnly) {
      chips.add(_Chip(
        label: 'In stock',
        onRemove: () => onRemove(filters.copyWith(inStockOnly: false)),
      ));
    }

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...chips,
          GestureDetector(
            onTap: onClearAll,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: const Text(
                'Clear all',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _Chip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(LucideIcons.x, size: 12, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}