import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/cart/cart_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/alert_service.dart';
import '../../product/models/product_model.dart';
import '../../home/store/recently_viewed_store.dart';
import '../../home/widgets/bottom_sheet.dart';

class ShopProductCard extends StatelessWidget {
  final Product product;
  const ShopProductCard({super.key, required this.product});

  // Image takes 195px, text section takes ~85px = 280px total
  // Matches mainAxisExtent: 280 in the grid delegate
  static const double _imageHeight = 192;

  @override
  Widget build(BuildContext context) {
    final isSoldOut = product.stockStatus != 'instock';
    final isOnSale = product.onSale;

    return GestureDetector(
      onTap: isSoldOut
          ? null
          : () {
              RecentlyViewedStore.add(product);
              context.push('/product/${product.id}', extra: product);
            },
      child: Opacity(
        opacity: isSoldOut ? 0.55 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // don't stretch beyond content
            children: [
              // ── Image ──────────────────────────────────────────────────
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: SizedBox(
                      height: _imageHeight,
                      width: double.infinity,
                      child: Image.network(
                        product.displayImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.background,
                          child: const Center(
                            child: Icon(
                              LucideIcons.imageOff,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isOnSale)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBA7517),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'SALE',
                          style: TextStyle(
                            color: Color(0xFFFAEEDA),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  if (isSoldOut)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.background.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: const Text(
                            'Sold out',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!isSoldOut)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          if (product.isVariable) {
                            QuickAddBottomSheet.show(context, product);
                          } else {
                            CartManager.addProduct(product);
                            AlertService.show(context, 'Added to cart');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.background.withValues(alpha: 0.75),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.plus,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // ── Info ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: AppColors.onBackground,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    if (isOnSale)
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '\$${product.regularPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFFBA7517),
                                fontSize: 12,
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
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}