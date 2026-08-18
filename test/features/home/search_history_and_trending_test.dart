import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/features/home/store/search_history_store.dart';
import 'package:flutter_application_1/features/home/widgets/search_discovery_view.dart';
import 'package:flutter_application_1/features/product/models/trending_search.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SearchHistoryStore Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SearchHistoryStore.clear();
    });

    test('add() inserts items at top and deduplicates', () async {
      await SearchHistoryStore.add('Lightstick');
      await SearchHistoryStore.add('Vinyl');
      await SearchHistoryStore.add('lightstick'); // duplicate with different casing

      expect(SearchHistoryStore.history.length, 2);
      expect(SearchHistoryStore.history.first, 'lightstick');
      expect(SearchHistoryStore.history[1], 'Vinyl');
    });

    test('remove() removes specific query', () async {
      await SearchHistoryStore.add('Lightstick');
      await SearchHistoryStore.add('Vinyl');
      await SearchHistoryStore.remove('Lightstick');

      expect(SearchHistoryStore.history.length, 1);
      expect(SearchHistoryStore.history.first, 'Vinyl');
    });

    test('clear() empties the store', () async {
      await SearchHistoryStore.add('Lightstick');
      await SearchHistoryStore.add('Vinyl');
      await SearchHistoryStore.clear();

      expect(SearchHistoryStore.history.isEmpty, true);
    });

    test('limits to maximum 10 recent searches', () async {
      for (int i = 0; i < 15; i++) {
        await SearchHistoryStore.add('Item $i');
      }
      expect(SearchHistoryStore.history.length, 10);
      expect(SearchHistoryStore.history.first, 'Item 14');
    });
  });

  group('TrendingItem Model Tests', () {
    test('TrendingItem serialization and deserialization', () {
      final item = const TrendingItem(
        query: 'BTS Lightstick',
        rank: 1,
        isHot: true,
        tag: 'HOT',
        category: 'Gear',
        searchCount: 1500,
      );

      final json = item.toJson();
      final fromJson = TrendingItem.fromJson(json);

      expect(fromJson.query, 'BTS Lightstick');
      expect(fromJson.rank, 1);
      expect(fromJson.isHot, true);
      expect(fromJson.tag, 'HOT');
      expect(fromJson.category, 'Gear');
      expect(fromJson.searchCount, 1500);
    });

    test('TrendingTimeframe enum labels and api values', () {
      expect(TrendingTimeframe.recent.label, 'Recent');
      expect(TrendingTimeframe.recent.apiValue, 'recent');
      expect(TrendingTimeframe.daily.label, 'Today');
      expect(TrendingTimeframe.daily.apiValue, 'daily');
      expect(TrendingTimeframe.monthly.label, 'This Month');
      expect(TrendingTimeframe.monthly.apiValue, 'monthly');
    });
  });

  group('SearchDiscoveryView Widget Tests', () {
    testWidgets('renders recent searches, timeframes, and trending items', (tester) async {
      String? selectedQuery;
      TrendingTimeframe? changedTimeframe;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchDiscoveryView(
              recentSearches: const ['NewJeans', 'Aespa'],
              selectedTimeframe: TrendingTimeframe.recent,
              trendingItems: const [
                TrendingItem(query: 'BORN PINK Vinyl', rank: 1, isHot: true, tag: 'HOT'),
                TrendingItem(query: 'Official Lightstick V2', rank: 2),
              ],
              isTrendingLoading: false,
              onTimeframeChanged: (tf) => changedTimeframe = tf,
              onSelectQuery: (q) => selectedQuery = q,
              onRemoveRecent: (_) {},
              onClearRecent: () {},
            ),
          ),
        ),
      );

      expect(find.text('Recent Searches'), findsOneWidget);
      expect(find.text('NewJeans'), findsOneWidget);
      expect(find.text('Aespa'), findsOneWidget);

      expect(find.text('Trending Searches'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('BORN PINK Vinyl'), findsOneWidget);
      expect(find.text('Official Lightstick V2'), findsOneWidget);

      // Tap on recent search chip
      await tester.tap(find.text('NewJeans'));
      expect(selectedQuery, 'NewJeans');

      // Tap on Daily timeframe pill
      await tester.tap(find.text('Today'));
      expect(changedTimeframe, TrendingTimeframe.daily);

      // Tap on trending item
      await tester.tap(find.text('BORN PINK Vinyl'));
      expect(selectedQuery, 'BORN PINK Vinyl');
    });
  });
}
