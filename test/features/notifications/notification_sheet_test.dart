import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/features/notifications/notification_sheet.dart';
import 'package:flutter_application_1/features/notifications/store/notification_store.dart';
import 'package:lucide_icons/lucide_icons.dart';

void main() {
  testWidgets('NotificationSheet shows empty state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => showNotificationsSheet(context),
                  child: const Text('Show'),
                );
              }
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.text('No notifications'), findsOneWidget);
    expect(find.byIcon(LucideIcons.bellOff), findsOneWidget);
  });
}
