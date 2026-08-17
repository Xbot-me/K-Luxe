import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/cart_item_model.dart';
import 'package:flutter/foundation.dart';

final cartRepositoryProvider = Provider((ref) => CartRepository());

class CartRepository {
  CartRepository();

  String? _cartToken; // stored once, sent with every request
  String? get cartToken => _cartToken;

  /// Build the Cart-Token header map for BFF requests.
  Map<String, String>? get _cartHeaders =>
      _cartToken != null ? {'Cart-Token': _cartToken!} : null;

  // ── Call this on app start, before any cart operations ──
  Future<void> initCart() async {
    try {
      final data = await ApiClient.get(
        ApiEndpoints.cart,
        extraHeaders: _cartHeaders,
      );
      _cartToken = data['cart']?['cartToken'] as String?;
      debugPrint('Cart token: $_cartToken');
    } catch (e) {
      debugPrint('Cart init failed: $e');
    }
  }

  Future<List<BffCartItem>> getCart() async {
    final data = await ApiClient.get(
      ApiEndpoints.cart,
      extraHeaders: _cartHeaders,
    );
    _cartToken ??= data['cart']?['cartToken'] as String?;
    final cart = data['cart'] as Map<String, dynamic>?;
    final raw = cart?['items'] as List<dynamic>?
            ?? data['items'] as List<dynamic>?
            ?? [];
    return raw
        .map((e) => BffCartItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String?> addItem({
    required String productId,
    required int quantity,
    String? variantId,
    Map<String, String> selectedOptions = const {},
  }) async {
    final data = await ApiClient.post(
      ApiEndpoints.cartAdd,
      body: {
        'productId': productId,
        'quantity': quantity,
        if (variantId != null) 'variantId': variantId,
        if (selectedOptions.isNotEmpty) 'selectedOptions': selectedOptions,
      },
      requiresAuth: true,
      extraHeaders: _cartHeaders,
    );
    // Update token in case BFF rotates it
    _cartToken ??= data['cart']?['cartToken'] as String?;
    final items = (data['cart']?['items'] as List<dynamic>?) ?? [];
    final match = items
        .whereType<Map<String, dynamic>>()
        .where((i) => i['productId'].toString() == productId)
        .lastOrNull;
    return match?['key'] as String?;
  }

  Future<void> updateItem({
    required String productId,
    required int quantity,
    String? variantId,
    String? cartKey,
  }) async {
    await ApiClient.post(
      ApiEndpoints.cartUpdate,
      body: {
        if (cartKey != null) 'key': cartKey
        else 'productId': productId,
        'quantity': quantity,
        if (variantId != null && cartKey == null) 'variantId': variantId,
      },
      requiresAuth: true,
      extraHeaders: _cartHeaders,
    );
  }

  Future<void> removeItem(String key) async {
    await ApiClient.post(
      ApiEndpoints.cartRemove,
      body: {
        'key': key,
      },
      requiresAuth: true,
      extraHeaders: _cartHeaders,
    );
  }

  Future<void> clearCart() async {
    await ApiClient.delete(
      ApiEndpoints.cart,
      requiresAuth: true,
      extraHeaders: _cartHeaders,
    );
    _cartToken = null; // cleared cart = no more token
  }

  Future<void> applyCoupon(String code) async {
    await ApiClient.post(
      ApiEndpoints.cartCoupon,
      body: {
        'code': code,
      },
      requiresAuth: true,
      extraHeaders: _cartHeaders,
    );
  }

  Future<void> mergeCart(String guestCartToken) async {
    try {
      final data = await ApiClient.post(
        ApiEndpoints.cartMerge,
        body: {'guestCartToken': guestCartToken},
        requiresAuth: true,
        extraHeaders: _cartHeaders,
      );
      _cartToken = data['cart']?['cartToken'] as String? ?? _cartToken;
    } catch (e) {
      debugPrint('Cart merge failed: $e');
    }
  }
}