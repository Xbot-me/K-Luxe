enum SortOption { newest, priceLow, priceHigh, popular,nameAz  }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.newest:
        return 'Newest';
      case SortOption.priceLow:
        return 'Price: Low to High';
      case SortOption.priceHigh:
        return 'Price: High to Low';
      case SortOption.popular:  return 'Top Rated';
      case SortOption.nameAz:   return 'Name: A–Z';
    }
  }

  String get apiValue {
    switch (this) {
      case SortOption.newest:
        return 'newest';
      case SortOption.priceLow:
        return 'price_asc';
      case SortOption.priceHigh:
        return 'price_desc';
      case SortOption.popular:  return 'rating';
      case SortOption.nameAz:   return 'name_asc';
    }
  }
}

class ShopFilterState {
  final String category;
  final SortOption sort;
  final double minPrice;
  final double maxPrice;
  final bool inStockOnly;

  const ShopFilterState({
    this.category = 'ALL',
    this.sort = SortOption.newest,
    this.minPrice = 0,
    this.maxPrice = 500,
    this.inStockOnly = false,
  });

  bool get hasActiveFilters =>
      category != 'ALL' ||
      sort != SortOption.newest ||
      minPrice > 0 ||
      maxPrice < 500 ||
      inStockOnly;

  ShopFilterState copyWith({
    String? category,
    SortOption? sort,
    double? minPrice,
    double? maxPrice,
    bool? inStockOnly,
  }) {
    return ShopFilterState(
      category: category ?? this.category,
      sort: sort ?? this.sort,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      inStockOnly: inStockOnly ?? this.inStockOnly,
    );
  }

  ShopFilterState reset() => const ShopFilterState();

  @override
  bool operator ==(Object other) =>
      other is ShopFilterState &&
      other.category == category &&
      other.sort == sort &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.inStockOnly == inStockOnly;

  @override
  int get hashCode => Object.hash(category, sort, minPrice, maxPrice, inStockOnly);
}