// lib/core/utils/alert_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../shared/widgets/alert.dart';

class AlertService {
  static OverlayEntry? _currentEntry;
  static Timer? _timer;

  static void show(
    BuildContext context, 
    String message, {
    AlertType type = AlertType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    _currentEntry?.remove();
    _timer?.cancel();

    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0, // Anchor to the top
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.topCenter, // Center the alert horizontally
          child: _AlertAnimationWrapper(
            child: KLuxeAlert(message: message, type: type),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentEntry!);

    _timer = Timer(duration, () {
      _currentEntry?.remove();
      _currentEntry = null;
    });
}
}

// Simple wrapper for a smooth fade-in/slide-down effect
class _AlertAnimationWrapper extends StatefulWidget {
  final Widget child;
  const _AlertAnimationWrapper({required this.child});

  @override
  State<_AlertAnimationWrapper> createState() => _AlertAnimationWrapperState();
}

class _AlertAnimationWrapperState extends State<_AlertAnimationWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _offsetAnimation, child: widget.child);
  }
}