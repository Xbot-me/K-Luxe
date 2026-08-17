import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/cart/cart_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/alert_service.dart';
import '../../features/product/models/product_model.dart';
import '../../features/home/store/recently_viewed_store.dart';
import '../../features/home/widgets/bottom_sheet.dart';

enum ProductCardVariant {
  /// Used in Shop Screen (liquid width grid, add to cart top right)
  shopGrid,
  /// Used in Home Screen horizontal lists (fixed width 140)
  horizontal,
  /// Used in Best Sellers (glassmorphism effect, rating, artist)
  glass,
}

class SharedProductCard extends ConsumerWidget {
  final Product product;
  final ProductCardVariant variant;

  const SharedProductCard({
    super.key,
    required this.product,
    required this.variant,
  });

  bool get _isSoldOut => !product.inStock;
  bool get _isOnSale => product.onSale;

  String get _priceLabel {
    if (product.isVariable && product.priceRange != null) {
      final r = product.priceRange!;
      if (r.min != r.max) {
        return '\$${r.min.toStringAsFixed(2)} – \$${r.max.toStringAsFixed(2)}';
      }
    }
    return '\$${product.price.toStringAsFixed(2)}';
  }

  void _onTap(BuildContext context) {
    if (_isSoldOut) return;
    RecentlyViewedStore.add(product);
    context.push('/product/${product.id}', extra: product);
  }

  void _onAddToCart(BuildContext context, WidgetRef ref) {
    if (product.isVariable) {
      QuickAddBottomSheet.show(context, product);
    } else {
      ref.read(cartProvider.notifier).addProduct(product);
      AlertService.show(context, 'Added to cart');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _onTap(context),
      child: Opacity(
        opacity: _isSoldOut ? 0.55 : 1.0,
        child: _buildCardContent(context, ref),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, WidgetRef ref) {
    if (variant == ProductCardVariant.glass) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'product-image-${product.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: _buildImage(double.infinity),
                    ),
                  ),
                  _buildDiscountBadge(isGlass: true),
                  _buildSoldOutBadge(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryPill(isGlass: true),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14, height: 1.3),
                  ),
                  if ((product.artist ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.artist!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(
                        product.averageRating.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _priceLabel,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondary),
                          ),
                          if (_isOnSale && !product.isVariable && product.regularPrice > product.price)
                            Text(
                              '\$${product.regularPrice.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), decoration: TextDecoration.lineThrough),
                            ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _isSoldOut ? null : () => _onAddToCart(context, ref),
                        child: product.isVariable
                            ? Row(
                                children: [
                                  Text('Options', style: TextStyle(fontSize: 11, color: AppColors.primary.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 4),
                                  const Icon(LucideIcons.chevronRight, color: AppColors.primary, size: 16),
                                ],
                              )
                            : Icon(LucideIcons.plusCircle, color: !_isSoldOut ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha: 0.3), size: 28),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isHorizontal = variant == ProductCardVariant.horizontal;
    
    return Container(
      width: isHorizontal ? 140 : null,
      height: isHorizontal ? 310 : null,
      margin: isHorizontal ? const EdgeInsets.only(right: 16) : null,
      decoration: isHorizontal ? null : BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: isHorizontal ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: isHorizontal ? BorderRadius.circular(12) : const BorderRadius.vertical(top: Radius.circular(14)),
                child: SizedBox(
                  height: isHorizontal ? 186 : 192,
                  width: double.infinity,
                  child: _buildImage(isHorizontal ? 186 : 192),
                ),
              ),
              _buildDiscountBadge(),
              _buildSoldOutBadge(bottom: isHorizontal ? 10 : 8),
              if (!isHorizontal && !_isSoldOut)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _onAddToCart(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.75),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const Icon(LucideIcons.plus, color: Colors.white, size: 14),
                    ),
                  ),
                ),
            ],
          ),
          if (isHorizontal) const SizedBox(height: 12),
          if (isHorizontal) const SizedBox(height: 12),
          if (isHorizontal)
            Expanded(child: _buildBottomInfo(context, ref, isHorizontal))
          else
            _buildBottomInfo(context, ref, isHorizontal),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(BuildContext context, WidgetRef ref, bool isHorizontal) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 8, 10, isHorizontal ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: isHorizontal ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCategoryPill(isGlass: false),
                SizedBox(height: isHorizontal ? 4 : 3),
                Text(
                  product.name,
                  style: TextStyle(
                    color: AppColors.onBackground,
                    fontSize: isHorizontal ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    height: isHorizontal ? 1.0 : 1.3,
                  ),
                  maxLines: isHorizontal ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isHorizontal ? 4 : 5),
                if (_isOnSale)
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '\$${product.regularPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: isHorizontal ? 11 : 10,
                            decoration: TextDecoration.lineThrough,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: isHorizontal ? 6 : 4),
                      Flexible(
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: const Color(0xFFBA7517),
                            fontSize: isHorizontal ? 13 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: isHorizontal ? 13 : 12,
                      fontWeight: isHorizontal ? FontWeight.normal : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (isHorizontal && !_isSoldOut)
            GestureDetector(
              onTap: () => _onAddToCart(context, ref),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.plus, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(double height) {
    return ColorFiltered(
      colorFilter: _isSoldOut
          ? ColorFilter.mode(Colors.black.withValues(alpha: 0.45), BlendMode.darken)
          : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
      child: Image.network(
        product.displayImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.background,
          child: const Center(child: Icon(LucideIcons.imageOff, color: AppColors.onSurfaceVariant)),
        ),
      ),
    );
  }

  Widget _buildCategoryPill({required bool isGlass}) {
    if (isGlass) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          product.category,
          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.0),
        ),
      );
    } else {
      return Text(
        product.category.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _buildDiscountBadge({bool isGlass = false}) {
    if (!_isOnSale) return const SizedBox.shrink();
    if (isGlass && product.discountPercent != null && !product.isVariable) {
      return Positioned(
        top: 10,
        left: 10,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(8)),
          child: Text(
            '-${product.discountPercent}%',
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
        ),
      );
    } else if (!isGlass) {
      return Positioned(
        top: 8,
        left: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFFBA7517), borderRadius: BorderRadius.circular(20)),
          child: const Text(
            'SALE',
            style: TextStyle(color: Color(0xFFFAEEDA), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.8),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSoldOutBadge({double? bottom}) {
    if (!_isSoldOut) return const SizedBox.shrink();
    return Positioned(
      bottom: bottom ?? 10,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Text(
            'OUT OF STOCK',
            style: TextStyle(color: bottom == null ? Colors.white : AppColors.onSurfaceVariant, fontSize: bottom == null ? 9 : 10, fontWeight: bottom == null ? FontWeight.w700 : FontWeight.w500, letterSpacing: bottom == null ? 1.0 : null),
          ),
        ),
      ),
    );
  }
}
