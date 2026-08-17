import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/features/notifications/notification_sheet.dart';
import 'package:flutter_application_1/features/notifications/models/notification_model.dart';
import 'package:flutter_application_1/features/notifications/store/notification_store.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EmptyNotificationStore extends NotificationStore {
  @override
  List<AppNotification> build() => [];
}

void main() {
  testWidgets('NotificationSheet shows empty state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWith(EmptyNotificationStore.new),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => showNotificationsSheet(context),
                  child: const Text('Show'),
                );
              },
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
