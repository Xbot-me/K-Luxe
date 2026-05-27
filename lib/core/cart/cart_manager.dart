import 'package:flutter/foundation.dart';
import '../../features/cart/repositories/cart_repository.dart';
import '../../features/product/models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;
  final int colorIndex;
  final String? variantId;
  final Map<String, String> selectedOptions;
  String? cartKey;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.colorIndex = 0,
    this.variantId,
    this.selectedOptions = const {},
    this.cartKey,
  });

  double get unitPrice {
    if (variantId == null) return product.price;
    return product.variants
            .where((v) => v.id == variantId)
            .firstOrNull
            ?.price ??
        product.price;
  }

  double get totalPrice => unitPrice * quantity;

  String get variantLabel {
    if (selectedOptions.isEmpty) return '';
    return selectedOptions.entries
        .map((e) => '${_capitalise(e.key)}: ${e.value}')
        .join(' · ');
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class CartManager {
  CartManager._();

  static final List<CartItem> _items = [];
  static List<CartItem> get items => List.unmodifiable(_items);

  // ── Reactive notifier — listen to this for live cart count updates ──────
  // Usage: ValueListenableBuilder<int>(
  //   valueListenable: CartManager.countNotifier,
  //   builder: (ctx, count, _) => Text('$count'),
  // )
  static final ValueNotifier<int> countNotifier = ValueNotifier<int>(0);

  static void _notifyCount() {
    countNotifier.value = _items.fold(0, (sum, i) => sum + i.quantity);
  }

  static int get itemCount => countNotifier.value;

  static double get subtotal =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  static String? get cartToken => CartRepository.instance.cartToken;

  // ── Add ─────────────────────────────────────────────────────────────────
  static Future<void> addProduct(
    Product product, {
    int colorIndex = 0,
    String? variantId,
    Map<String, String> selectedOptions = const {},
  }) async {
    final newKey = await CartRepository.instance.addItem(
      productId: product.id,
      quantity: 1,
      variantId: variantId,
      selectedOptions: selectedOptions,
    );

    if (newKey == null) {
      debugPrint('Failed to add product to cart on server');
      return;
    }

    _items.add(CartItem(
      product: product,
      colorIndex: colorIndex,
      variantId: variantId,
      selectedOptions: selectedOptions,
      cartKey: newKey,
      quantity: 1,
    ));

    _notifyCount(); // ← triggers all ValueListenableBuilder listeners
  }

  // ── Remove ───────────────────────────────────────────────────────────────
  static Future<void> removeItem(String productId, {String? variantId}) async {
    final item = _items.firstWhere(
      (i) => i.product.id == productId && i.variantId == variantId,
      orElse: () => throw Exception('Item not found'),
    );
    final key = item.cartKey;
    if (key == null) {
      debugPrint('Cannot remove: cartKey is null.');
      return;
    }
    _items.remove(item);
    _notifyCount();
    await CartRepository.instance.removeItem(key);
  }

  // ── Update quantity ──────────────────────────────────────────────────────
  static Future<void> updateQuantity(
    String productId,
    int newQty, {
    String? variantId,
  }) async {
    final index = _items.indexWhere(
      (i) => i.product.id == productId && i.variantId == variantId,
    );
    if (index < 0) return;
    final item = _items[index];
    if (item.cartKey == null) return;
    if (newQty <= 0) {
      await removeItem(productId, variantId: variantId);
      return;
    }
    item.quantity = newQty;
    _notifyCount();
    await CartRepository.instance.updateItem(
      productId: productId,
      quantity: newQty,
      cartKey: item.cartKey,
    );
  }

  // ── Clear ────────────────────────────────────────────────────────────────
  static void clear() {
    _items.clear();
    _notifyCount();
    _syncClear();
  }

  // ── Init from BFF on app start ───────────────────────────────────────────
  static Future<void> init() async {
    try {
      await CartRepository.instance.initCart();
      final bffItems = await CartRepository.instance.getCart();
      _items.clear();
      for (final item in bffItems) {
        _items.add(CartItem(
          product: item.toProduct(),
          quantity: item.quantity,
          variantId: item.variantId,
          selectedOptions: item.selectedOptions,
          cartKey: item.key,
        ));
      }
      _notifyCount();
    } catch (e) {
      debugPrint('Cart init failed: $e');
    }
  }

  // ── Private BFF sync ─────────────────────────────────────────────────────
  static Future<void> _syncRemove(String productId, {String? cartKey}) async {
    try {
      await CartRepository.instance.removeItem(productId);
    } catch (e) {
      debugPrint('Cart sync remove failed: $e');
    }
  }

  static Future<void> _syncUpdate(
    String productId,
    int quantity, {
    String? variantId,
    String? cartKey,
  }) async {
    try {
      await CartRepository.instance.updateItem(
        productId: productId,
        quantity: quantity,
        variantId: variantId,
        cartKey: cartKey,
      );
    } catch (e) {
      debugPrint('Cart sync update failed: $e');
    }
  }

  static Future<void> _syncClear() async {
    try {
      await CartRepository.instance.clearCart();
    } catch (e) {
      debugPrint('Cart sync clear failed: $e');
    }
  }
}