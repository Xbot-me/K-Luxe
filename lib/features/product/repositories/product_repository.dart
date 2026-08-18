import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/cache/local_cache_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/product_model.dart';

// ─── Response Models ──────────────────────────────────────────────────────────

class ProductsResult {
  final List<Product> products;
  final int total;
  final int totalPages;

  const ProductsResult({
    required this.products,
    required this.total,
    required this.totalPages,
  });

  Map<String, dynamic> toJson() => {
    'products': products.map((e) => e.toJson()).toList(),
    'total': total,
    'totalPages': totalPages,
  };

  factory ProductsResult.fromJson(Map<String, dynamic> j) {
    final rawList = (j['products'] ?? j['results']) as List<dynamic>? ?? [];
    return ProductsResult(
      products: rawList
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      total: (j['total'] as num?)?.toInt() ?? rawList.length,
      totalPages: (j['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class SearchResult {
  final List<Product> products;
  final int total;
  final int totalPages;

  const SearchResult({
    required this.products,
    required this.total,
    required this.totalPages,
  });

  Map<String, dynamic> toJson() => {
    'products': products.map((e) => e.toJson()).toList(),
    'total': total,
    'totalPages': totalPages,
  };

  factory SearchResult.fromJson(Map<String, dynamic> j) {
    final rawList = (j['results'] ?? j['products']) as List<dynamic>? ?? [];
    return SearchResult(
      products: rawList
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      total: (j['total'] as num?)?.toInt() ?? rawList.length,
      totalPages: (j['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class FeaturedResult {
  final List<Product> onSale;
  final List<Product> topRated;
  final List<Product> newArrivals;

  const FeaturedResult({
    required this.onSale,
    required this.topRated,
    required this.newArrivals,
  });

  Map<String, dynamic> toJson() => {
    'onSale': onSale.map((e) => e.toJson()).toList(),
    'topRated': topRated.map((e) => e.toJson()).toList(),
    'newArrivals': newArrivals.map((e) => e.toJson()).toList(),
  };

  factory FeaturedResult.fromJson(Map<String, dynamic> j) {
    List<Product> parse(dynamic raw) {
      if (raw is! List) return [];
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return FeaturedResult(
      onSale: parse(j['onSale']),
      topRated: parse(j['topRated']),
      newArrivals: parse(j['newArrivals']),
    );
  }
}

// ─── Repository ───────────────────────────────────────────────────────────────

final productRepositoryProvider = Provider((ref) => ProductRepository());

class ProductRepository {
  final LocalCacheService _cache;

  ProductRepository({LocalCacheService? cache})
      : _cache = cache ?? LocalCacheService.instance;

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Parses a raw JSON list into [Product]s. Guards against null/bad shapes.
  List<Product> _parseList(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ── GET /api/products ──────────────────────────────────────────────────────
  /// Paginated product list with Stale-While-Revalidate caching.
  Future<ProductsResult> getProducts({
    int page = 1,
    int perPage = 20,
    String? category,
    String? orderby,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    String? search,
  }) async {
    final cacheKey =
        'products_p${page}_pp${perPage}_c${category ?? 'all'}_o${orderby ?? 'default'}_min${minPrice ?? 0}_max${maxPrice ?? 0}_stk${inStock ?? false}_s${search ?? ''}';

    return _cache.fetchWithSWR<ProductsResult>(
      boxName: LocalCacheService.boxProductLists,
      key: cacheKey,
      ttl: const Duration(minutes: 3),
      networkFetcher: () async {
        if (search != null && search.isNotEmpty) {
          final data = await ApiClient.get(
            ApiEndpoints.searchProducts,
            queryParams: {
              'q': search,
              'page': '$page',
              'perPage': '$perPage',
            },
          );
          return ProductsResult(
            products: _parseList(data['results'] ?? data['products']),
            total: (data['total'] as num?)?.toInt() ?? 0,
            totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
          );
        }

        final params = <String, String>{
          'page': '$page',
          'perPage': '$perPage',
          if (category != null && category.toUpperCase() != 'ALL')
            'category': category,
          if (orderby != null) 'sort': orderby,
          if (inStock == true) 'inStock': 'true',
          if (minPrice != null && minPrice > 0)
            'min_price': minPrice.toStringAsFixed(0),
          if (maxPrice != null && maxPrice < 500)
            'max_price': maxPrice.toStringAsFixed(0),
        };

        final data = await ApiClient.get(
          ApiEndpoints.products,
          queryParams: params,
        );

        return ProductsResult(
          products: _parseList(data['products']),
          total: (data['total'] as num?)?.toInt() ?? 0,
          totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
        );
      },
      deserializer: (data) =>
          ProductsResult.fromJson(Map<String, dynamic>.from(data as Map)),
      serializer: (result) => result.toJson(),
    );
  }

  // ── GET /api/products/:id ──────────────────────────────────────────────────
  /// Single product by ID or slug with SWR & in-flight deduplication.
  Future<Product> getProduct(String id) async {
    return _cache.fetchWithSWR<Product>(
      boxName: LocalCacheService.boxProducts,
      key: id,
      ttl: const Duration(minutes: 5),
      networkFetcher: () async {
        final data = await ApiClient.get(ApiEndpoints.product(id));
        return Product.fromJson(
          Map<String, dynamic>.from(data['product'] as Map),
        );
      },
      deserializer: (data) =>
          Product.fromJson(Map<String, dynamic>.from(data as Map)),
      serializer: (product) => product.toJson(),
    );
  }

  // ── GET /api/products/categories ──────────────────────────────────────────
  /// Category list with SWR (20 min TTL).
  Future<List<String>> getCategories() async {
    return _cache.fetchWithSWR<List<String>>(
      boxName: LocalCacheService.boxCategories,
      key: 'all_categories',
      ttl: const Duration(minutes: 20),
      networkFetcher: () async {
        final data = await ApiClient.get(ApiEndpoints.categories);
        final raw = data['categories'];

        if (raw is List) {
          return raw.map((e) {
            if (e is String) return e;
            if (e is Map) return (e['name'] ?? e['slug'] ?? '').toString();
            return e.toString();
          }).where((s) => s.isNotEmpty).toList();
        }

        return [];
      },
      deserializer: (data) =>
          (data as List).map((e) => e.toString()).toList(),
      serializer: (categories) => categories,
    );
  }

  // ── GET /api/products/featured ─────────────────────────────────────────────
  /// Featured products with SWR (5 min TTL).
  Future<FeaturedResult> getFeaturedProducts() async {
    return _cache.fetchWithSWR<FeaturedResult>(
      boxName: LocalCacheService.boxProductLists,
      key: 'featured_products',
      ttl: const Duration(minutes: 5),
      networkFetcher: () async {
        final data = await ApiClient.get(ApiEndpoints.featuredProducts);
        return FeaturedResult(
          onSale: _parseList(data['onSale']),
          topRated: _parseList(data['topRated']),
          newArrivals: _parseList(data['newArrivals']),
        );
      },
      deserializer: (data) =>
          FeaturedResult.fromJson(Map<String, dynamic>.from(data as Map)),
      serializer: (result) => result.toJson(),
    );
  }

  // ── GET /api/products/search?q=&page=&perPage= ────────────────────────────
  /// Full-text product search with pagination.
  Future<SearchResult> searchProducts(
    String query, {
    int page = 1,
    int perPage = 20,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const SearchResult(products: [], total: 0, totalPages: 0);
    }

    final cacheKey = 'search_${trimmed.toLowerCase()}_p${page}_pp$perPage';

    return _cache.fetchWithSWR<SearchResult>(
      boxName: LocalCacheService.boxProductLists,
      key: cacheKey,
      ttl: const Duration(minutes: 1), // Search results 1-min TTL
      networkFetcher: () async {
        final params = <String, String>{
          'q': trimmed,
          'page': '$page',
          'perPage': '$perPage',
        };

        final data = await ApiClient.get(
          ApiEndpoints.searchProducts,
          queryParams: params,
        );

        return SearchResult(
          products: _parseList(data['results'] ?? data['products']),
          total: (data['total'] as num?)?.toInt() ?? 0,
          totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
        );
      },
      deserializer: (data) =>
          SearchResult.fromJson(Map<String, dynamic>.from(data as Map)),
      serializer: (result) => result.toJson(),
    );
  }
}