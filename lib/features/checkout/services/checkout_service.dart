import '../../../core/cart/cart_manager.dart';
import '../../order/repositories/order_repository.dart';

class CheckoutResult {
  final String orderId;
  final List<CartItem> items;
  final double total;
  final String paymentMethod;

  const CheckoutResult({
    required this.orderId,
    required this.items,
    required this.total,
    required this.paymentMethod,
  });
}

class CheckoutService {
  /**
   * Processes the checkout flow.
   * Currently invokes OrderRepository mock flow with a smooth minimum delay.
   * In Phase 3, this single method will bridge to Shopify Checkout Sheet Kit.
   */
  static Future<CheckoutResult> processOrder({
    required String cartToken,
    required Map<String, dynamic> billingAddress,
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
    required List<CartItem> items,
    required double total,
    required OrderRepository orderRepository,
  }) async {
    // Natural minimum delay so fast local mock calls do not flicker
    final minDelay = Future.delayed(const Duration(milliseconds: 550));

    final orderFuture = orderRepository.placeOrder(
      cartToken: cartToken,
      billingAddress: billingAddress,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
    );

    final results = await Future.wait([orderFuture, minDelay]);
    final orderId = results[0] as String;

    return CheckoutResult(
      orderId: orderId,
      items: List<CartItem>.from(items),
      total: total,
      paymentMethod: paymentMethod,
    );
  }
}
