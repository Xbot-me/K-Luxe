import '../../product/models/product_model.dart';

// Possible states an order can be in
enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

class OrderItem {
  final Product product;
  final int quantity;

  const OrderItem({required this.product, required this.quantity});

  double get totalPrice => product.price * quantity;
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final DateTime placedAt;
  final DateTime? deliveredAt;

  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.placedAt,
    this.deliveredAt,
  });

  // How many total products in this order
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
}