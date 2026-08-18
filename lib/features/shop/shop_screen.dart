import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/shared/widgets/alert.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/utils/alert_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../features/product/repositories/product_repository.dart';
import '../product/models/product_model.dart';
import '../../core/cart/cart_manager.dart';
import 'models/shop_filter_state.dart';
import '../../shared/widgets/shared_search_bar.dart';
import 'widgets/shop_promo_banner.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/active_filter_chips.dart';
import '../../shared/widgets/shared_product_card.dart';
import 'widgets/shop_skeleton.dart';

class ShopScreen extends ConsumerStatefulWidget {
  /// Optional: pre-select a category when navigating from home (e.g. /shop?category=albums)
  final String? initialCategory;

  const ShopScreen({super.key, this.initialCategory});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with AutomaticKeepAliveClientMixin {
  // ── Data ────────────────────────────────────────────────────────────────────
  List<Product> _products = [];
  List<String> _categories = ['ALL'];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _page = 1;
  static const int _pageSize = 20;

  // ── Filter / search state ────────────────────────────────────────────────
  late ShopFilterState _filters;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';

  // ── Scroll ───────────────────────────────────────────────────────────────
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _filters = ShopFilterState(category: widget.initialCategory ?? 'ALL');
    _loadCategories();
    _loadProducts(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll listener for infinite scroll ──────────────────────────────────
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  // ── Data loading ─────────────────────────────────────────────────────────
  Future<void> _loadCategories() async {
    try {
      final cats = await ref.read(productRepositoryProvider).getCategories();
      if (mounted) setState(() => _categories = ['ALL', ...cats]);
    } catch (_) {}
  }

  Future<void> _loadProducts({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _page = 1;
        _hasMore = true;
        _products = [];
      });
    }

    try {
      final result = await ref.read(productRepositoryProvider).getProducts(
        category: _filters.category == 'ALL' ? null : _filters.category,
        orderby: _filters.sort.apiValue,
        minPrice: _filters.minPrice > 0 ? _filters.minPrice : null,
        maxPrice: _filters.maxPrice < 500 ? _filters.maxPrice : null,
        inStock: _filters.inStockOnly ? true : null,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        page: _page,
        perPage: _pageSize,
      );

      if (mounted) {
        setState(() {
          if (reset) {
            _products = result.products;
          } else {
            _products = [..._products, ...result.products];
          }
          _hasMore = result.products.length == _pageSize;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'An unexpected error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    setState(() {
      _isLoadingMore = true;
      _page++;
    });
    await _loadProducts();
    if (mounted) setState(() => _isLoadingMore = false);
  }

  Future<void> _onRefresh() async {
    await _loadProducts(reset: true);
  }

  // ── Search ────────────────────────────────────────────────────────────────
  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted && query != _searchQuery) {
        setState(() => _searchQuery = query.trim());
        _loadProducts(reset: true);
      }
    });
  }

  // ── Filter ────────────────────────────────────────────────────────────────
  void _onFiltersApplied(ShopFilterState updated) {
    if (updated == _filters) return;
    setState(() => _filters = updated);
    _loadProducts(reset: true);
  }

  @override
  bool get wantKeepAlive => true;
  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_error != null && !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AlertService.show(context, 'Error: $_error', type: AlertType.error);
        setState(() => _error = null);
      });
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // ── App bar ──────────────────────────────────────────────────
            _buildAppBar(),
            const SizedBox(height: 12),

            // ── Promo banner ─────────────────────────────────────────────
            const ShopPromoBanner(),
            const SizedBox(height: 12),

            // ── Search + filter ──────────────────────────────────────────
            SharedSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              hasActiveFilters: _filters.hasActiveFilters,
              hintText: 'Search products...',
              onFilterTap: () => FilterBottomSheet.show(
                context,
                initial: _filters,
                categories: _categories,
                onApply: _onFiltersApplied,
              ),
            ),
            const SizedBox(height: 10),

            // ── Active filter chips ───────────────────────────────────────
            ActiveFilterChips(
              filters: _filters,
              onClearAll: () {
                setState(() => _filters = _filters.reset());
                _loadProducts(reset: true);
              },
              onRemove: _onFiltersApplied,
            ),

            if (_filters.hasActiveFilters) const SizedBox(height: 10),

            // ── Result count ─────────────────────────────────────────────
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _hasMore
                      ? '${_products.length}+ products'
                      : '${_products.length} product${_products.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),

            if (!_isLoading) const SizedBox(height: 10),

            // ── Grid ─────────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const ShopSkeleton()
                  : _products.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      child: GridView.builder(
                        controller: _scrollController,
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              mainAxisExtent: 280,
                            ),
                        itemCount: _products.length + (_isLoadingMore ? 2 : 0),
                        itemBuilder: (_, i) {
                          if (i >= _products.length) {
                            // Skeleton placeholders at the bottom while loading more
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                              ),
                            );
                          }
                          return SharedProductCard(product: _products[i], variant: ProductCardVariant.shopGrid);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shop',
                  style: TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Explore the full collection',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Cart shortcut
          Consumer(
            builder: (context, ref, _) {
              final count = ref.watch(cartProvider).fold(0, (sum, i) => sum + i.quantity);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.shoppingBag,
                      color: AppColors.onBackground,
                      size: 20,
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasQuery = _searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasQuery ? LucideIcons.searchX : LucideIcons.packageOpen,
              size: 48,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              hasQuery ? 'No results for "$_searchQuery"' : 'No products found',
              style: const TextStyle(
                color: AppColors.onBackground,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your filters or search terms',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_filters.hasActiveFilters || hasQuery)
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _filters = _filters.reset();
                    _searchQuery = '';
                  });
                  _loadProducts(reset: true);
                },
                child: const Text(
                  'Clear all filters',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
