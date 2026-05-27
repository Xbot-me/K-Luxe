class ShippingRate {
  final String id;
  final String title;
  final double price;
  final String currency;
  final String estimatedDays;
  final String provider;

  const ShippingRate({required this.id, required this.title, required this.price, required this.currency, required this.estimatedDays, required this.provider});

  factory ShippingRate.fromJson(Map<String, dynamic> json) => ShippingRate(
    id: json['id'],
    title: json['title'],
    price: (json['price'] as num).toDouble(),
    currency: json['currency'],
    estimatedDays: json['estimatedDays'],
    provider: json['provider'],
  );
}