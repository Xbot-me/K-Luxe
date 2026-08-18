import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../product/models/trending_search.dart';

class SearchDiscoveryView extends StatelessWidget {
  final List<String> recentSearches;
  final TrendingTimeframe selectedTimeframe;
  final List<TrendingItem> trendingItems;
  final bool isTrendingLoading;
  final ValueChanged<TrendingTimeframe> onTimeframeChanged;
  final ValueChanged<String> onSelectQuery;
  final ValueChanged<String> onRemoveRecent;
  final VoidCallback onClearRecent;

  const SearchDiscoveryView({
    super.key,
    required this.recentSearches,
    required this.selectedTimeframe,
    required this.trendingItems,
    required this.isTrendingLoading,
    required this.onTimeframeChanged,
    required this.onSelectQuery,
    required this.onRemoveRecent,
    required this.onClearRecent,
  });

  static const List<String> _quickCategories = [
    'Albums',
    'Lightsticks',
    'Vinyl',
    'Photocards',
    'Hoodies',
    'Tour Merch',
    'Accessories',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
      children: [
        // ── 1. Recent Searches ───────────────────────────────────────────────
        if (recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.history, size: 16, color: AppColors.onSurfaceVariant),
                  SizedBox(width: 8),
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onClearRecent,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  child: Text(
                    'Clear all',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches.map((query) {
              return GestureDetector(
                onTap: () => onSelectQuery(query),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.history,
                        size: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        query,
                        style: const TextStyle(
                          color: AppColors.onBackground,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => onRemoveRecent(query),
                        child: const Icon(
                          LucideIcons.x,
                          size: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
        ],

        // ── 2. Popular & Trending Header & Timeframe Pills ───────────────────
        Row(
          children: [
            const Icon(LucideIcons.flame, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Trending Searches',
              style: TextStyle(
                color: AppColors.onBackground,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Timeframe selector
        Row(
          children: TrendingTimeframe.values.map((timeframe) {
            final isSelected = timeframe == selectedTimeframe;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onTimeframeChanged(timeframe),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Text(
                    timeframe.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Trending Items List
        if (isTrendingLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
          )
        else
          ...trendingItems.map((item) {
            final isTopThree = item.rank <= 3;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelectQuery(item.query),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: isTopThree
                          ? Border.all(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Rank badge
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isTopThree
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.rank}',
                            style: TextStyle(
                              color: isTopThree ? AppColors.primary : AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Query name and category
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      item.query,
                                      style: const TextStyle(
                                        color: AppColors.onBackground,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (item.isHot) ...[
                                    const SizedBox(width: 6),
                                    const Icon(
                                      LucideIcons.flame,
                                      size: 14,
                                      color: Colors.orangeAccent,
                                    ),
                                  ],
                                ],
                              ),
                              if (item.category != null || item.searchCount != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item.category ?? '${item.searchCount} searches',
                                  style: const TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Tag badge (e.g. +45%, HOT, NEW)
                        if (item.tag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: item.isHot
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.tag!,
                              style: TextStyle(
                                color: item.isHot ? AppColors.primary : AppColors.onSurfaceVariant,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.search,
                          size: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

        const SizedBox(height: 28),

        // ── 3. Quick Categories ──────────────────────────────────────────────
        const Row(
          children: [
            Icon(LucideIcons.sparkles, size: 16, color: AppColors.onSurfaceVariant),
            SizedBox(width: 8),
            Text(
              'Explore Quick Tags',
              style: TextStyle(
                color: AppColors.onBackground,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickCategories.map((cat) {
            return GestureDetector(
              onTap: () => onSelectQuery(cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Text(
                  cat,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
