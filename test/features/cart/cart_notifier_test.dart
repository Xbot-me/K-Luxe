import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/cart/cart_manager.dart';
import 'package:flutter_application_1/features/cart/repositories/cart_repository.dart';
import 'package:flutter_application_1/features/product/models/product_model.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockCartRepository mockCartRepository;
  late ProviderContainer container;

  setUp(() {
    mockCartRepository = MockCartRepository();
    container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(mockCartRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('CartNotifier Edge Cases', () {
    final testProduct = const Product(
      id: 'p1',
      slug: 'test-product',
      name: 'Test Product',
      type: ProductType.simple,
      price: 100,
      regularPrice: 100,
      description: 'Desc',
      category: 'c1',
      featuredImage: ProductImage(id: 'i1', url: 'url', alt: ''),
      images: [],
      variants: [],
      attributes: [],
      averageRating: 4.0,
      stockStatus: 'instock',
      onSale: false,
    );

    test('Adding product sets state and handles repo failure', () async {
      when(() => mockCartRepository.addItem(
        productId: any(named: 'productId'),
        quantity: any(named: 'quantity'),
      )).thenAnswer((_) async => null);

      await container.read(cartProvider.notifier).addProduct(testProduct);
      expect(container.read(cartProvider).isEmpty, true);

      when(() => mockCartRepository.addItem(
        productId: any(named: 'productId'),
        quantity: any(named: 'quantity'),
      )).thenAnswer((_) async => 'cart-key-1');

      await container.read(cartProvider.notifier).addProduct(testProduct);
      final state = container.read(cartProvider);
      expect(state.length, 1);
      expect(state.first.cartKey, 'cart-key-1');
      expect(state.first.quantity, 1);
    });

    test('Removing non-existent item throws Exception', () async {
      expect(
        () => container.read(cartProvider.notifier).removeItem('non-existent-id'),
        throwsException,
      );
    });

    test('updateQuantity out of bounds removes item', () async {
      when(() => mockCartRepository.addItem(
        productId: any(named: 'productId'),
        quantity: any(named: 'quantity'),
      )).thenAnswer((_) async => 'cart-key-1');

      when(() => mockCartRepository.removeItem(any())).thenAnswer((_) async => {});

      await container.read(cartProvider.notifier).addProduct(testProduct);
      
      await container.read(cartProvider.notifier).updateQuantity('p1', 0);
      
      expect(container.read(cartProvider).isEmpty, true);
      verify(() => mockCartRepository.removeItem('cart-key-1')).called(1);
    });

    test('clear() clears state immediately and syncs with repo', () async {
      when(() => mockCartRepository.clearCart()).thenAnswer((_) async => {});
      when(() => mockCartRepository.addItem(
        productId: any(named: 'productId'),
        quantity: any(named: 'quantity'),
      )).thenAnswer((_) async => 'cart-key-1');

      await container.read(cartProvider.notifier).addProduct(testProduct);
      expect(container.read(cartProvider).isNotEmpty, true);

      container.read(cartProvider.notifier).clear();
      expect(container.read(cartProvider).isEmpty, true);
      verify(() => mockCartRepository.clearCart()).called(1);
    });
  });
}
