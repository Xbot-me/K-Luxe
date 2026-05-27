import 'package:flutter/material.dart';
import '../../features/product/models/product_model.dart';
import '../../features/order/models/order_models.dart';
import '../../features/checkout/models/address_model.dart';

// ── Banners ──
class BannerItem {
  final String title;
  final String subtitle;
  final Color color;
  const BannerItem({
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

final List<BannerItem> dummyBanners = [
  BannerItem(
    title: 'Summer Sale',
    subtitle: 'Up to 50% off — Shop now',
    color: const Color(0xFF185FA5),
  ),
  BannerItem(
    title: 'New Arrivals',
    subtitle: 'Fresh picks every week',
    color: const Color(0xFF1D9E75),
  ),
  BannerItem(
    title: 'Free Delivery',
    subtitle: 'On orders above ৳1000',
    color: const Color(0xFF8B5CF6),
  ),
];

// ── Categories ──
const List<String> appCategories = [
  'All',
  'Gear',
  'Albums',
  'Apparel',
  'Bundles',
  'Events',
  'Merch',
];

// Helper to build a ProductImage inline
ProductImage _img(String url, String alt) =>
    ProductImage(id: url, url: url, alt: alt);

// ── Products — fields now match the new Product model ──
final List<Product> dummyProducts = [
  Product(
    id: '1',
    slug: 'official-lightstick-v2',
    name: 'Official Lightstick V2',
    type: ProductType.simple,
    price: 55,
    regularPrice: 55,
    onSale: false,
    stockStatus: 'instock',
    stockQuantity: 80,
    featuredImage: _img(
      'https://placehold.co/600x600/111/fff?text=Lightstick',
      'Official Lightstick V2',
    ),
    category: 'Gear',
    averageRating: 5,
  ),
  Product(
    id: '2',
    slug: 'special-album-dawn-dusk',
    name: 'Special Album [Dawn/Dusk]',
    type: ProductType.variable,
    price: 22,
    regularPrice: 28,
    onSale: true,
    stockStatus: 'instock',
    featuredImage: _img(
      'https://placehold.co/600x600/222/fff?text=Album',
      'Special Album',
    ),
    category: 'Albums',
    averageRating: 4.9,
  ),
  Product(
    id: '3',
    slug: 'world-tour-hoodie',
    name: 'World Tour Hoodie',
    type: ProductType.variable,
    price: 65,
    regularPrice: 65,
    onSale: false,
    stockStatus: 'instock',
    featuredImage: _img(
      'https://placehold.co/600x600/333/fff?text=Hoodie',
      'World Tour Hoodie',
    ),
    category: 'Apparel',
    averageRating: 4.7,
  ),
  Product(
    id: '4',
    slug: 'collector-full-set',
    name: 'Complete Collection Set',
    type: ProductType.grouped,
    price: 180,
    regularPrice: 200,
    onSale: true,
    stockStatus: 'instock',
    stockQuantity: 10,
    featuredImage: _img(
      'https://placehold.co/600x600/444/fff?text=Bundle',
      'Complete Collection Bundle',
    ),
    category: 'Bundles',
    averageRating: 5,
  ),
  Product(
    id: '5',
    slug: 'concert-tix-dhaka-vip',
    name: 'Concert in Dhaka - VIP',
    type: ProductType.external,
    price: 150,
    regularPrice: 150,
    onSale: false,
    stockStatus: 'instock',
    featuredImage: _img(
      'https://placehold.co/600x600/555/fff?text=Ticket',
      'VIP Concert Ticket',
    ),
    category: 'Events',
    averageRating: 0,
  ),
  Product(
    id: '6',
    slug: 'limited-poster-signed',
    name: 'Hand-Signed Poster',
    type: ProductType.simple,
    price: 15,
    regularPrice: 30,
    onSale: true,
    stockStatus: 'instock',
    stockQuantity: 2,
    featuredImage: _img(
      'https://placehold.co/600x600/666/fff?text=Poster',
      'Hand-Signed Poster',
    ),
    category: 'Merch',
    averageRating: 4.5,
  ),
  Product(
    id: '7',
    slug: 'photo-card-set',
    name: 'Photo Card Set',
    type: ProductType.simple,
    price: 12,
    regularPrice: 12,
    onSale: false,
    stockStatus: 'instock',
    stockQuantity: 150,
    featuredImage: _img(
      'https://placehold.co/600x600/777/fff?text=PhotoCard',
      'Photo Card Set',
    ),
    category: 'Merch',
    averageRating: 4.8,
  ),
  Product(
    id: '8',
    slug: 'fan-club-tshirt',
    name: 'Fan Club T-Shirt',
    type: ProductType.variable,
    price: 35,
    regularPrice: 35,
    onSale: false,
    stockStatus: 'instock',
    featuredImage: _img(
      'https://placehold.co/600x600/888/fff?text=TShirt',
      'Fan Club T-Shirt',
    ),
    category: 'Apparel',
    averageRating: 4.6,
  ),
];

// ── Addresses ──
final List<Address> dummyAddresses = [
  Address(
    id: 'addr_1',
    name: 'Abdullah Rahim',
    phone: '+880 1711-000000',
    line1: 'House 12, Road 5',
    line2: 'Gulshan 1',
    city: 'Dhaka',
    isDefault: true,
  ),
  Address(
    id: 'addr_2',
    name: 'Abdullah Rahim',
    phone: '+880 1711-000000',
    line1: 'Flat 3B, Green Tower',
    line2: 'Dhanmondi 27',
    city: 'Dhaka',
  ),
];

// ── Orders ──
final List<Order> dummyOrders = [
  Order(
    id: 'ORD-2847',
    items: [
      OrderItem(product: dummyProducts[0], quantity: 1),
      OrderItem(product: dummyProducts[1], quantity: 2),
    ],
    total: 99,
    status: OrderStatus.delivered,
    placedAt: DateTime(2026, 4, 28),
    deliveredAt: DateTime(2026, 5, 1),
  ),
  Order(
    id: 'ORD-2831',
    items: [
      OrderItem(product: dummyProducts[2], quantity: 1),
    ],
    total: 65,
    status: OrderStatus.shipped,
    placedAt: DateTime(2026, 4, 22),
  ),
  Order(
    id: 'ORD-2800',
    items: [
      OrderItem(product: dummyProducts[4], quantity: 1),
      OrderItem(product: dummyProducts[5], quantity: 1),
    ],
    total: 165,
    status: OrderStatus.delivered,
    placedAt: DateTime(2026, 4, 10),
    deliveredAt: DateTime(2026, 4, 13),
  ),
  Order(
    id: 'ORD-2755',
    items: [
      OrderItem(product: dummyProducts[3], quantity: 1),
    ],
    total: 180,
    status: OrderStatus.cancelled,
    placedAt: DateTime(2026, 3, 30),
  ),
  Order(
    id: 'ORD-2901',
    items: [
      OrderItem(product: dummyProducts[6], quantity: 2),
    ],
    total: 24,
    status: OrderStatus.confirmed,
    placedAt: DateTime(2026, 5, 5),
  ),
];