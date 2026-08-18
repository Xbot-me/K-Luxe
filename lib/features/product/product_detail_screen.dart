import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/cart/cart_manager.dart';
import 'models/product_model.dart';
import 'repositories/product_repository.dart';
import '../../shared/widgets/app_cached_image.dart';
import '../../shared/widgets/app_action_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Drop-in replacement for the old ProductDetailScreen.
// Same constructor, same external API — only the UI is new.
// ─────────────────────────────────────────────────────────────────────────────
class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  // ── Full product loaded from single-product endpoint ──────────────────────
  // The list API omits variants/attributes — we fetch the full object here,
  // exactly like QuickAddBottomSheet does.
  Product? _fullProduct;
  bool _isLoading = true;

  int _quantity = 1;
  bool _isWishlisted = false;
  final Map<String, String> _selectedOptions = {};

  // Animation controller for the bottom bar entrance
  late final AnimationController _barController;
  late final Animation<double> _barSlide;
  late final Animation<double> _barFade;

  // Convenience: use full product once loaded, else fall back to the stub
  Product get _product => _fullProduct ?? widget.product;

  @override
  void initState() {
    super.initState();

    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _barSlide = Tween<double>(begin: 32, end: 0).animate(
      CurvedAnimation(parent: _barController, curve: Curves.easeOutCubic),
    );
    _barFade = CurvedAnimation(parent: _barController, curve: Curves.easeOut);

    _loadFullProduct();
  }

  Future<void> _loadFullProduct() async {
    try {
      final full = await ref.read(productRepositoryProvider).getProduct(
        widget.product.id,
      );
      if (!mounted) return;
      setState(() {
        _fullProduct = full;
        _isLoading = false;
        // Auto-select first option per attribute, same as QuickAddBottomSheet
        for (final attr in full.variationAttributes) {
          if (attr.options.isNotEmpty &&
              !_selectedOptions.containsKey(attr.key)) {
            _selectedOptions[attr.key] = attr.options.first;
          }
        }
        // Seed the hero image — use first variant image if available
        final firstVariant = full.findVariant(_selectedOptions);
        _activeImageUrl =
            firstVariant?.image?.url ?? full.displayImageUrl;
      });
      // Start bottom-bar entrance after data arrives
      _barController.forward();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Failed to load product details');
    }
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  // ── State helpers ──────────────────────────────────────────────────────────

  ProductVariant? get _selectedVariant =>
      _product.findVariant(_selectedOptions);

  double get _displayPrice =>
      _selectedVariant?.price ?? _product.price;

  double get _displayRegularPrice =>
      _selectedVariant?.regularPrice ?? _product.regularPrice;

  bool get _isOnSale => _displayPrice < _displayRegularPrice;

  // Tracks the currently displayed image URL for crossfade animation
  String _activeImageUrl = '';

  bool get _inStock =>
      _product.isVariable
          ? (_selectedVariant?.inStock ?? false)
          : _product.inStock;

  bool get _allOptionsSelected {
    for (final attr in _product.variationAttributes) {
      if (_selectedOptions[attr.key] == null ||
          _selectedOptions[attr.key]!.isEmpty) {
        return false;
      }
    }
    return true;
  }

  void _addToCart() {
    if (_product.isVariable && !_allOptionsSelected) {
      _showSnack('Please select all options');
      return;
    }
    for (int i = 0; i < _quantity; i++) {
      ref.read(cartProvider.notifier).addProduct(
        _product,
        variantId: _selectedVariant?.id,
        selectedOptions: _selectedOptions,
      );
    }
    HapticFeedback.lightImpact();
    _showSnack('${_product.name} added to cart', success: true);
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? _AppTokens.gold : _AppTokens.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final product = _product;
    // Fallback for before full product loads
    final heroUrl = _activeImageUrl.isNotEmpty
        ? _activeImageUrl
        : product.displayImageUrl;

    return Scaffold(
      backgroundColor: _AppTokens.bg,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: _isLoading
          ? null
          : _BottomBar(
              slide: _barSlide,
              fade: _barFade,
              displayPrice: _displayPrice,
              quantity: _quantity,
              inStock: _inStock,
              isVariable: product.isVariable,
              allOptionsSelected: _allOptionsSelected,
              onAddToCart: _addToCart,
            ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero ──────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            stretch: true,
            backgroundColor: _AppTokens.bg,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Crossfade between variant images on selection change
                  Hero(
                    tag: 'product-image-${product.id}',
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: AppCachedImage(
                        key: ValueKey(heroUrl),
                        imageUrl: heroUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        memCacheWidth: 800,
                        memCacheHeight: 800,
                      ),
                    ),
                  ),
                  // Bottom gradient fade into bg
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 200,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _AppTokens.bg.withValues(alpha: 0),
                            _AppTokens.bg.withValues(alpha: 0.7),
                            _AppTokens.bg,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Nav row
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _GlassButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          _GlassButton(
                            icon: _isWishlisted
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            iconColor: _isWishlisted
                                ? const Color(0xFFE85D5D)
                                : Colors.white,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _isWishlisted = !_isWishlisted);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Category label at bottom of hero
                  Positioned(
                    bottom: 52,
                    left: 24,
                    child: _CategoryPill(product.category),
                  ),
                  // Variant image thumbnails (only when multiple variant images exist)
                  if (!_isLoading && product.isVariable)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: _VariantThumbnailStrip(
                        product: product,
                        activeImageUrl: _activeImageUrl,
                        onThumbnailTap: (variant) {
                          setState(() {
                            // Apply this variant's selectedOptions
                            for (final entry
                                in variant.selectedOptions.entries) {
                              _selectedOptions[entry.key] = entry.value;
                            }
                            _activeImageUrl =
                                variant.image?.url ?? product.displayImageUrl;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Loading skeleton ───────────────────────────────────────────────
          if (_isLoading)
            SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Skeleton(width: 200, height: 28),
                    const SizedBox(height: 12),
                    _Skeleton(width: 100, height: 32),
                    const SizedBox(height: 24),
                    _Skeleton(width: double.infinity, height: 0.5),
                    const SizedBox(height: 24),
                    _Skeleton(width: 80, height: 10),
                    const SizedBox(height: 12),
                    Row(children: [
                      _Skeleton(width: 90, height: 40),
                      const SizedBox(width: 10),
                      _Skeleton(width: 90, height: 40),
                      const SizedBox(width: 10),
                      _Skeleton(width: 90, height: 40),
                    ]),
                    const SizedBox(height: 24),
                    _Skeleton(width: double.infinity, height: 0.5),
                    const SizedBox(height: 24),
                    _Skeleton(width: 80, height: 10),
                    const SizedBox(height: 12),
                    _Skeleton(width: double.infinity, height: 14),
                    const SizedBox(height: 8),
                    _Skeleton(width: double.infinity, height: 14),
                    const SizedBox(height: 8),
                    _Skeleton(width: 180, height: 14),
                  ],
                ),
              ),
            ),

          // ── Content (shown after load) ─────────────────────────────────────
          if (!_isLoading)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Title + stock (simple products)
                  _TitleRow(
                    name: product.name,
                    artist: product.artist,
                    inStock: product.inStock,
                    isVariable: product.isVariable,
                  ),
                  const SizedBox(height: 16),

                  // Price
                  _PriceRow(
                    price: _displayPrice,
                    regularPrice: _displayRegularPrice,
                    isOnSale: _isOnSale,
                  ),
                  const SizedBox(height: 14),

                  // Rating
                  _RatingRow(rating: product.averageRating),
                  const SizedBox(height: 24),

                  // ── Variations ──────────────────────────────────────────
                  if (product.isVariable) ...[
                    _VariationSelector(
                      product: product,
                      selectedOptions: _selectedOptions,
                      onChanged: (key, value) {
                        setState(() {
                          _selectedOptions[key] = value;
                          // Update hero image to the newly selected variant's image
                          final newVariant =
                              product.findVariant(_selectedOptions);
                          final newUrl = newVariant?.image?.url ??
                              product.displayImageUrl;
                          if (newUrl != _activeImageUrl) {
                            _activeImageUrl = newUrl;
                          }
                        });
                      },
                    ),
                    _VariantStockStatus(variant: _selectedVariant),
                    _Divider(),
                  ],

                  // ── Info attributes ────────────────────────────────────
                  if (product.infoAttributes.isNotEmpty) ...[
                    _SectionLabel('Details'),
                    const SizedBox(height: 10),
                    _InfoAttributes(attrs: product.infoAttributes),
                    _Divider(),
                  ],

                  // ── Quantity ───────────────────────────────────────────
                  _SectionLabel('Quantity'),
                  const SizedBox(height: 12),
                  _QuantitySelector(
                    quantity: _quantity,
                    onDecrement: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                    onIncrement: () => setState(() => _quantity++),
                  ),
                  _Divider(),

                  // ── Description ────────────────────────────────────────
                  _SectionLabel('Description'),
                  const SizedBox(height: 10),
                  _Description(product: product),

                  const SizedBox(height: 120),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading skeleton shimmer block
// ─────────────────────────────────────────────────────────────────────────────
class _Skeleton extends StatefulWidget {
  final double width;
  final double height;
  const _Skeleton({required this.width, required this.height});

  @override
  State<_Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<_Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
            _AppTokens.surface,
            _AppTokens.surface2,
            _anim.value,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Variant image thumbnail strip — shown in the hero, right side
// Only renders variants that actually have a distinct image
// ─────────────────────────────────────────────────────────────────────────────
class _VariantThumbnailStrip extends StatelessWidget {
  final Product product;
  final String activeImageUrl;
  final void Function(ProductVariant variant) onThumbnailTap;

  const _VariantThumbnailStrip({
    required this.product,
    required this.activeImageUrl,
    required this.onThumbnailTap,
  });

  @override
  Widget build(BuildContext context) {
    // Collect variants that have their own image, deduplicated by URL
    final seen = <String>{};
    final variantsWithImages = product.variants.where((v) {
      final url = v.image?.url;
      if (url == null || url.isEmpty) return false;
      return seen.add(url); // false if already seen
    }).toList();

    // Need at least 2 distinct images to be worth showing
    if (variantsWithImages.length < 2) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: variantsWithImages.map((variant) {
        final url = variant.image!.url;
        final isActive = url == activeImageUrl;
        return GestureDetector(
          onTap: () => onThumbnailTap(variant),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive
                    ? _AppTokens.gold
                    : Colors.white.withValues(alpha: 0.2),
                width: isActive ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AppCachedImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: 44,
              height: 44,
              borderRadius: BorderRadius.circular(9),
              memCacheWidth: 100,
              memCacheHeight: 100,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inline variation selector — mirrors QuickAddBottomSheet logic exactly,
// styled for the dark editorial theme. No external widget dependency.
// ─────────────────────────────────────────────────────────────────────────────
class _VariationSelector extends StatelessWidget {
  final Product product;
  final Map<String, String> selectedOptions;
  final void Function(String attrKey, String value) onChanged;

  const _VariationSelector({
    required this.product,
    required this.selectedOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final attrs = product.variationAttributes;
    if (attrs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: attrs.map((attr) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Attribute label row — "VERSION : Dawn"
              Row(
                children: [
                  Text(
                    attr.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: _AppTokens.textHint,
                    ),
                  ),
                  if (selectedOptions[attr.key] != null &&
                      selectedOptions[attr.key]!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      ': ${selectedOptions[attr.key]}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: _AppTokens.gold,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: attr.options.map((option) {
                  final isSelected = selectedOptions[attr.key] == option;

                  // Check if this option has any in-stock variant
                  // (same logic as QuickAddBottomSheet)
                  final tempSelection =
                      Map<String, String>.from(selectedOptions);
                  tempSelection[attr.key] = option;
                  final variant = product.findVariant(tempSelection);
                  final bool inStock = variant?.stockStatus == 'instock';

                  return GestureDetector(
                    onTap: inStock
                        ? () => onChanged(attr.key, option)
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _AppTokens.goldLight
                            : _AppTokens.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? _AppTokens.gold
                              : inStock
                                  ? _AppTokens.border
                                  : _AppTokens.surface,
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            option,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? _AppTokens.gold
                                  : inStock
                                      ? _AppTokens.textPrimary
                                      : _AppTokens.textHint,
                              decoration: inStock
                                  ? TextDecoration.none
                                  : TextDecoration.lineThrough,
                              decorationColor: _AppTokens.textHint,
                            ),
                          ),
                          // Diagonal strikethrough for out-of-stock chips
                          if (!inStock)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _StrikethroughPainter(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Diagonal line across out-of-stock option chips
class _StrikethroughPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, 0),
      Paint()
        ..color = _AppTokens.textHint
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens — dark editorial palette
// ─────────────────────────────────────────────────────────────────────────────
class _AppTokens {
  _AppTokens._();

  static const bg = Color(0xFF0E0E10);
  static const surface = Color(0xFF161618);
  static const surface2 = Color(0xFF1E1E21);
  static const border = Color(0xFF262628);

  static const gold = Color(0xFFC9A96E);
  static const goldLight = Color(0x1AC9A96E);
  static const goldBorder = Color(0x40C9A96E);

  static const textPrimary = Color(0xFFF0EDE8);
  static const textSecondary = Color(0xFF888884);
  static const textHint = Color(0xFF555552);

  static const success = Color(0xFF4AB478);
  static const successLight = Color(0x154AB478);
  static const successBorder = Color(0x404AB478);

  static const error = Color(0xFFE85D5D);
  static const errorLight = Color(0x15E85D5D);
  static const errorBorder = Color(0x40E85D5D);

  static const warning = Color(0xFFD4953A);
  static const warningLight = Color(0x15D4953A);
}

// ─────────────────────────────────────────────────────────────────────────────
// Small reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _GlassButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String category;
  const _CategoryPill(this.category);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _AppTokens.goldLight,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: _AppTokens.goldBorder, width: 0.5),
      ),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: _AppTokens.gold,
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  final String name;
  final String? artist;
  final bool inStock;
  final bool isVariable;

  const _TitleRow({
    required this.name,
    required this.artist,
    required this.inStock,
    required this.isVariable,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (artist != null && artist!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              artist!.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.5,
                color: _AppTokens.gold,
              ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _AppTokens.textPrimary,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            if (!isVariable) ...[
              const SizedBox(width: 12),
              _StockBadge(inStock: inStock),
            ],
          ],
        ),
      ],
    );
  }
}

class _StockBadge extends StatelessWidget {
  final bool inStock;
  const _StockBadge({required this.inStock});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: inStock ? _AppTokens.successLight : _AppTokens.errorLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: inStock ? _AppTokens.successBorder : _AppTokens.errorBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: inStock ? _AppTokens.success : _AppTokens.error,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            inStock ? 'In Stock' : 'Out of Stock',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: inStock ? _AppTokens.success : _AppTokens.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final double price;
  final double regularPrice;
  final bool isOnSale;

  const _PriceRow({
    required this.price,
    required this.regularPrice,
    required this.isOnSale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: _AppTokens.gold,
            letterSpacing: -0.5,
            height: 1,
          ),
        ),
        if (isOnSale) ...[
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              '\$${regularPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                color: _AppTokens.textHint,
                decoration: TextDecoration.lineThrough,
                decorationColor: _AppTokens.textHint,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _AppTokens.errorLight,
                borderRadius: BorderRadius.circular(6),
                border:
                    Border.all(color: _AppTokens.errorBorder, width: 0.5),
              ),
              child: Text(
                '${(((regularPrice - price) / regularPrice) * 100).round()}% OFF',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _AppTokens.error,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  final double rating;
  const _RatingRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) => Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            i < rating.floor()
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            size: 15,
            color: _AppTokens.gold,
          ),
        )),
        const SizedBox(width: 8),
        Text(
          rating > 0
              ? rating.toStringAsFixed(1)
              : 'No reviews yet',
          style: const TextStyle(
            fontSize: 12,
            color: _AppTokens.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _VariantStockStatus extends StatelessWidget {
  final ProductVariant? variant;
  const _VariantStockStatus({required this.variant});

  @override
  Widget build(BuildContext context) {
    if (variant == null) {
      return Container(
        margin: const EdgeInsets.only(top: 4, bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _AppTokens.warningLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _AppTokens.warning.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 14, color: _AppTokens.warning),
            SizedBox(width: 8),
            Text(
              'Select options to see availability',
              style: TextStyle(fontSize: 12, color: _AppTokens.warning),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      child: Row(
        children: [
          _StockBadge(inStock: variant!.inStock),
          if (variant!.stockQuantity != null &&
              variant!.stockQuantity! <= 5) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _AppTokens.errorLight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: _AppTokens.errorBorder, width: 0.5),
              ),
              child: Text(
                'Only ${variant!.stockQuantity} left!',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _AppTokens.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoAttributes extends StatelessWidget {
  final List<ProductAttribute> attrs;
  const _InfoAttributes({required this.attrs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: attrs.map((attr) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: Text(
                attr.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _AppTokens.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Expanded(
              child: Text(
                attr.options.join(', '),
                style: const TextStyle(
                  fontSize: 12,
                  color: _AppTokens.textPrimary,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantitySelector({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QtyButton(
          icon: Icons.remove,
          onTap: quantity > 1 ? onDecrement : null,
        ),
        SizedBox(
          width: 52,
          child: Center(
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _AppTokens.textPrimary,
              ),
            ),
          ),
        ),
        _QtyButton(icon: Icons.add, onTap: onIncrement),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled ? _AppTokens.goldLight : _AppTokens.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled ? _AppTokens.goldBorder : _AppTokens.border,
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? _AppTokens.gold : _AppTokens.textHint,
        ),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  final Product product;
  const _Description({required this.product});

  @override
  Widget build(BuildContext context) {
    final desc = product.shortDescription ??
        product.description ??
        'No description available.';
    return Text(
      desc,
      style: const TextStyle(
        fontSize: 14,
        color: _AppTokens.textSecondary,
        height: 1.75,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        color: _AppTokens.textHint,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      color: _AppTokens.border,
      margin: const EdgeInsets.symmetric(vertical: 24),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated bottom bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final Animation<double> slide;
  final Animation<double> fade;
  final double displayPrice;
  final int quantity;
  final bool inStock;
  final bool isVariable;
  final bool allOptionsSelected;
  final VoidCallback onAddToCart;

  const _BottomBar({
    required this.slide,
    required this.fade,
    required this.displayPrice,
    required this.quantity,
    required this.inStock,
    required this.isVariable,
    required this.allOptionsSelected,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final canAdd = inStock && (!isVariable || allOptionsSelected);

    final String label = canAdd
        ? 'Add to Cart'
        : isVariable && !allOptionsSelected
            ? 'Select Options'
            : 'Out of Stock';

    return AnimatedBuilder(
      animation: slide,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, slide.value),
        child: Opacity(opacity: fade.value, child: child),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          14,
          24,
          14 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: _AppTokens.bg,
          border: Border(
            top: BorderSide(color: _AppTokens.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Total price column
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: _AppTokens.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${(displayPrice * quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _AppTokens.gold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            // CTA button
            Expanded(
              child: AppActionButton(
                onPressed: canAdd ? () async => onAddToCart() : null,
                enabled: canAdd,
                backgroundColor: _AppTokens.gold,
                foregroundColor: _AppTokens.bg,
                label: label.toUpperCase(),
                icon: canAdd ? Icons.shopping_bag_outlined : Icons.block_rounded,
                height: 52,
                borderRadius: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}