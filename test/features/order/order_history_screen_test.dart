import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/features/order/order_history_screen.dart';
import 'package:flutter_application_1/features/order/repositories/order_repository.dart';
import 'package:flutter_application_1/core/network/api_exception.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  testWidgets('OrderHistoryScreen shows empty state when no orders', (WidgetTester tester) async {
    final mockRepo = MockOrderRepository();
    when(() => mockRepo.getOrders()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          orderRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: OrderHistoryScreen(),
        ),
      ),
    );

    // Initial loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    // Empty state
    expect(find.text('No orders found'), findsOneWidget);
    expect(find.text('Try a different filter'), findsOneWidget);
  });
  
  testWidgets('OrderHistoryScreen shows error state on failure', (WidgetTester tester) async {
    final mockRepo = MockOrderRepository();
    when(() => mockRepo.getOrders()).thenThrow(const ApiException('Network Error'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          orderRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: OrderHistoryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    
    // Should show error and retry button
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Network Error'), findsOneWidget);
  });
}
