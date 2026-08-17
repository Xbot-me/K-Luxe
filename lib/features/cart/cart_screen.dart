import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/checkout/models/shipping_rate.dart';
import 'package:flutter_application_1/features/checkout/services/shipping_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/cart/cart_manager.dart';
import '../../shared/widgets/glass_container.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen>
    with AutomaticKeepAliveClientMixin {
  final _couponController = TextEditingController();

  // Shipping rates state
  List<ShippingRate> _availableRates = [];
  ShippingRate? _selectedRate;
  bool _isLoadingRates = false;

  // TODO: Replace with real address selection (e.g., from user's saved addresses)
  final String _mockAddressId = "mock_address_123";

  @override
  void initState() {
    super.initState();
    _loadShippingRates();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _refresh() {} // Replaced by Riverpod

  double get subtotal => ref.watch(cartProvider).fold(0.0, (sum, i) => sum + i.totalPrice);
  double get shippingCost => _selectedRate?.price ?? 0;
  double get total => subtotal + shippingCost;

  Future<void> _loadShippingRates() async {
    setState(() => _isLoadingRates = true);
    try {
      final rates = await ShippingService().getRates(
        addressId: _mockAddressId,
        cartToken: ref.read(cartProvider.notifier).cartToken!,
      );
      setState(() {
        _availableRates = rates;
        _isLoadingRates = false;
        // Auto-select the first rate (optional)
        if (rates.isNotEmpty && _selectedRate == null) {
          _selectedRate = rates.first;
        }
      });
    } catch (e) {
      setState(() => _isLoadingRates = false);
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load shipping rates'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _selectRate(ShippingRate rate) async {
    try {
      await ShippingService().selectRate(
        rateId: rate.id,
        cartToken: ref.read(cartProvider.notifier).cartToken!,
      );
      setState(() => _selectedRate = rate);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select shipping rate: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final items = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () => context.pop(),
              )
            : null,
        title: const Text('YOUR CART'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text(
                    'Clear cart?',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'This will remove all items from your cart.',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(cartProvider.notifier).clear();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              child: const Text(
                'Clear',
                style: TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyState(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${items.fold(0, (sum, i) => sum + i.quantity as int)} items securely held.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // Cart item tiles
                  ...items.map(
                    (item) => _CartItemTile(item: item, onChanged: _refresh),
                  ),
                  const SizedBox(height: 24),

                  // Coupon field (keep as is)
                  _buildCouponField(),
                  const SizedBox(height: 48),

                  // Order summary + shipping selection + checkout
                  GlassContainer(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Subtotal
                        _SummaryRow(
                          label: 'Subtotal',
                          value: '\$${subtotal.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 16),

                        // Shipping section
                        if (_isLoadingRates)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_availableRates.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'No shipping methods available',
                              style: TextStyle(color: AppColors.error),
                            ),
                          )
                        else ...{
                          const SizedBox(height: 8),
                          const Text(
                            'SHIPPING METHODS',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._availableRates.map(
                            (rate) => RadioListTile<ShippingRate>(
                              contentPadding: EdgeInsets.zero,
                              title: Text(rate.title),
                              subtitle: Text(
                                '${rate.estimatedDays} · ${rate.provider}',
                              ),
                              secondary: Text(
                                '\$${rate.price.toStringAsFixed(2)}',
                              ),
                              value: rate,
                              groupValue: _selectedRate,
                              onChanged: (value) => _selectRate(value!),
                              activeColor: AppColors.primary,
                            ),
                          ),
                        },

                        const SizedBox(height: 24),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 24),

                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(fontSize: 20),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 28,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Checkout button
                        GestureDetector(
                          onTap: () => context.push('/checkout'),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'CHECKOUT',
                                style: TextStyle(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          ).animate().shimmer(duration: 2.seconds),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(32),
            borderRadius: 100,
            child: const Icon(
              LucideIcons.shoppingBag,
              size: 48,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add some products to get started',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'START SHOPPING',
                style: TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponField() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(
            LucideIcons.tag,
            size: 16,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _couponController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Enter coupon code',
                hintStyle: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final code = _couponController.text.trim();
              if (code.isEmpty) return;
              // TODO: call CartRepository.applyCoupon(code)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invalid coupon code'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
            ),
            child: const Text(
              'Apply',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Cart item tile (unchanged, but included for completeness) ---
class _CartItemTile extends ConsumerWidget {
  final CartItem item;
  final VoidCallback onChanged;

  const _CartItemTile({required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('${item.product.id}_${item.variantId ?? 'simple'}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 24),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: const Icon(LucideIcons.trash2, color: AppColors.error, size: 22),
      ),
      onDismissed: (_) {
        ref.read(cartProvider.notifier).removeItem(item.product.id, variantId: item.variantId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.product.name} removed'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item.product.featuredImage.url,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  color: AppColors.surface,
                  child: const Icon(
                    LucideIcons.imageOff,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.product.name,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(cartProvider.notifier).removeItem(
                            item.product.id,
                            variantId: item.variantId,
                          );
                        },
                        child: const Icon(
                          LucideIcons.x,
                          size: 18,
                          color: Colors.white30,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item.product.category.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  if (item.variantLabel.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.variantLabel,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                ref.read(cartProvider.notifier).updateQuantity(
                                  item.product.id,
                                  item.quantity - 1,
                                  variantId: item.variantId,
                                );
                              },
                              child: Icon(
                                item.quantity == 1
                                    ? LucideIcons.trash2
                                    : LucideIcons.minus,
                                size: 14,
                                color: item.quantity == 1
                                    ? AppColors.error
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                ref.read(cartProvider.notifier).updateQuantity(
                                  item.product.id,
                                  item.quantity + 1,
                                  variantId: item.variantId,
                                );
                              },
                              child: const Icon(LucideIcons.plus, size: 14),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
