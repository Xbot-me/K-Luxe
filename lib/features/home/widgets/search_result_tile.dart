import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../product/models/product_model.dart';
import '../store/recently_viewed_store.dart';

class SearchResultTile extends StatelessWidget {
  final Product product;
  const SearchResultTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        RecentlyViewedStore.add(product);
        context.push('/product/${product.id}', extra: product);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.displayImageUrl,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category,
                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}