import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/product/models/product_model.dart';

void main() {
  group('Product Serialization Roundtrip Tests', () {
    test('Product serializes to and from JSON preserving all fields', () {
      final original = Product(
        id: 'prod-42',
        slug: 'blackpink-born-pink-vinyl',
        name: 'BORN PINK Limited Vinyl',
        type: ProductType.variable,
        price: 59.99,
        regularPrice: 69.99,
        priceRange: const PriceRange(min: 49.99, max: 59.99),
        onSale: true,
        stockStatus: 'instock',
        stockQuantity: 25,
        featuredImage: const ProductImage(
          id: 'img-1',
          url: 'https://example.com/cover.jpg',
          alt: 'Born Pink Cover',
        ),
        category: 'Albums',
        averageRating: 4.9,
        description: 'Limited edition gatefold LP',
        shortDescription: 'Gatefold Vinyl',
        artist: 'BLACKPINK',
        images: const [
          ProductImage(id: 'img-1', url: 'https://example.com/cover.jpg', alt: 'Cover'),
          ProductImage(id: 'img-2', url: 'https://example.com/back.jpg', alt: 'Back'),
        ],
        variants: const [
          ProductVariant(
            id: 'var-1',
            sku: 'BP-LP-PINK',
            price: 59.99,
            regularPrice: 69.99,
            stockStatus: 'instock',
            stockQuantity: 15,
            selectedOptions: {'color': 'pink'},
          ),
        ],
        attributes: const [
          ProductAttribute(
            name: 'Color',
            key: 'color',
            options: ['pink', 'black'],
            usedForVariations: true,
          ),
        ],
      );

      final json = original.toJson();
      final reconstituted = Product.fromJson(json);

      expect(reconstituted.id, original.id);
      expect(reconstituted.slug, original.slug);
      expect(reconstituted.name, original.name);
      expect(reconstituted.type, original.type);
      expect(reconstituted.price, original.price);
      expect(reconstituted.regularPrice, original.regularPrice);
      expect(reconstituted.onSale, original.onSale);
      expect(reconstituted.stockStatus, original.stockStatus);
      expect(reconstituted.stockQuantity, original.stockQuantity);
      expect(reconstituted.featuredImage.url, original.featuredImage.url);
      expect(reconstituted.category, original.category);
      expect(reconstituted.averageRating, original.averageRating);
      expect(reconstituted.description, original.description);
      expect(reconstituted.artist, original.artist);
      expect(reconstituted.images.length, 2);
      expect(reconstituted.variants.length, 1);
      expect(reconstituted.variants.first.id, 'var-1');
      expect(reconstituted.attributes.length, 1);
      expect(reconstituted.attributes.first.options, ['pink', 'black']);
    });
  });
}
