import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/order_models.dart';
import '../../product/models/product_model.dart';

final orderRepositoryProvider = Provider((ref) => OrderRepository());

class OrderRepository {
  OrderRepository();

  Future<String> placeOrder({
    required String cartToken,
    required Map<String, dynamic> billingAddress,
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ??
        'flutter-order-${DateTime.now().millisecondsSinceEpoch}-${cartToken.hashCode}';

    final data = await ApiClient.post(
      ApiEndpoints.checkoutProcess, // /api/checkout/process
      body: {
        'cartToken': cartToken,
        'nonce': 'flutter-nonce-${DateTime.now().millisecondsSinceEpoch}',
        'billingAddress': billingAddress,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
      },
      requiresAuth: true,
      extraHeaders: {
        'X-Idempotency-Key': key,
        if (cartToken.isNotEmpty) 'Cart-Token': cartToken,
      },
    );

    return data['orderId'] as String? ??
        data['id'] as String? ??
        data['order']?['id'] as String? ??
        'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  // ── Get all orders for current user ──
  Future<List<Order>> getOrders() async {
    final data = await ApiClient.get(
      ApiEndpoints.orders,
      requiresAuth: true,
    );

    final raw = data['orders'] as List<dynamic>? ?? [];
    return raw
        .map((e) => _orderFromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Get single order ──
  Future<Order> getOrder(String id) async {
    final data = await ApiClient.get(
      ApiEndpoints.order(id),
      requiresAuth: true,
    );

    final raw = data['order'] as Map<String, dynamic>? ?? data;
    return _orderFromJson(raw);
  }

  // ── Parse order from BFF JSON ──
  Order _orderFromJson(Map<String, dynamic> j) {
    // Parse status string → enum
    final statusStr = j['status'] as String? ?? 'pending';
    final status = _parseStatus(statusStr);

    // Parse items
    final rawItems = j['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((e) {
      final item = e as Map<String, dynamic>;

      // Handle nested product or flat fields
      if (item.containsKey('product')) {
        final p = item['product'] as Map<String, dynamic>;
        final img = p['featuredImage'] as Map<String, dynamic>?;
        final product = Product(
          id: p['id'] as String,
          slug: p['slug'] as String? ?? p['id'] as String,
          name: p['name'] as String,
          type: ProductType.simple,
          price: (p['price'] as num).toDouble(),
          regularPrice: (p['regularPrice'] as num?)?.toDouble() ??
              (p['price'] as num).toDouble(),
          onSale: p['onSale'] as bool? ?? false,
          stockStatus: p['stockStatus'] as String? ?? 'instock',
          featuredImage: ProductImage(
            id: p['id'] as String,
            url: img?['url'] as String? ?? '',
            alt: p['name'] as String,
          ),
          category: p['category'] as String? ?? '',
          averageRating: (p['averageRating'] as num?)?.toDouble() ?? 0,
        );
        return OrderItem(
          product: product,
          quantity: item['quantity'] as int,
        );
      }

      // Flat shape fallback
      // Flat shape fallback — matches BFF response fields
      final product = Product(
        id: item['productId'] as String,
        slug: item['productId'] as String,
        name: item['name'] as String,
        type: ProductType.simple,
        // BFF sends 'unitPrice', not 'price'
        price: (item['unitPrice'] as num? ??
                item['price'] as num? ?? 0).toDouble(),
        regularPrice: (item['unitPrice'] as num? ??
                      item['price'] as num? ?? 0).toDouble(),
        onSale: false,
        stockStatus: 'instock',
        featuredImage: ProductImage(
          id: item['productId'] as String,
          // BFF sends 'image', not 'imageUrl'
          url: item['image'] as String? ??
              item['imageUrl'] as String? ?? '',
          alt: item['name'] as String,
        ),
        category: '',
        averageRating: 0,
      );
      return OrderItem(
        product: product,
        quantity: item['quantity'] as int,
      );
    }).toList();

    return Order(
      id: j['id'] as String,
      items: items,
      total: (() {
        final totals = j['totals'] as Map<String, dynamic>?;
        return (totals?['total'] as num? ?? j['total'] as num? ?? 0).toDouble();
      })(),
      status: status,
      placedAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ??
          DateTime.now(),
      deliveredAt: j['deliveredAt'] != null
          ? DateTime.tryParse(j['deliveredAt'] as String)
          : null,
    );
  }

  OrderStatus _parseStatus(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
      case 'processing':
        return OrderStatus.confirmed;
      case 'shipped':
      case 'on-hold':
        return OrderStatus.shipped;
      case 'delivered':
      case 'completed':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
      case 'refunded':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}