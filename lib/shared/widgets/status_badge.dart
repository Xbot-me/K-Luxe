import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/order/models/order_models.dart';

// Reusable colored badge for order status.
// Used in both OrderHistory and order detail cards.
class StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }

  String get _label {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get _bgColor {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warningLight;
      case OrderStatus.confirmed:
        return AppColors.primaryLight;
      case OrderStatus.shipped:
        return AppColors.primaryLight;
      case OrderStatus.delivered:
        return AppColors.successLight;
      case OrderStatus.cancelled:
        return AppColors.errorLight;
    }
  }

  Color get _textColor {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.primary;
      case OrderStatus.shipped:
        return AppColors.primaryDark;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }
}