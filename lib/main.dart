import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/product/product_detail_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/checkout/checkout_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/product/models/product_model.dart';
import 'core/cart/cart_manager.dart';
import 'features/product/widgets/product_detail_fetch_screen.dart';
import 'features/shop/shop_screen.dart';

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CartManager.init();
  runApp(const KLuxeApp());
}

class KLuxeApp extends StatefulWidget {
  const KLuxeApp({super.key});
  @override
  State<KLuxeApp> createState() => _KLuxeAppState();
}

class _KLuxeAppState extends State<KLuxeApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            final product = state.extra as Product?;
            final id = state.pathParameters['id']!;
            // If extra is missing (deep link / hot restart), fetch by ID
            if (product != null) return ProductDetailScreen(product: product);
            return ProductDetailFetchScreen(id: id); // see note below
          },
        ),
        GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
        GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/shop', builder: (_, state) {
          final cat = state.uri.queryParameters['category'];
          return ShopScreen(initialCategory: cat);
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'K-LUXE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}

