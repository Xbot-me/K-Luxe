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

  // ── Call this on app start, before any cart operations ──
  Future<void> initCart() async {
    try {
      final data = await ApiClient.get(ApiEndpoints.cart);
      _cartToken = data['cart']?['cartToken'] as String?;
      debugPrint('Cart token: $_cartToken');
    } catch (e) {
      debugPrint('Cart init failed: $e');
    }
  }

  Future<List<BffCartItem>> getCart() async {
    final data = await ApiClient.get(
      ApiEndpoints.cart,
      // send token if we have it
      queryParams: _cartToken != null ? {'cartToken': _cartToken!} : null,
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
        if (_cartToken != null) 'cartToken': _cartToken,
        if (variantId != null) 'variantId': variantId,
        if (selectedOptions.isNotEmpty) 'selectedOptions': selectedOptions,
      },
      requiresAuth: true,
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
        if (_cartToken != null) 'cartToken': _cartToken,
        if (variantId != null && cartKey == null) 'variantId': variantId,
      },
      requiresAuth: true,
    );
  }

  Future<void> removeItem(String key) async {
  await ApiClient.post(
    ApiEndpoints.cartRemove,
    body: {
      'key': key,
      if (_cartToken != null) 'cartToken': _cartToken,
    },
    requiresAuth: true,
  );
  }

  Future<void> clearCart() async {
    await ApiClient.delete(ApiEndpoints.cart, requiresAuth: true);
    _cartToken = null; // cleared cart = no more token
  }

  Future<void> applyCoupon(String code) async {
    await ApiClient.post(
      ApiEndpoints.cartCoupon,
      body: {
        'code': code,
        if (_cartToken != null) 'cartToken': _cartToken,
      },
      requiresAuth: true,
    );
  }
}