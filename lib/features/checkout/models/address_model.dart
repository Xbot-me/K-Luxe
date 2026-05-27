class Address {
  final String id;
  final String name;
  final String phone;
  final String line1;
  final String line2;
  final String city;
  final bool isDefault;

  const Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.line1,
    this.line2 = '',
    required this.city,
    this.isDefault = false,
  });

  String get fullAddress =>
      line2.isEmpty ? '$line1, $city' : '$line1, $line2, $city';
}