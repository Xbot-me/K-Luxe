// Built to exactly match your BFF response shape.
// Field names match your JSON keys via fromJson factory.
class ProductVariant {
  final String id;
  final String? sku;
  final double price;
  final double regularPrice;
  final String stockStatus;
  final int? stockQuantity;
  final Map<String, String> selectedOptions;
  final ProductImage? image;

  const ProductVariant({
    required this.id,
    this.sku,
    required this.price,
    required this.regularPrice,
    required this.stockStatus,
    this.stockQuantity,
    required this.selectedOptions,
    this.image,
  });

  bool get inStock => stockStatus == 'instock';

  bool matchesSelection(Map<String, String> selection) {
    for (final entry in selection.entries) {
      final variantValue = selectedOptions[entry.key]?.toLowerCase();
      final selectedValue = entry.value.toLowerCase();
      if (variantValue != selectedValue) return false;
    }
    return true;
  }

  factory ProductVariant.fromJson(Map<String, dynamic> j) {
    final rawOptions = j['selectedOptions'] as Map<String, dynamic>? ?? {};
    final options = rawOptions.map(
      (key, value) => MapEntry(key.toLowerCase(), value.toString()),
    );

    ProductImage? image;
    if (j['image'] != null) {
      image = ProductImage.fromJson(j['image'] as Map<String, dynamic>);
    }
    final price = (j['price'] as num).toDouble();

    return ProductVariant(
      id: j['id'].toString(),
      sku: j['sku'] as String?,
      image: image,
      stockQuantity: j['stockQuantity'] as int?,
      price: price,
      regularPrice:(j['regularPrice'] as num?)?.toDouble() ?? price,
      stockStatus: j['stockStatus'] as String? ?? 'outofstock',
      selectedOptions: options,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (sku != null) 'sku': sku,
    'price': price,
    'regularPrice': regularPrice,
    'stockStatus': stockStatus,
    if (stockQuantity != null) 'stockQuantity': stockQuantity,
    'selectedOptions': selectedOptions,
    if (image != null) 'image': image!.toJson(),
  };
}

class ProductAttribute {
  final String name;
  final String key;
  final List<String> options;
  final bool usedForVariations;

  const ProductAttribute({
    required this.name,
    required this.key,
    required this.options,
    this.usedForVariations = true,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> j) {
    final name = j['name'] as String;
    final rawOptions = (j['values'] ?? j['options']) as List<dynamic>? ?? [];
    return ProductAttribute(
      name: name,
      key: (j['key'] as String? ?? name).toLowerCase(), 
      options: rawOptions.map((e) => e.toString()).toList(),
      usedForVariations: j['usedForVariations'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'key': key,
    'values': options,
    'usedForVariations': usedForVariations,
  };
}

class ProductImage {
  final String id;
  final String url;
  final String alt;

  const ProductImage({required this.id, required this.url, required this.alt});

  factory ProductImage.fromJson(Map<String, dynamic> j) => ProductImage(
    id: (j['id'] ?? '').toString(),
    url: j['url'] as String? ?? '',
    alt: j['alt'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'alt': alt,
  };
}

class PriceRange {
  final double min;
  final double max;

  const PriceRange({required this.min, required this.max});

  factory PriceRange.fromJson(Map<String, dynamic> j) => PriceRange(
    min: (j['min'] as num).toDouble(),
    max: (j['max'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'min': min,
    'max': max,
  };
}

// Product type matches WooCommerce types your BFF already returns
enum ProductType { simple, variable, grouped, external }

class Product {
  final String id;
  final String slug;
  final String name;
  final ProductType type;
  final double price;
  final double regularPrice;
  final PriceRange? priceRange;
  final bool onSale;
  final String stockStatus; // "instock" | "outofstock" | "onbackorder"
  final int? stockQuantity;
  final ProductImage featuredImage;
  final String category;
  final double averageRating;
  final String? description;
  final String? shortDescription;
  final List<ProductImage> images;

  final List<ProductVariant> variants;
  final List<ProductAttribute> attributes;

  // Artist field
  final String? artist;

  const Product({
    required this.id,
    required this.slug,
    required this.name,
    required this.type,
    required this.price,
    required this.regularPrice,
    this.priceRange,
    required this.onSale,
    required this.stockStatus,
    this.stockQuantity,
    required this.featuredImage,
    required this.category,
    required this.averageRating,
    this.description,
    this.shortDescription,
    this.images = const [],

    this.variants = const [],
    this.attributes = const [],

    this.artist,
  });

  // ── Convenience getters ──

  bool get inStock => stockStatus == 'instock';
  bool get isVariable => type == ProductType.variable;

  List<String> get variationOptions {
    if (attributes.isEmpty) return [];
    return attributes.first.options;
  }

  String get variationAttributeName {
    if (attributes.isEmpty) return 'OPTION';
    return attributes.first.name.toUpperCase();
  }

  ProductVariant? variantForOption(String optionValue) {
    if (variants.isEmpty) return null;
    final attrKey = attributes.first.key;
    try {
      return variants.firstWhere(
        (v) => v.selectedOptions[attrKey]?.toLowerCase() ==
            optionValue.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  List<ProductAttribute> get variationAttributes =>
      attributes.where((a) => a.usedForVariations).toList();

  List<ProductAttribute> get infoAttributes =>
      attributes.where((a) => !a.usedForVariations).toList();

  // Only show discount when actually on sale
  int? get discountPercent {
    if (!onSale || regularPrice <= 0) return null;
    return (((regularPrice - price) / regularPrice) * 100).round();
  }

  // Display image — first from images list, fallback to featuredImage
  String get displayImageUrl =>
      images.isNotEmpty ? images.first.url : featuredImage.url;

  ProductVariant? findVariant(Map<String, String> selection) {
    if (variants.isEmpty) return null;
    try {
      return variants.firstWhere((v) => v.matchesSelection(selection));
    } catch (_) {
      return null;
    }
  }

  // fromJson maps your exact JSON field names to Dart fields
  factory Product.fromJson(Map<String, dynamic> j) {
    // Parse type safely — default to simple if unknown
    final typeStr = j['type'] as String? ?? 'simple';
    
    final type = ProductType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => ProductType.simple,
    );

    // Images list — only present on single product endpoint
    final rawImages = j['images'] as List<dynamic>? ?? [];
    final rawVariants = j['variants'] as List<dynamic>? ?? [];
    final rawAttributes = (j['options'] as List<dynamic>?)
    ?? (j['attributes'] as List<dynamic>?)
    ?? [];

    return Product(
      id: j['id'] as String,
      slug: j['slug'] as String,
      name: j['name'] as String,
      type: type,
      price: (j['price'] as num).toDouble(),
      regularPrice: (j['regularPrice'] as num).toDouble(),
      priceRange: j['priceRange'] != null
          ? PriceRange.fromJson(j['priceRange'] as Map<String, dynamic>)
          : null,
      onSale: j['onSale'] as bool? ?? false,
      stockStatus: j['stockStatus'] as String? ?? 'outofstock',
      stockQuantity: j['stockQuantity'] as int?,
      featuredImage: ProductImage.fromJson(
        j['featuredImage'] as Map<String, dynamic>,
      ),
      category: j['category'] as String? ?? '',
      averageRating: (j['averageRating'] as num?)?.toDouble() ?? 0.0,
      description: j['description'] as String?,
      shortDescription: j['shortDescription'] as String?,
      artist: j['artist'] as String?,
      images: rawImages
          .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      variants: rawVariants
          .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
          .toList(),
      attributes: rawAttributes
          .map((e) => ProductAttribute.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'name': name,
    'type': type.name,
    'price': price,
    'regularPrice': regularPrice,
    if (priceRange != null) 'priceRange': priceRange!.toJson(),
    'onSale': onSale,
    'stockStatus': stockStatus,
    if (stockQuantity != null) 'stockQuantity': stockQuantity,
    'featuredImage': featuredImage.toJson(),
    'category': category,
    'averageRating': averageRating,
    if (description != null) 'description': description,
    if (shortDescription != null) 'shortDescription': shortDescription,
    if (artist != null) 'artist': artist,
    'images': images.map((e) => e.toJson()).toList(),
    'variants': variants.map((e) => e.toJson()).toList(),
    'attributes': attributes.map((e) => e.toJson()).toList(),
  };
}
