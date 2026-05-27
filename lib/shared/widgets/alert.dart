// lib/shared/widgets/k_luxe_alert.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import 'glass_container.dart';

enum AlertType { success, error, info }

class KLuxeAlert extends StatelessWidget {
  final String message;
  final AlertType type;

  const KLuxeAlert({
    super.key,
    required this.message,
    this.type = AlertType.success,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color accentColor;

    switch (type) {
      case AlertType.error:
        icon = LucideIcons.alertCircle;
        accentColor = AppColors.error;
        break;
      case AlertType.info:
        icon = LucideIcons.info;
        accentColor = AppColors.primary;
        break;
      case AlertType.success:
      default:
        icon = LucideIcons.checkCircle;
        accentColor = AppColors.success;
    }

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: 16,
            blur: 20,
            color: AppColors.surface.withValues(alpha: 0.8),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}