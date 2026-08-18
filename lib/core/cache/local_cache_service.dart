import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalCacheService {
  static const String boxProducts = 'products';
  static const String boxCategories = 'categories';
  static const String boxProductLists = 'product_lists';

  static final LocalCacheService instance = LocalCacheService._internal();
  LocalCacheService._internal();

  // In-flight request deduplication map: prevents 2-3 simultaneous calls for the same key
  final Map<String, Future<dynamic>> _inFlight = {};

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      await Future.wait([
        Hive.openBox(boxProducts),
        Hive.openBox(boxCategories),
        Hive.openBox(boxProductLists),
      ]);
      debugPrint('[LocalCacheService] Hive boxes initialized successfully');
    } catch (e) {
      debugPrint('[LocalCacheService] Hive initialization warning: $e');
    }
  }

  Box? _getBox(String boxName) {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return null;
  }

  /// Deduplicates in-flight asynchronous requests so identical calls share one Future
  Future<T> deduplicate<T>(String requestKey, Future<T> Function() fetcher) {
    if (_inFlight.containsKey(requestKey)) {
      debugPrint('[LocalCacheService] Joining existing in-flight request for "$requestKey"');
      return _inFlight[requestKey]! as Future<T>;
    }

    final future = fetcher();
    _inFlight[requestKey] = future;

    future.whenComplete(() {
      _inFlight.remove(requestKey);
    });

    return future;
  }

  /// Stale-While-Revalidate (SWR) fetching engine
  Future<T> fetchWithSWR<T>({
    required String boxName,
    required String key,
    required Duration ttl,
    required Future<T> Function() networkFetcher,
    required T Function(dynamic data) deserializer,
    required dynamic Function(T data) serializer,
    void Function(T updatedData)? onBackgroundUpdate,
  }) async {
    final box = _getBox(boxName);
    final requestKey = '$boxName:$key';

    if (box != null) {
      final cachedEntry = box.get(key);
      if (cachedEntry is Map) {
        final cachedAtRaw = cachedEntry['cachedAt'] as String?;
        final rawData = cachedEntry['data'];

        if (cachedAtRaw != null && rawData != null) {
          try {
            final cachedAt = DateTime.parse(cachedAtRaw);
            final age = DateTime.now().difference(cachedAt);
            final isFresh = age < ttl;
            final cachedValue = deserializer(rawData);

            if (isFresh) {
              debugPrint('[LocalCacheService] Cache HIT (Fresh, age: ${age.inSeconds}s) for "$key"');
              return cachedValue;
            }

            // Stale: return cached data immediately, refresh in background
            debugPrint('[LocalCacheService] Cache SWR HIT (Stale, age: ${age.inSeconds}s). Serving cached & revalidating "$key"');
            unawaited(
              deduplicate<T>(requestKey, () async {
                try {
                  final freshData = await networkFetcher();
                  await box.put(key, {
                    'data': serializer(freshData),
                    'cachedAt': DateTime.now().toIso8601String(),
                  });
                  onBackgroundUpdate?.call(freshData);
                  debugPrint('[LocalCacheService] Background revalidation completed for "$key"');
                  return freshData;
                } catch (e) {
                  debugPrint('[LocalCacheService] Background revalidation failed for "$key": $e');
                  return cachedValue;
                }
              }),
            );

            return cachedValue;
          } catch (e) {
            debugPrint('[LocalCacheService] Corrupt cache entry for "$key", discarding: $e');
            await box.delete(key);
          }
        }
      }
    }

    // Cache miss: execute network fetch with deduplication
    debugPrint('[LocalCacheService] Cache MISS for "$key". Fetching from network...');
    return deduplicate(requestKey, () async {
      final response = await networkFetcher();
      if (box != null) {
        try {
          await box.put(key, {
            'data': serializer(response),
            'cachedAt': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          debugPrint('[LocalCacheService] Error saving cache for "$key": $e');
        }
      }
      return response;
    });
  }

  /// Manually clear a box or invalidate a key
  Future<void> invalidate(String boxName, String key) async {
    final box = _getBox(boxName);
    if (box != null) {
      await box.delete(key);
    }
  }

  Future<void> clearAll() async {
    final boxes = [boxProducts, boxCategories, boxProductLists];
    for (final b in boxes) {
      final box = _getBox(b);
      if (box != null) {
        await box.clear();
      }
    }
  }
}
