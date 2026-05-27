import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../models/product_model.dart';

class ProductsCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductsCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  // ── Price display string ──────────────────────────────────────────────────
  // Variable with a range  →  "$12 – $18"
  // Variable, single price →  "$12.00"
  // Simple on sale         →  "$12.00"  (strikethrough handled separately)
  // Simple                 →  "$12.00"
  String get _priceLabel {
    if (product.isVariable && product.priceRange != null) {
      final r = product.priceRange!;
      if (r.min != r.max) {
        return '\$${r.min.toStringAsFixed(2)} – \$${r.max.toStringAsFixed(2)}';
      }
    }
    return '\$${product.price.toStringAsFixed(2)}';
  }

  // Only show strikethrough for simple products on sale
  bool get _showStrikethrough =>
      product.onSale && !product.isVariable && product.regularPrice > product.price;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ───────────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'product-image-${product.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: ColorFiltered(
                        // Dim image when out of stock
                        colorFilter: product.inStock
                            ? const ColorFilter.mode(
                                Colors.transparent, BlendMode.multiply)
                            : ColorFilter.mode(
                                Colors.black.withValues(alpha: 0.45),
                                BlendMode.darken),
                        child: Image.network(
                          product.featuredImage.url,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return Container(color: AppColors.surface);
                          },
                          errorBuilder: (ctx, _, __) =>
                              Container(color: AppColors.surface),
                        ),
                      ),
                    ),
                  ),

                  // Discount badge — simple products only
                  if (product.discountPercent != null && !product.isVariable)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                  // Out of stock badge
                  if (!product.inStock)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Product name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 14,
                          height: 1.3,
                        ),
                  ),

                  // Artist
                  if ((product.artist ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.artist ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 11),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(
                        product.averageRating.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── Price + action row ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _priceLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                          if (_showStrikethrough)
                            Text(
                              '\$${product.regularPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),

                      // Variable → navigate to detail for selection
                      // Simple in stock → add directly
                      // Out of stock → disabled
                      GestureDetector(
                        onTap: product.inStock
                            ? (product.isVariable ? onTap : onAddToCart)
                            : null,
                        child: product.isVariable
                            ? Row(
                                children: [
                                  Text(
                                    'Options',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primary
                                          .withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    LucideIcons.chevronRight,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                ],
                              )
                            : Icon(
                                LucideIcons.plusCircle,
                                color: product.inStock
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant
                                        .withValues(alpha: 0.3),
                                size: 28,
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}