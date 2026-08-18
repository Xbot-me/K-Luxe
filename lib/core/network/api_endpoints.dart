import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://192.168.47.182:3000/api';

  // ── Auth ──
  static String get login => '$baseUrl/auth/login';
  static String get logout => '$baseUrl/auth/logout';
  static String get me => '$baseUrl/auth/me';
  static String get signup => '$baseUrl/signup';

  // ── Products ──
  static String get products => '$baseUrl/products';
  static String product(String id) => '$baseUrl/products/$id';

  // ── Cart ──
  static String get cart => '$baseUrl/cart'; // GET cart
  static String get cartAdd => '$baseUrl/cart/add'; // POST add item
  static String get cartRemove => '$baseUrl/cart/remove'; // POST/DELETE remove
  static String get cartUpdate => '$baseUrl/cart/update'; // POST/PUT update qty
  static String get cartCoupon => '$baseUrl/cart/coupon'; // POST apply coupon
  static String get cartMerge => '$baseUrl/cart/merge'; // POST merge cart

  // ── Checkout ──
  static String get checkoutProcess =>
      '$baseUrl/checkout/process'; // POST place order
  static String get shippingRates =>
      '$baseUrl/checkout/shipping'; // GET shipping methods
  static String get selectShippingRate => '$baseUrl/checkout/shipping/select';

  // ── Orders ──
  static String get orders => '$baseUrl/orders';
  static String order(String id) => '$baseUrl/orders/$id';

  // ── User ──
  static String get userProfile => '$baseUrl/user/profile';
  static String get userAddresses => '$baseUrl/user/addresses';
  static String get deleteAccount => '$baseUrl/user/delete';

  // ── Payments (NEW) ──
  static String get createPaymentSession => '$baseUrl/payments/create-session';
  static String get verifyPayment => '$baseUrl/payments/verify';


  // In api_endpoints.dart — add these if missing:
  static String get categories      => '$baseUrl/products/categories';
  static String get featuredProducts => '$baseUrl/products/featured';
  static String get searchProducts  => '$baseUrl/products/search';
  static String get tenantConfig    => '$baseUrl/tenant-config';
}
