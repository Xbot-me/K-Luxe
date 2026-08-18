import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

class AppActionButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final Widget? child;
  final String? label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isFullWidth;
  final bool enabled;

  const AppActionButton({
    super.key,
    this.onPressed,
    this.child,
    this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 52,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.isFullWidth = true,
    this.enabled = true,
  });

  @override
  State<AppActionButton> createState() => _AppActionButtonState();
}

class _AppActionButtonState extends State<AppActionButton> {
  bool _isLoading = false;
  bool _isPressed = false;

  Future<void> _handlePress() async {
    if (!widget.enabled || _isLoading || widget.onPressed == null) return;

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      await widget.onPressed!();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? AppColors.primary;
    final fg = widget.foregroundColor ?? const Color(0xFF41117C);
    final canTap = widget.enabled && !_isLoading && widget.onPressed != null;

    Widget content;
    if (_isLoading) {
      content = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(fg),
        ),
      );
    } else if (widget.child != null) {
      content = widget.child!;
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 18, color: fg),
            const SizedBox(width: 8),
          ],
          if (widget.label != null)
            Text(
              widget.label!,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
        ],
      );
    }

    return AnimatedScale(
      scale: _isPressed && canTap ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: widget.enabled ? (_isLoading ? 0.6 : 1.0) : 0.45,
        duration: const Duration(milliseconds: 150),
        child: GestureDetector(
          onTapDown: canTap ? (_) => setState(() => _isPressed = true) : null,
          onTapUp: canTap ? (_) => setState(() => _isPressed = false) : null,
          onTapCancel: canTap ? () => setState(() => _isPressed = false) : null,
          onTap: canTap ? _handlePress : null,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: widget.height,
            width: widget.isFullWidth ? double.infinity : null,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.enabled ? bg : AppColors.surface,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: widget.enabled
                    ? bg.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}
