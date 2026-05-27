import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationStore extends ChangeNotifier {
  NotificationStore._();
  static final instance = NotificationStore._();

  final List<AppNotification> _items = [
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

  List<AppNotification> get all => List.unmodifiable(_items);
  bool get hasUnread => _items.any((n) => !n.isRead);

  List<AppNotification> byType(NotificationType t) =>
      _items.where((n) => n.type == t).toList();

  void markAllRead() {
    for (final n in _items) { n.isRead = true; }
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    notifyListeners();
  }
}