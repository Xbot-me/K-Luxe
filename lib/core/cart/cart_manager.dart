import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../features/cart/repositories/cart_repository.dart';
import '../../features/product/models/product_model.dart';

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

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

  CartItem copyWith({
    Product? product,
    int? quantity,
    int? colorIndex,
    String? variantId,
    Map<String, String>? selectedOptions,
    String? cartKey,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      colorIndex: colorIndex ?? this.colorIndex,
      variantId: variantId ?? this.variantId,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      cartKey: cartKey ?? this.cartKey,
    );
  }

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

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [];
  }

  int get itemCount => state.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => state.fold(0, (sum, item) => sum + item.totalPrice);
  String? get cartToken => ref.read(cartRepositoryProvider).cartToken;

  Future<void> initCart() async {
    try {
      final repo = ref.read(cartRepositoryProvider);
      await repo.initCart();
      final bffItems = await repo.getCart();
      state = bffItems.map((item) => CartItem(
        product: item.toProduct(),
        quantity: item.quantity,
        variantId: item.variantId,
        selectedOptions: item.selectedOptions,
        cartKey: item.key,
      )).toList();
    } catch (e) {
      debugPrint('Cart init failed: $e');
    }
  }

  Future<void> mergeAndReloadCart() async {
    try {
      final repo = ref.read(cartRepositoryProvider);
      final guestToken = repo.cartToken;
      if (guestToken != null && guestToken.isNotEmpty) {
        await repo.mergeCart(guestToken);
      }
      await initCart();
    } catch (e) {
      debugPrint('Cart mergeAndReload failed: $e');
      await initCart();
    }
  }

  Future<void> addProduct(
    Product product, {
    int colorIndex = 0,
    String? variantId,
    Map<String, String> selectedOptions = const {},
  }) async {
    final repo = ref.read(cartRepositoryProvider);
    final newKey = await repo.addItem(
      productId: product.id,
      quantity: 1,
      variantId: variantId,
      selectedOptions: selectedOptions,
    );

    if (newKey == null) {
      debugPrint('Failed to add product to cart on server');
      return;
    }

    state = [
      ...state,
      CartItem(
        product: product,
        colorIndex: colorIndex,
        variantId: variantId,
        selectedOptions: selectedOptions,
        cartKey: newKey,
        quantity: 1,
      )
    ];
  }

  Future<void> removeItem(String productId, {String? variantId}) async {
    final item = state.firstWhere(
      (i) => i.product.id == productId && i.variantId == variantId,
      orElse: () => throw Exception('Item not found'),
    );
    final key = item.cartKey;
    if (key == null) {
      debugPrint('Cannot remove: cartKey is null.');
      return;
    }

    state = state.where((i) => i != item).toList();
    await ref.read(cartRepositoryProvider).removeItem(key);
  }

  Future<void> updateQuantity(
    String productId,
    int newQty, {
    String? variantId,
  }) async {
    final index = state.indexWhere(
      (i) => i.product.id == productId && i.variantId == variantId,
    );
    if (index < 0) return;
    final item = state[index];
    if (item.cartKey == null) return;
    if (newQty <= 0) {
      await removeItem(productId, variantId: variantId);
      return;
    }
    
    // Update local state by copying
    final updatedList = List<CartItem>.from(state);
    updatedList[index] = item.copyWith(quantity: newQty);
    state = updatedList;

    await ref.read(cartRepositoryProvider).updateItem(
      productId: productId,
      quantity: newQty,
      cartKey: item.cartKey,
    );
  }

  void clear() {
    state = [];
    _syncClear();
  }

  Future<void> _syncClear() async {
    try {
      await ref.read(cartRepositoryProvider).clearCart();
    } catch (e) {
      debugPrint('Cart sync clear failed: $e');
    }
  }
}