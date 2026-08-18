import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/cache/local_cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalCacheService In-Flight Deduplication Tests', () {
    test('deduplicates simultaneous in-flight requests into a single execution', () async {
      final cacheService = LocalCacheService.instance;
      int networkCallCount = 0;

      Future<String> slowFetch() async {
        networkCallCount++;
        await Future.delayed(const Duration(milliseconds: 100));
        return 'response_data';
      }

      // Fire 3 simultaneous requests with the same key
      final futures = [
        cacheService.deduplicate('product_13', slowFetch),
        cacheService.deduplicate('product_13', slowFetch),
        cacheService.deduplicate('product_13', slowFetch),
      ];

      final results = await Future.wait(futures);

      expect(results[0], 'response_data');
      expect(results[1], 'response_data');
      expect(results[2], 'response_data');
      expect(networkCallCount, 1, reason: 'Expected exactly 1 execution for 3 simultaneous calls');
    });

    test('allows sequential requests after in-flight completion', () async {
      final cacheService = LocalCacheService.instance;
      int networkCallCount = 0;

      Future<String> fetch() async {
        networkCallCount++;
        return 'seq_$networkCallCount';
      }

      final first = await cacheService.deduplicate('key_seq', fetch);
      final second = await cacheService.deduplicate('key_seq', fetch);

      expect(first, 'seq_1');
      expect(second, 'seq_2');
      expect(networkCallCount, 2);
    });
  });
}
