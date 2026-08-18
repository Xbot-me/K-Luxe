import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/utils/alert_service.dart';
import 'package:flutter_application_1/shared/widgets/alert.dart';
import '../../../core/theme/app_colors.dart';
import '../../product/models/product_model.dart';
import '../../../core/cart/cart_manager.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../product/repositories/product_repository.dart';
import '../../../shared/widgets/app_cached_image.dart';
import '../../../shared/widgets/app_action_button.dart';

class QuickAddBottomSheet extends ConsumerStatefulWidget {
  final Product product; // minimal product from list (no options/variants)

  const QuickAddBottomSheet({super.key, required this.product});

  static void show(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QuickAddBottomSheet(product: product),
    );
  }

  @override
  ConsumerState<QuickAddBottomSheet> createState() => _QuickAddBottomSheetState();
}

class _QuickAddBottomSheetState extends ConsumerState<QuickAddBottomSheet> {
  Product? _fullProduct;
  bool _isLoading = true;
  bool _isAdding = false;
  final Map<String, String> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    _loadFullProduct();
  }

  Future<void> _loadFullProduct() async {
    try {
      final product = await ref.read(productRepositoryProvider).getProduct(
        widget.product.id,
      );
      setState(() {
        _fullProduct = product;
        _isLoading = false;
      });
      // Auto-select first option for each variation attribute
      for (var attr in product.variationAttributes) {
        if (attr.options.isNotEmpty &&
            !_selectedOptions.containsKey(attr.key)) {
          _selectedOptions[attr.key] = attr.options.first;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AlertService.show(
          context, 
          'Failed to load product details', 
          type: AlertType.error
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _fullProduct ?? widget.product;

    if (_isLoading) {
  return GlassContainer(
    blur: 30,
    color: AppColors.surface.withAlpha(230),
    borderRadius: 32,
    // Add a height constraint so it doesn't jump to full screen
    child: SizedBox(
      height: 350, // This keeps it at a "bottom sheet" height
      width: double.infinity,
      child: Column(
        children: [
          // Drag handle to maintain visual consistency
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Spacer(),
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            "Loading variations...",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const Spacer(),
        ],
      ),
    ),
  );
}

    final selectedVariant = product.findVariant(_selectedOptions);
    final bool isOutOfStock =
        selectedVariant != null && !selectedVariant.inStock;
    final bool noVariantSelected = selectedVariant == null;

    return GlassContainer(
      blur: 30,
      color: AppColors.surface.withAlpha(230),
      borderRadius: 32,
      border: const Border(top: BorderSide(color: Colors.white10)),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppCachedImage(
                          imageUrl: product.displayImageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(12),
                          memCacheWidth: 200,
                          memCacheHeight: 200,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    if (product.variationAttributes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "Select an option",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),

                    ...product.variationAttributes.map((attr) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attr.name.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: attr.options.map((option) {
                                final isSelected =
                                    _selectedOptions[attr.key] == option;
                                final tempSelection = Map<String, String>.from(
                                  _selectedOptions,
                                );
                                tempSelection[attr.key] = option;
                                final variant = product.findVariant(
                                  tempSelection,
                                );
                                final bool inStock =
                                    variant?.stockStatus == 'instock';

                                return GestureDetector(
                                  onTap: inStock
                                      ? () => setState(
                                          () => _selectedOptions[attr.key] =
                                              option,
                                        )
                                      : null,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.white.withAlpha(13),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : (inStock
                                                  ? Colors.white10
                                                  : Colors.transparent),
                                      ),
                                    ),
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.onPrimary
                                            : (inStock
                                                  ? Colors.white
                                                  : Colors.white24),
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        decoration: inStock
                                            ? TextDecoration.none
                                            : TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: AppActionButton(
                onPressed: (isOutOfStock || noVariantSelected)
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        await ref.read(cartProvider.notifier).addProduct(
                          product,
                          variantId: selectedVariant.id,
                          selectedOptions: _selectedOptions,
                        );
                        if (mounted) {
                          navigator.pop();
                          AlertService.show(context, 'Added to cart');
                        }
                      },
                enabled: !isOutOfStock && !noVariantSelected,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                label: isOutOfStock ? 'OUT OF STOCK' : 'ADD TO CART',
                height: 56,
                borderRadius: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
