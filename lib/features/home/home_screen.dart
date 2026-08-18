// ── home_screen.dart ─────────────────────────────────────────────────────────
// Changes from original:
//   1. Added _scaffoldKey (GlobalKey<ScaffoldState>)
//   2. Added `drawer: const AppDrawer()` to Scaffold
//   3. Wrapped hamburger icon in GestureDetector → opens drawer
//   4. No other logic changed

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/shared/widgets/alert.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/utils/alert_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/network/api_exception.dart';
import '../../features/product/repositories/product_repository.dart';
import '../product/models/product_model.dart';
import '../shop/shop_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';

// Store
import 'store/recently_viewed_store.dart';
import 'store/search_history_store.dart';
import '../product/models/trending_search.dart';

// Widgets
import 'widgets/hero_banner.dart';
import '../../shared/widgets/shared_search_bar.dart';
import 'widgets/flash_sale_countdown.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/section_header.dart';
import 'widgets/cinematic_card.dart';
import 'widgets/featured_artist_banner.dart';
import '../../shared/widgets/shared_product_card.dart';
import 'widgets/best_sellers_grid.dart';
import 'widgets/recently_viewed_card.dart';
import 'widgets/search_result_tile.dart';
import 'widgets/search_discovery_view.dart';
import 'widgets/home_skeleton.dart';
import 'widgets/bottom_nav.dart';

// ── NEW ──
import '../info/app_drawer.dart';
import '../notifications/notification_sheet.dart';
import '../notifications/store/notification_store.dart';

export 'store/recently_viewed_store.dart';
export 'store/search_history_store.dart';



class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // ── NEW: key to open the drawer programmatically ──
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Data ──────────────────────────────────────────────────────────────────
  List<Product> _products = [];
  List<String> _categories = ['ALL'];
  bool _isInitialLoad = true;
  bool _isLoading = true;
  String? _error;

  // ── UI state ──────────────────────────────────────────────────────────────
  int _currentTab = 0;
  String _selectedCategory = 'ALL';
  final TextEditingController _searchController = TextEditingController();
  bool _searchActive = false;
  List<Product> _searchResults = [];
  bool _searchLoading = false;
  Timer? _searchDebounce;

  // ── Trending / Popular Searches ──
  TrendingTimeframe _trendingTimeframe = TrendingTimeframe.recent;
  List<TrendingItem> _trendingItems = [];
  bool _trendingLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
    SearchHistoryStore.load().then((_) {
      if (mounted) setState(() {});
    });
    _loadTrendingSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────
  Future<void> _loadTrendingSearches([TrendingTimeframe? tf]) async {
    final target = tf ?? _trendingTimeframe;
    setState(() {
      _trendingTimeframe = target;
      _trendingLoading = true;
    });
    try {
      final items = await ref
          .read(productRepositoryProvider)
          .getTrendingSearches(target);
      if (mounted) setState(() => _trendingItems = items);
    } catch (_) {
      if (mounted) setState(() => _trendingItems = []);
    } finally {
      if (mounted) setState(() => _trendingLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await ref.read(productRepositoryProvider).getCategories();
      if (mounted) setState(() => _categories = ['ALL', ...cats]);
    } catch (_) {}
  }

  Future<void> _loadProducts({String? category}) async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final products = await ref.read(productRepositoryProvider).getProducts(
        category: category == 'ALL' ? null : category,
      );
      if (mounted) setState(() {
        _products = products.products;
        _isInitialLoad = false;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'An unexpected error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onCategorySelected(String cat) {
    if (_selectedCategory == cat) return;
    setState(() => _selectedCategory = cat);
    _loadProducts(category: cat);
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchLoading = false;
      });
      return;
    }
    setState(() => _searchLoading = true);
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    _searchDebounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchLoading = false;
      });
      return;
    }

    SearchHistoryStore.add(trimmed).then((_) {
      if (mounted) setState(() {});
    });

    setState(() => _searchLoading = true);
    try {
      final results =
          await ref.read(productRepositoryProvider).searchProducts(trimmed);
      if (mounted) {
        setState(() => _searchResults = results.products);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _searchResults = []);
      }
    } finally {
      if (mounted) {
        setState(() => _searchLoading = false);
      }
    }
  }

  void _onSearchNavTap() {
    setState(() {
      _currentTab = 1;
      _searchActive = true;
    });
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  void _onTabChanged(int i) {
    setState(() {
      _currentTab = i;
      if (i != 1) {
        _searchActive = false;
        _searchController.clear();
        _searchResults = [];
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_error != null && !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AlertService.show(context, 'Network error: $_error',
            type: AlertType.error);
        setState(() => _error = null);
      });
    }

    final showAppBar = _currentTab == 0 ||
        (_currentTab == 1 && !_searchActive);

    final stackIndex = switch (_currentTab) {
      2 => 1,
      3 => 2,
      4 => 3,
      _ => 0,
    };

    return Scaffold(
      // ── NEW ──
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      // ─────────
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: showAppBar,
      appBar: showAppBar ? _buildAppBar() : null,
      body: Stack(
        children: [
          IndexedStack(
            index: stackIndex,
            children: [
                RepaintBoundary(child: _buildHomeBody()),
                const RepaintBoundary(child: ShopScreen()),
                const RepaintBoundary(child: CartScreen()),
                const RepaintBoundary(child: ProfileScreen()),
              ],
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: HomeBottomNav(
              currentTab: _currentTab,
              onTabChanged: _onTabChanged,
              onSearchTap: _onSearchNavTap,
            ),
          ),
        ],
      ),
    );
  }

  // ── Home body ─────────────────────────────────────────────────────────────
  Widget _buildHomeBody() {
    if (_isLoading && _isInitialLoad) return const HomeSkeleton();
    if (_searchActive) return _buildSearchResults();

    final trending = _products.take(4).toList();
    final newReleases = _products.skip(4).take(6).toList();
    final bestSellers = _products.reversed.take(6).toList();
    final recentlyViewed = RecentlyViewedStore.items;

    return _buildContent(trending, newReleases, bestSellers, recentlyViewed);
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── UPDATED: hamburger now opens drawer ──
              GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 2, width: 24, color: AppColors.onBackground),
                      const SizedBox(height: 6),
                      Container(height: 2, width: 16, color: AppColors.onBackground),
                    ],
                  ),
                ),
              ),
              // ────────────────────────────────────────
              Text(
                ref.watch(tenantBrandingProvider).appTitle.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  letterSpacing: 8.0,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onBackground,
                ),
              ),
              GestureDetector(
                onTap: () => showNotificationsSheet(context),
                child: Stack(
                  alignment: Alignment.topRight,
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(LucideIcons.bell, size: 24, color: AppColors.onBackground),
                    if (ref.watch(notificationProvider).any((n) => !n.isRead))
                      Positioned(
                        top: 0, right: 2,
                        child: Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
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

  Widget _buildContent(
    List<Product> trending,
    List<Product> newReleases,
    List<Product> bestSellers,
    List<Product> recentlyViewed,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroBanner(onShopTap: () => _onTabChanged(2)),
          const SizedBox(height: 20),
          SharedSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onSubmitted: (val) {
              setState(() => _searchActive = true);
              _performSearch(val);
            },
            onTap: () {
              setState(() => _searchActive = true);
              if (_searchController.text.trim().isNotEmpty) {
                _performSearch(_searchController.text);
              }
            },
            padding: const EdgeInsets.symmetric(horizontal: 24),
            hintText: 'Search albums, merch, artists...',
          ),
          const SizedBox(height: 20),
          const FlashSaleCountdown(),
          const SizedBox(height: 32),
          CategoryFilterBar(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: _onCategorySelected,
          ),
          const SizedBox(height: 32),
          if (_isLoading && !_isInitialLoad) ...[
            const ProductSectionSkeleton(),
            const SizedBox(height: 48),
            const ProductSectionSkeleton(),
            const SizedBox(height: 48),
          ] else ...[
            if (trending.isNotEmpty) ...[
              SectionHeader(title: 'Trending Albums', onViewAll: () => _onTabChanged(2)),
              const SizedBox(height: 20),
              SizedBox(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: trending.length,
                  itemBuilder: (_, i) => CinematicCard(product: trending[i]),
                ),
              ),
              const SizedBox(height: 48),
            ],
            const FeaturedArtistBanner(),
            const SizedBox(height: 48),
            if (newReleases.isNotEmpty) ...[
              SectionHeader(title: 'New Releases', onViewAll: () => _onTabChanged(2)),
              const SizedBox(height: 20),
              SizedBox(
                height: 310,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: newReleases.length,
                  itemBuilder: (_, i) => SharedProductCard(product: newReleases[i], variant: ProductCardVariant.horizontal),
                ),
              ),
              const SizedBox(height: 48),
            ],
            if (bestSellers.isNotEmpty) ...[
              SectionHeader(title: 'Best Sellers', onViewAll: () => _onTabChanged(2)),
              const SizedBox(height: 20),
              BestSellersGrid(products: bestSellers),
              const SizedBox(height: 48),
            ],
            if (recentlyViewed.isNotEmpty) ...[
              SectionHeader(title: 'Recently Viewed', onViewAll: () {}),
              const SizedBox(height: 20),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: recentlyViewed.length,
                  itemBuilder: (_, i) => RecentlyViewedCard(product: recentlyViewed[i]),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final queryText = _searchController.text.trim();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 24, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _searchActive = false;
                      _searchController.clear();
                      _searchResults = [];
                      _currentTab = 0;
                    });
                  },
                ),
                Expanded(
                  child: SharedSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onSubmitted: (val) => _performSearch(val),
                    autofocus: true,
                    padding: EdgeInsets.zero,
                    hintText: 'Search albums, merch, artists...',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_searchLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (queryText.isEmpty)
            Expanded(
              child: SearchDiscoveryView(
                recentSearches: SearchHistoryStore.history,
                selectedTimeframe: _trendingTimeframe,
                trendingItems: _trendingItems,
                isTrendingLoading: _trendingLoading,
                onTimeframeChanged: (tf) => _loadTrendingSearches(tf),
                onSelectQuery: (q) {
                  _searchController.text = q;
                  _performSearch(q);
                },
                onRemoveRecent: (q) async {
                  await SearchHistoryStore.remove(q);
                  if (mounted) setState(() {});
                },
                onClearRecent: () async {
                  await SearchHistoryStore.clear();
                  if (mounted) setState(() {});
                },
              ),
            )
          else if (_searchResults.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.searchX, size: 40, color: AppColors.onSurfaceVariant),
                    const SizedBox(height: 12),
                    Text(
                      'No results for "$queryText"',
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: _searchResults.length,
                itemBuilder: (_, i) => SearchResultTile(product: _searchResults[i]),
              ),
            ),
        ],
      ),
    );
  }
}