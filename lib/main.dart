import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/cart/cart_manager.dart';
import 'core/theme/theme_provider.dart';
import 'features/cart/cart_screen.dart';
import 'features/checkout/checkout_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/product/models/product_model.dart';
import 'features/product/product_detail_screen.dart';
import 'features/product/widgets/product_detail_fetch_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/shop/shop_screen.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup Global Error Handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // Send to crashlytics/sentry in production
    }
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kReleaseMode) {
      // Send to crashlytics/sentry in production
    }
    return true;
  };

  await dotenv.load(fileName: ".env");

  final container = ProviderContainer();
  await container.read(cartProvider.notifier).initCart();

  runApp(UncontrolledProviderScope(
    container: container,
    child: const KLuxeApp(),
  ));
}

class KLuxeApp extends ConsumerStatefulWidget {
  const KLuxeApp({super.key});

  @override
  ConsumerState<KLuxeApp> createState() => _KLuxeAppState();
}

class _KLuxeAppState extends ConsumerState<KLuxeApp> {
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
            if (product != null) return ProductDetailScreen(product: product);
            return ProductDetailFetchScreen(id: id);
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
    final dynamicTheme = ref.watch(appThemeDataProvider);
    final branding = ref.watch(tenantBrandingProvider);

    return MaterialApp.router(
      title: branding.appTitle,
      debugShowCheckedModeBanner: false,
      theme: dynamicTheme,
      routerConfig: _router,
    );
  }
}
