import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/cart/cart_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/alert_service.dart';
import '../../product/models/product_model.dart';
import '../store/recently_viewed_store.dart';
import '../widgets/bottom_sheet.dart';

class PremiumProductCard extends StatelessWidget {
  final Product product;
  const PremiumProductCard({super.key, required this.product});

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
          width: 140,
          height: 310,
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.displayImageUrl,
                      height: 186,
                      width: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 186,
                        width: 140,
                        color: AppColors.surface,
                        child: const Center(
                          child: Icon(LucideIcons.imageOff, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                  if (isOnSale)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                      bottom: 10,
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
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.name,
                          style: const TextStyle(
                            color: AppColors.onBackground,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (isOnSale)
                          Row(
                            children: [
                              Text(
                                '\$${product.regularPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 11,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFBA7517),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!isSoldOut)
                    GestureDetector(
                      onTap: () {
                        if (product.isVariable) {
                          QuickAddBottomSheet.show(context, product);
                        } else {
                          CartManager.addProduct(product);
                          AlertService.show(context, 'Added to cart');
                        }
                      },
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}