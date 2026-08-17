import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

final notificationProvider = NotifierProvider<NotificationStore, List<AppNotification>>(() {
  return NotificationStore();
});

class NotificationStore extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() {
    return [
      AppNotification(
        id: '1', type: NotificationType.order,
        title: 'Your order has shipped',
        body: 'BTS Proof Standard Ed. × 1 is on the way. Est. delivery May 16.',
        chipLabel: 'Shipped',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: '2', type: NotificationType.order,
        title: 'Order confirmed',
        body: 'Order #KP-80412 placed. Total \$38.00',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: '3', type: NotificationType.order, isRead: true,
        title: 'Order delivered',
        body: 'TWICE Formula of Love album arrived.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      AppNotification(
        id: '4', type: NotificationType.promo,
        title: 'Flash sale starts in 1 hr',
        body: 'Up to 40% off BLACKPINK & NewJeans merch.',
        chipLabel: 'Ends tonight',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: '5', type: NotificationType.promo, isRead: true,
        title: 'Wishlist item restocked',
        body: 'aespa My World Diary Ver. is available again.',
        chipLabel: 'Back in stock',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AppNotification(
        id: '6', type: NotificationType.update, isRead: true,
        title: 'New arrivals: Stray Kids',
        body: 'HOP limited photocard sets just dropped.',
        chipLabel: 'New',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }

  bool get hasUnread => state.any((n) => !n.isRead);

  List<AppNotification> byType(NotificationType t) =>
      state.where((n) => n.type == t).toList();

  void markAllRead() {
    state = state.map((n) {
      n.isRead = true;
      return n;
    }).toList();
  }

  void remove(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}