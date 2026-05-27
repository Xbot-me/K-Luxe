import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../models/shop_filter_state.dart';

class FilterBottomSheet extends StatefulWidget {
  final ShopFilterState initial;
  final List<String> categories;
  final ValueChanged<ShopFilterState> onApply;

  const FilterBottomSheet({
    super.key,
    required this.initial,
    required this.categories,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required ShopFilterState initial,
    required List<String> categories,
    required ValueChanged<ShopFilterState> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        initial: initial,
        categories: categories,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late ShopFilterState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
              child: Row(
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      color: AppColors.onBackground,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (_state.hasActiveFilters)
                    TextButton(
                      onPressed: () => setState(() => _state = _state.reset()),
                      child: const Text(
                        'Reset all',
                        style: TextStyle(color: AppColors.primary, fontSize: 13),
                      ),
                    ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, color: AppColors.onSurfaceVariant, size: 20),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 24),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Sort ──────────────────────────────────────────────
                    _SectionLabel(label: 'Sort by'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SortOption.values.map((opt) {
                        final isActive = _state.sort == opt;
                        return GestureDetector(
                          onTap: () => setState(() => _state = _state.copyWith(sort: opt)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive ? AppColors.primary : Colors.white12,
                              ),
                            ),
                            child: Text(
                              opt.label,
                              style: TextStyle(
                                color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                                fontSize: 13,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ── Category ──────────────────────────────────────────
                    _SectionLabel(label: 'Category'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.categories.map((cat) {
                        final isActive = _state.category == cat;
                        return GestureDetector(
                          onTap: () => setState(() => _state = _state.copyWith(category: cat)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive ? AppColors.primary : Colors.white12,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                                fontSize: 13,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ── Price Range ───────────────────────────────────────
                    _SectionLabel(label: 'Price range'),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${_state.minPrice.toInt()}',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '\$${_state.maxPrice.toInt()}${_state.maxPrice >= 500 ? '+' : ''}',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: RangeValues(_state.minPrice, _state.maxPrice),
                      min: 0,
                      max: 500,
                      divisions: 50,
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.white12,
                      onChanged: (values) => setState(() => _state = _state.copyWith(
                            minPrice: values.start,
                            maxPrice: values.end,
                          )),
                    ),
                    const SizedBox(height: 8),

                    // ── In Stock Toggle ───────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.packageCheck,
                              color: AppColors.onSurfaceVariant, size: 18),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'In stock only',
                                  style: TextStyle(
                                    color: AppColors.onBackground,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Hide sold-out items',
                                  style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _state.inStockOnly,
                            onChanged: (v) =>
                                setState(() => _state = _state.copyWith(inStockOnly: v)),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Apply button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onApply(_state);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.onBackground,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}