import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/product/models/product_model.dart';
import 'package:flutter_application_1/features/product/repositories/product_repository.dart';

void main() {
  group('Search Serialization Tests', () {
    test('SearchResult.fromJson deserializes when key is "results"', () {
      final json = {
        'success': true,
        'query': 'lightstick',
        'results': [
          {
            'id': 'prod-1',
            'slug': 'bts-lightstick-v4',
            'name': 'BTS Official Lightstick Special Edition',
            'type': 'simple',
            'price': 65.0,
            'regularPrice': 65.0,
            'onSale': false,
            'stockStatus': 'instock',
            'featuredImage': {
              'id': 'img-1',
              'url': 'https://example.com/ls.jpg',
              'alt': 'BTS Lightstick',
            },
            'category': 'Lightsticks',
            'averageRating': 5.0,
          },
        ],
        'total': 1,
        'tookMs': 12,
      };

      final result = SearchResult.fromJson(json);

      expect(result.products.length, 1);
      expect(result.products.first.name, 'BTS Official Lightstick Special Edition');
      expect(result.total, 1);
    });

    test('SearchResult.fromJson deserializes when key is "products"', () {
      final json = {
        'products': [
          {
            'id': 'prod-2',
            'slug': 'album-1',
            'name': 'NewJeans 2nd EP Get Up',
            'type': 'simple',
            'price': 24.99,
            'regularPrice': 29.99,
            'onSale': true,
            'stockStatus': 'instock',
            'featuredImage': {
              'id': 'img-2',
              'url': 'https://example.com/nj.jpg',
              'alt': 'Get Up',
            },
            'category': 'Albums',
            'averageRating': 4.9,
          },
        ],
        'total': 1,
      };

      final result = SearchResult.fromJson(json);

      expect(result.products.length, 1);
      expect(result.products.first.name, 'NewJeans 2nd EP Get Up');
      expect(result.total, 1);
    });
  });
}
