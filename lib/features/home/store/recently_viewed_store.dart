import '../../product/models/product_model.dart';

class RecentlyViewedStore {
  RecentlyViewedStore._();
  static final List<Product> _items = [];
  static List<Product> get items => List.unmodifiable(_items);

  static void add(Product p) {
    _items.removeWhere((e) => e.id == p.id);
    _items.insert(0, p);
    if (_items.length > 10) _items.removeLast();
  }
}
