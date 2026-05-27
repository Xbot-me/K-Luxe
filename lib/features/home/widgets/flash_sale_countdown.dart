import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class FlashSaleCountdown extends StatefulWidget {
  /// Pass a real end time in production. Defaults to 6 hours from mount.
  final DateTime? endTime;
  const FlashSaleCountdown({super.key, this.endTime});

  @override
  State<FlashSaleCountdown> createState() => _FlashSaleCountdownState();
}

class _FlashSaleCountdownState extends State<FlashSaleCountdown> {
  late DateTime _endTime;
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _endTime = widget.endTime ?? DateTime.now().add(const Duration(hours: 6));
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final remaining = _endTime.difference(DateTime.now());
    if (mounted) {
      setState(() => _remaining = remaining.isNegative ? Duration.zero : remaining);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final h = _pad(_remaining.inHours);
    final m = _pad(_remaining.inMinutes.remainder(60));
    final s = _pad(_remaining.inSeconds.remainder(60));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.zap, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FLASH SALE',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Up to 40% off selected items',
                    style: TextStyle(
                      color: AppColors.onBackground,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _TimeUnit(value: h, label: 'HR'),
                const _Colon(),
                _TimeUnit(value: m, label: 'MIN'),
                const _Colon(),
                _TimeUnit(value: s, label: 'SEC'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeUnit extends StatelessWidget {
  final String value;
  final String label;
  const _TimeUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 8,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _Colon extends StatelessWidget {
  const _Colon();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12, left: 3, right: 3),
      child: Text(
        ':',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }
}