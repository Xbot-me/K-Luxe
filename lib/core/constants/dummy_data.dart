import '../../features/checkout/models/address_model.dart';

// ── Addresses ──
// Keeping this until the Address API is connected in Checkout
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