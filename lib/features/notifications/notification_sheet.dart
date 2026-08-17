import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import './models/notification_model.dart';
import './store/notification_store.dart';

void showNotificationsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _NotificationsSheet(),
  );
}

class _NotificationsSheet extends ConsumerStatefulWidget {
  const _NotificationsSheet();
  @override
  ConsumerState<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends ConsumerState<_NotificationsSheet> {
  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(notificationProvider.notifier).markAllRead();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D0D0D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(notifier),
            Expanded(
              child: notifications.isEmpty
                  ? _buildEmpty()
                  : _buildList(controller, notifications, notifier),
            ),
            _buildClearButton(notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() => Center(
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 36, height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  Widget _buildHeader(NotificationStore notifier) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('NOTIFICATIONS',
          style: Theme.of(context).textTheme.labelLarge),
        GestureDetector(
          onTap: () => notifier.markAllRead(),
          child: const Text('Mark all read',
            style: TextStyle(fontSize: 11, color: AppColors.primary,
                letterSpacing: 0.5)),
        ),
      ],
    ),
  );

  Widget _buildList(ScrollController controller, List<AppNotification> notifications, NotificationStore notifier) {
    final sections = [
      (label: 'Orders',      type: NotificationType.order),
      (label: 'Promotions',  type: NotificationType.promo),
      (label: 'Updates',     type: NotificationType.update),
    ];
    return ListView(
      controller: controller,
      children: [
        for (final s in sections)
          if (notifier.byType(s.type).isNotEmpty) ...[
            _SectionLabel(s.label),
            for (final n in notifier.byType(s.type))
              _NotifTile(notification: n,
                  onDismiss: () => notifier.remove(n.id)),
          ],
      ],
    );
  }

  Widget _buildEmpty() => const Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(LucideIcons.bellOff, size: 40, color: AppColors.onSurfaceVariant),
      SizedBox(height: 12),
      Text('No notifications', style: TextStyle(color: AppColors.onSurfaceVariant)),
    ]),
  );

  Widget _buildClearButton(NotificationStore notifier) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: GestureDetector(
        onTap: () => notifier.clearAll(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF2A2A2A)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.trash2, size: 14, color: AppColors.onSurfaceVariant),
              SizedBox(width: 6),
              Text('Clear all notifications',
                style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
    child: Text(label.toUpperCase(),
      style: const TextStyle(fontSize: 10, letterSpacing: 2,
          color: AppColors.onSurfaceVariant)),
  );
}

class _NotifTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onDismiss;
  const _NotifTile({required this.notification, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: AppColors.error.withValues(alpha: 0.15),
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(LucideIcons.trash2, color: AppColors.error, size: 18),
      ),
      onDismissed: (_) => onDismiss(),
      child: Container(
        color: notification.isRead ? Colors.transparent : const Color(0xFF0E0E0E),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBadge(notification.type),
              const SizedBox(width: 12),
              Expanded(child: _TileBody(notification)),
              if (!notification.isRead)
                Container(
                  width: 7, height: 7, margin: const EdgeInsets.only(top: 5),
                  decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final NotificationType type;
  const _IconBadge(this.type);

  @override
  Widget build(BuildContext context) {
    final (icon, bg, fg) = switch (type) {
      NotificationType.order  => (LucideIcons.package,     AppColors.success.withValues(alpha: 0.12),  AppColors.success),
      NotificationType.promo  => (LucideIcons.zap,          AppColors.primary.withValues(alpha: 0.12),  AppColors.primary),
      NotificationType.update => (LucideIcons.megaphone,   AppColors.secondary.withValues(alpha: 0.12), AppColors.secondary),
    };
    return Container(
      width: 38, height: 38,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 17, color: fg),
    );
  }
}

class _TileBody extends StatelessWidget {
  final AppNotification n;
  const _TileBody(this.n);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(n.title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
              color: AppColors.onBackground)),
        const SizedBox(height: 2),
        Text(n.body,
          style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant,
              height: 1.45)),
        if (n.chipLabel != null) ...[
          const SizedBox(height: 5),
          _Chip(n.chipLabel!, n.type),
        ],
        const SizedBox(height: 4),
        Text(_timeAgo(n.createdAt),
          style: const TextStyle(fontSize: 10, color: Color(0xFF5F5E5A))),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    return 'May ${dt.day}';
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final NotificationType type;
  const _Chip(this.label, this.type);

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (type) {
      NotificationType.order  => (AppColors.success.withValues(alpha: 0.13), AppColors.success),
      NotificationType.promo  => (AppColors.primary.withValues(alpha: 0.13), AppColors.primary),
      NotificationType.update => (AppColors.secondary.withValues(alpha: 0.13), AppColors.secondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}