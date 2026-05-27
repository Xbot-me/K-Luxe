import '../../product/models/product_model.dart';

class BffCartItem {
  final String key; // BFF cart item key — use this for remove/update
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;
  final String? variantId;
  final Map<String, String> selectedOptions;

  const BffCartItem({
    required this.key,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    this.variantId,
    this.selectedOptions = const {},
  });

  double get totalPrice => price * quantity;

  factory BffCartItem.fromJson(Map<String, dynamic> j) {
    // Parse options: [{ "name": "size", "value": "L" }] → { "size": "L" }
    final rawOptions = j['options'] as List<dynamic>? ?? [];
    final options = <String, String>{};
    for (final opt in rawOptions) {
      final map = opt as Map<String, dynamic>;
      final name = map['name'] as String?;
      final value = map['value'] as String?;
      if (name != null && value != null) options[name] = value;
    }

    return BffCartItem(
      key: j['key'] as String? ?? j['productId'].toString(),
      productId: j['productId'].toString(),
      name: j['name'] as String,
      price: (j['price'] as num).toDouble(),
      quantity: j['quantity'] as int,
      imageUrl: j['image'] as String?       // BFF uses 'image'
              ?? j['imageUrl'] as String?    // fallback
              ?? '',
      variantId: j['variantId'] as String?,
      selectedOptions: options,
    );
  }

  Product toProduct() => Product(
        id: productId,
        slug: productId,
        name: name,
        type: ProductType.simple,
        price: price,
        regularPrice: price,
        onSale: false,
        stockStatus: 'instock',
        featuredImage: ProductImage(id: productId, url: imageUrl, alt: name),
        category: '',
        averageRating: 0,
      );
}