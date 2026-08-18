import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../product/models/product_model.dart';

import '../../../shared/widgets/app_cached_image.dart';

class RecentlyViewedCard extends StatelessWidget {
  final Product product;
  const RecentlyViewedCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}', extra: product),
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCachedImage(
              imageUrl: product.displayImageUrl,
              width: 110,
              height: 110,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(10),
              memCacheWidth: 220,
              memCacheHeight: 220,
            ),
            const SizedBox(height: 6),
            Text(
              product.name,
              style: const TextStyle(
                color: AppColors.onBackground,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}