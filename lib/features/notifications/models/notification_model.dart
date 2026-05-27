enum NotificationType { order, promo, update }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? chipLabel;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.chipLabel,
    required this.createdAt,
    this.isRead = false,
  });
}