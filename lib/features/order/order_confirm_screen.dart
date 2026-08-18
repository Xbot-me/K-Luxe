import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/cart/cart_manager.dart';
import '../../core/theme/theme_provider.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_cached_image.dart';
import '../home/home_screen.dart';
import 'order_history_screen.dart';

class OrderConfirmScreen extends ConsumerStatefulWidget {
  final String orderId;
  final List<CartItem>? items;
  final double? total;

  const OrderConfirmScreen({
    super.key,
    required this.orderId,
    this.items,
    this.total,
  });

  @override
  ConsumerState<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends ConsumerState<OrderConfirmScreen>
    with TickerProviderStateMixin {
  late final AnimationController _checkController;
  late final Animation<double> _checkScale;

  late final AnimationController _contentController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  late final AnimationController _btnController;
  late final Animation<double> _btnFade;

  @override
  void initState() {
    super.initState();

    // Checkmark elastic pop
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    // Content fade and slide up
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    // Action buttons fade in
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _btnFade = CurvedAnimation(
      parent: _btnController,
      curve: Curves.easeIn,
    );

    // Sequence animations
    _checkController.forward();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _contentController.forward();
    });
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) _btnController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _contentController.dispose();
    _btnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final branding = ref.watch(tenantBrandingProvider);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final bg = theme.scaffoldBackgroundColor;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 24),
                          // ── 1. Checkmark Circle with Ambient Glow ──
                          _buildCheckmark(primary),
                          const SizedBox(height: 28),

                          // ── 2. Title & Subtitle ──
                          _buildHeading(theme, onSurface, onSurfaceVariant, branding.appTitle),
                          const SizedBox(height: 32),

                          // ── 3. Order Details Card ──
                          _buildOrderCard(theme, primary, surface, onSurface, onSurfaceVariant, branding.borderRadius.toDouble()),
                          const SizedBox(height: 32),
                        ],
                      ),

                      // ── 4. Action Buttons ──
                      _buildButtons(context, primary, surface, onSurface),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCheckmark(Color primary) {
    return ScaleTransition(
      scale: _checkScale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Glow
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.3),
                  blurRadius: 36,
                  spreadRadius: 6,
                ),
              ],
            ),
          ),
          // Outer decorative border
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: 0.12),
              border: Border.all(
                color: primary.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF41117C),
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading(ThemeData theme, Color onSurface, Color onSurfaceVariant, String appTitle) {
    return FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: _contentSlide,
        child: Column(
          children: [
            Text(
              'Order Confirmed!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: onSurface,
                letterSpacing: -0.5,
              ) ?? TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Thank you for shopping with $appTitle.\nWe\'re preparing your merch shipment now.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onSurfaceVariant,
                height: 1.5,
              ) ?? TextStyle(
                fontSize: 14,
                color: onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    ThemeData theme,
    Color primary,
    Color surface,
    Color onSurface,
    Color onSurfaceVariant,
    double borderRadius,
  ) {
    final items = widget.items ?? [];
    final total = widget.total;

    return FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: _contentSlide,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(borderRadius > 0 ? borderRadius : 20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.packageCheck, size: 18, color: primary),
                        const SizedBox(width: 8),
                        Text(
                          'Order Number',
                          style: TextStyle(
                            fontSize: 13,
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '#${widget.orderId.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Items Summary Preview if available
              if (items.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'ITEMS ORDERED (${items.length})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                ...items.take(3).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      AppCachedImage(
                        imageUrl: item.product.displayImageUrl,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(8),
                        memCacheWidth: 100,
                        memCacheHeight: 100,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Qty: ${item.quantity}',
                              style: TextStyle(
                                fontSize: 11,
                                color: onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                )),
                if (items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+ ${items.length - 3} more items',
                      style: TextStyle(fontSize: 11, color: onSurfaceVariant, fontStyle: FontStyle.italic),
                    ),
                  ),
              ],

              const Divider(color: Colors.white10, height: 28),

              // Summary Metadata Rows
              _buildSummaryRow('Estimated Delivery', '2–4 Business Days', onSurface, onSurfaceVariant),
              const SizedBox(height: 10),
              _buildSummaryRow('Status', 'Processing', primary, onSurfaceVariant, isStatus: true),
              if (total != null && total > 0) ...[
                const SizedBox(height: 10),
                _buildSummaryRow('Total Paid', '\$${total.toStringAsFixed(2)}', primary, onSurfaceVariant, isTotal: true),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor, Color labelColor, {bool isStatus = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: labelColor,
          ),
        ),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: valueColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: valueColor,
            ),
          ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context, Color primary, Color surface, Color onSurface) {
    return FadeTransition(
      opacity: _btnFade,
      child: Column(
        children: [
          // Primary CTA: Continue Shopping
          AppActionButton(
            onPressed: () async {
              HapticFeedback.lightImpact();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            label: 'CONTINUE SHOPPING',
            icon: LucideIcons.shoppingBag,
            backgroundColor: primary,
            foregroundColor: const Color(0xFF41117C),
            height: 54,
            borderRadius: 16,
          ),
          const SizedBox(height: 12),

          // Secondary CTA: View Order History
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
              );
            },
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.history, size: 16, color: onSurface),
                  const SizedBox(width: 8),
                  Text(
                    'VIEW ORDERS',
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}