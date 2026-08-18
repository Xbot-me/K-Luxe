import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/features/checkout/widgets/checkout_loading_overlay.dart';
import 'package:flutter_application_1/features/checkout/services/checkout_service.dart';
import 'package:flutter_application_1/features/order/order_confirm_screen.dart';
import 'package:flutter_application_1/core/cart/cart_manager.dart';
import 'package:flutter_application_1/features/product/models/product_model.dart';
import 'package:flutter_application_1/features/order/models/order_models.dart';
import 'package:flutter_application_1/features/order/repositories/order_repository.dart';

class MockOrderRepo implements OrderRepository {
  @override
  Future<String> placeOrder({
    required String cartToken,
    required Map<String, dynamic> billingAddress,
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
    String? idempotencyKey,
  }) async {
    return 'ORD-999';
  }

  @override
  Future<List<Order>> getOrders() async => [];

  @override
  Future<Order> getOrder(String id) async {
    return Order(
      id: id,
      placedAt: DateTime.now(),
      status: OrderStatus.confirmed,
      total: 99.98,
      items: const [],
    );
  }
}

void main() {
  group('CheckoutLoadingOverlay Tests', () {
    testWidgets('renders with theme colors and text', (tester) async {
      const customPrimary = Color(0xFFFF5500);
      final customTheme = ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: customPrimary,
          surface: Color(0xFF1E1E2C),
          onSurface: Colors.white,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: customTheme,
          home: const Scaffold(
            body: CheckoutLoadingOverlay(message: 'Securing transaction...'),
          ),
        ),
      );

      expect(find.text('Securing transaction...'), findsOneWidget);
      expect(find.text('Please do not close or refresh the app'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('OrderConfirmScreen Themed Tests', () {
    testWidgets('renders order ID, items count, and actions with theme', (tester) async {
      const customPrimary = Color(0xFFE5A93C);
      final customTheme = ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
        colorScheme: const ColorScheme.dark(
          primary: customPrimary,
          surface: Color(0xFF1B1A24),
          onSurface: Colors.white,
          onSurfaceVariant: Colors.white70,
        ),
      );

      final dummyProduct = Product(
        id: 'prod-1',
        slug: 'limited-vinyl',
        name: 'Limited Edition Vinyl',
        type: ProductType.simple,
        price: 49.99,
        regularPrice: 49.99,
        onSale: false,
        stockStatus: 'instock',
        featuredImage: const ProductImage(
          id: 'img1',
          url: 'https://example.com/item.png',
          alt: 'Limited Vinyl',
        ),
        category: 'Merch',
        averageRating: 5.0,
      );

      final cartItems = [
        CartItem(product: dummyProduct, quantity: 2),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: customTheme,
            home: OrderConfirmScreen(
              orderId: 'KL-88219',
              items: cartItems,
              total: 109.98,
            ),
          ),
        ),
      );

      // Advance animation controllers
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Order Confirmed!'), findsOneWidget);
      expect(find.text('#KL-88219'), findsOneWidget);
      expect(find.text('Limited Edition Vinyl'), findsOneWidget);
      expect(find.text('\$99.98'), findsOneWidget);
      expect(find.text('\$109.98'), findsOneWidget);
      expect(find.text('CONTINUE SHOPPING'), findsOneWidget);
      expect(find.text('VIEW ORDERS'), findsOneWidget);
    });
  });

  group('CheckoutService Isolation Tests', () {
    test('processOrder isolates repository call with natural delay and returns CheckoutResult', () async {
      final mockRepo = MockOrderRepo();
      final addressPayload = {
        'firstName': 'Alex',
        'address1': '123 Main St',
        'city': 'Seoul',
        'country': 'KR',
      };

      final stopwatch = Stopwatch()..start();
      final result = await CheckoutService.processOrder(
        cartToken: 'tok-123',
        billingAddress: addressPayload,
        shippingAddress: addressPayload,
        paymentMethod: 'bkash',
        items: [],
        total: 150.0,
        orderRepository: mockRepo,
      );
      stopwatch.stop();

      expect(result.orderId, 'ORD-999');
      expect(result.total, 150.0);
      expect(result.paymentMethod, 'bkash');
      expect(stopwatch.elapsedMilliseconds >= 500, isTrue);
    });
  });
}
