class UserAddress {
  final String id;
  final String firstName;
  final String lastName;
  final String address1;
  final String address2;
  final String city;
  final String postcode;
  final String country;
  final String phone;
  final bool isDefaultShipping;
  final bool isDefaultBilling;

  const UserAddress({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.address1,
    this.address2 = '',
    required this.city,
    required this.postcode,
    required this.country,
    required this.phone,
    this.isDefaultShipping = false,
    this.isDefaultBilling = false,
  });

  // Full name convenience getter
  String get fullName => '$firstName $lastName';

  // Full address for display
  String get fullAddress => address2.isEmpty
      ? '$address1, $city $postcode'
      : '$address1, $address2, $city $postcode';

  factory UserAddress.fromJson(Map<String, dynamic> j) => UserAddress(
        id: j['id'] as String,
        firstName: j['firstName'] as String? ?? '',
        lastName: j['lastName'] as String? ?? '',
        address1: j['address1'] as String? ?? '',
        address2: j['address2'] as String? ?? '',
        city: j['city'] as String? ?? '',
        postcode: j['postcode'] as String? ?? '',
        country: j['country'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        isDefaultShipping: j['isDefaultShipping'] as bool? ?? false,
        isDefaultBilling: j['isDefaultBilling'] as bool? ?? false,
      );
}

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final String? phone;
  final int rewardPoints;
  final List<UserAddress> addresses;
  final bool isGuest;
  final bool isVerified;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    this.phone,
    this.rewardPoints = 0,
    this.addresses = const [],
    this.isGuest = false,
    this.isVerified = false,
  });

  String get fullName => '$firstName $lastName';

  // Initials for avatar — "Mustafizur Rahman" → "MR"
  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return displayName.substring(0, 2).toUpperCase();
  }

  UserAddress? get defaultShippingAddress => addresses.firstWhere(
        (a) => a.isDefaultShipping,
        orElse: () => addresses.isNotEmpty ? addresses.first
            : const UserAddress(
                id: '', firstName: '', lastName: '',
                address1: '', city: '', postcode: '',
                country: '', phone: ''),
      );

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'] as String,
        email: j['email'] as String,
        firstName: j['firstName'] as String? ?? '',
        lastName: j['lastName'] as String? ?? '',
        displayName: j['displayName'] as String? ?? '',
        phone: j['phone'] as String?,
        rewardPoints: j['rewardPoints'] as int? ?? 0,
        addresses: (j['addresses'] as List<dynamic>? ?? [])
            .map((e) => UserAddress.fromJson(e as Map<String, dynamic>))
            .toList(),
        isGuest: j['isGuest'] as bool? ?? false,
        isVerified: j['isVerified'] as bool? ?? false,
      );
}