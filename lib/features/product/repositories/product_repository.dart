import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}

// ─── Repository ───────────────────────────────────────────────────────────────

final productRepositoryProvider = Provider((ref) => ProductRepository());

class ProductRepository {
  ProductRepository();

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Parses a raw JSON list into [Product]s. Guards against null/bad shapes.
  List<Product> _parseList(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  // ── GET /api/products ──────────────────────────────────────────────────────
  /// Paginated product list.
  /// Pass [category] to filter; [page] and [perPage] control pagination.
  Future<ProductsResult> getProducts({
    int page = 1,
    int perPage = 20,
    String? category,
    String? orderby,        // maps to `sort` on your backend
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    String? search,
  }) async {
    // If there's a search query, hit the search endpoint instead
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

    // Otherwise hit /api/products with filters
    final params = <String, String>{
      'page': '$page',
      'perPage': '$perPage',
      if (category != null && category.toUpperCase() != 'ALL')
        'category': category,
      if (orderby != null) 'sort': orderby,          // backend param is `sort`
      if (inStock == true) 'inStock': 'true',         // backend param is `inStock`
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
  }

  // ── GET /api/products/:id ──────────────────────────────────────────────────
  /// Single product by ID or slug.
  Future<Product> getProduct(String id) async {
    final data = await ApiClient.get(ApiEndpoints.product(id));
    return Product.fromJson(data['product'] as Map<String, dynamic>);
  }

  // ── GET /api/products/categories ──────────────────────────────────────────
  /// Returns raw category list from the BFF.
  /// Shape: { success: true, categories: [...] }
  Future<List<String>> getCategories() async {
    final data = await ApiClient.get(ApiEndpoints.categories);
    final raw = data['categories'];

    // Handle both List<String> and List<Map> with a "name" field
    if (raw is List) {
      return raw.map((e) {
        if (e is String) return e;
        if (e is Map) return (e['name'] ?? e['slug'] ?? '').toString();
        return e.toString();
      }).where((s) => s.isNotEmpty).toList();
    }

    return [];
  }

  // ── GET /api/products/featured ─────────────────────────────────────────────
  /// Returns { onSale[], topRated[], newArrivals[] }
  Future<FeaturedResult> getFeaturedProducts() async {
    final data = await ApiClient.get(ApiEndpoints.featuredProducts);

    return FeaturedResult(
      onSale: _parseList(data['onSale']),
      topRated: _parseList(data['topRated']),
      newArrivals: _parseList(data['newArrivals']),
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
  }
}