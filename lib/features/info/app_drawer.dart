import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_colors.dart';
import 'info_screen.dart';

// ── Custom drawer transition with eased curve ────────────────────────────────

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF111111),
      width: 288,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: _DrawerContent(onOpenPage: _openPage),
    );
  }

  void _openPage(BuildContext context, InfoPageType type) {
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => InfoScreen(type: type),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(opacity: curved, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }
}

// ── Stateful content so we can trigger entrance animations ───────────────────

class _DrawerContent extends StatefulWidget {
  final void Function(BuildContext, InfoPageType) onOpenPage;
  const _DrawerContent({required this.onOpenPage});

  @override
  State<_DrawerContent> createState() => _DrawerContentState();
}

class _DrawerContentState extends State<_DrawerContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header animates in from top
        _DrawerHeader()
            .animate(controller: _ctrl)
            .fadeIn(duration: 300.ms, curve: Curves.easeOut)
            .slideY(begin: -0.08, duration: 350.ms, curve: Curves.easeOutCubic),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                _SectionLabel('INFORMATION')
                    .animate(controller: _ctrl)
                    .fadeIn(delay: 80.ms, duration: 250.ms),

                const SizedBox(height: 4),

                _AnimatedNavItem(
                  index: 0,
                  ctrl: _ctrl,
                  icon: LucideIcons.store,
                  label: 'About K-Luxe',
                  iconBg: const Color(0xFF1E1530),
                  iconColor: AppColors.primary,
                  onTap: () => widget.onOpenPage(context, InfoPageType.about),
                ),
                _AnimatedNavItem(
                  index: 1,
                  ctrl: _ctrl,
                  icon: LucideIcons.helpCircle,
                  label: 'FAQ',
                  iconBg: const Color(0xFF1E1530),
                  iconColor: AppColors.primary,
                  onTap: () => widget.onOpenPage(context, InfoPageType.faq),
                ),
                _AnimatedNavItem(
                  index: 2,
                  ctrl: _ctrl,
                  icon: LucideIcons.mapPin,
                  label: 'Store Address',
                  iconBg: const Color(0xFF1E1530),
                  iconColor: AppColors.primary,
                  onTap: () => widget.onOpenPage(context, InfoPageType.storeAddress),
                ),
                _AnimatedNavItem(
                  index: 3,
                  ctrl: _ctrl,
                  icon: LucideIcons.headphones,
                  label: 'Contact Us',
                  iconBg: const Color(0xFF1E1530),
                  iconColor: AppColors.primary,
                  onTap: () => widget.onOpenPage(context, InfoPageType.contact),
                ),

                const SizedBox(height: 20),

                _SectionLabel('POLICIES')
                    .animate(controller: _ctrl)
                    .fadeIn(delay: 220.ms, duration: 250.ms),

                const SizedBox(height: 4),

                _AnimatedNavItem(
                  index: 4,
                  ctrl: _ctrl,
                  icon: LucideIcons.refreshCw,
                  label: 'Return Policy',
                  iconBg: const Color(0xFF231428),
                  iconColor: AppColors.secondary,
                  onTap: () => widget.onOpenPage(context, InfoPageType.returnPolicy),
                ),
                _AnimatedNavItem(
                  index: 5,
                  ctrl: _ctrl,
                  icon: LucideIcons.fileText,
                  label: 'Terms & Conditions',
                  iconBg: const Color(0xFF231428),
                  iconColor: AppColors.secondary,
                  onTap: () => widget.onOpenPage(context, InfoPageType.terms),
                ),
                _AnimatedNavItem(
                  index: 6,
                  ctrl: _ctrl,
                  icon: LucideIcons.shield,
                  label: 'Privacy Policy',
                  iconBg: const Color(0xFF231428),
                  iconColor: AppColors.secondary,
                  onTap: () => widget.onOpenPage(context, InfoPageType.privacy),
                ),
                _AnimatedNavItem(
                  index: 7,
                  ctrl: _ctrl,
                  icon: LucideIcons.alertCircle,
                  label: 'Submit a Claim',
                  iconBg: const Color(0xFF231428),
                  iconColor: AppColors.secondary,
                  onTap: () => widget.onOpenPage(context, InfoPageType.submitClaim),
                ),

                const SizedBox(height: 20),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(color: Color(0xFF1C1C1C), height: 1),
                ).animate(controller: _ctrl).fadeIn(delay: 400.ms, duration: 250.ms),

                const SizedBox(height: 20),

                _SectionLabel('FOLLOW US')
                    .animate(controller: _ctrl)
                    .fadeIn(delay: 420.ms, duration: 250.ms),

                const SizedBox(height: 12),

                const _SocialRow()
                    .animate(controller: _ctrl)
                    .fadeIn(delay: 440.ms, duration: 280.ms)
                    .slideY(
                      begin: 0.12,
                      delay: 440.ms,
                      duration: 280.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        _DrawerFooter()
            .animate(controller: _ctrl)
            .fadeIn(delay: 480.ms, duration: 250.ms),
      ],
    );
  }
}

// ── Animated nav item with stagger + press feedback ──────────────────────────

class _AnimatedNavItem extends StatefulWidget {
  final int index;
  final AnimationController ctrl;
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.index,
    required this.ctrl,
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final delay = Duration(milliseconds: 100 + widget.index * 45);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: _pressed ? const Color(0xFF1A1A1A) : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: _pressed
                        ? widget.iconColor.withValues(alpha: 0.18)
                        : widget.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, size: 16, color: widget.iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13,
                      color: _pressed
                          ? AppColors.onBackground
                          : const Color(0xFFCCC8D4),
                    ),
                  ),
                ),
                AnimatedSlide(
                  offset: _pressed ? const Offset(0.15, 0) : Offset.zero,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  child: Icon(
                    LucideIcons.chevronRight,
                    size: 14,
                    color: _pressed
                        ? widget.iconColor.withValues(alpha: 0.6)
                        : const Color(0xFF2E2838),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(controller: widget.ctrl)
        .fadeIn(delay: delay, duration: 280.ms, curve: Curves.easeOut)
        .slideX(
          begin: -0.06,
          delay: delay,
          duration: 320.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: const Color(0xFF0A0A0A),
      padding: EdgeInsets.fromLTRB(24, top + 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'K-LUXE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 6,
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 18),
            child: Text(
              'OFFICIAL LICENSED MERCH',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: Color(0xFF4A4555),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: const _HanteoCertCard()
                    .animate()
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      delay: 150.ms,
                      duration: 380.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(delay: 150.ms, duration: 280.ms),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: const _BillboardCertCard()
                    .animate()
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      delay: 220.ms,
                      duration: 380.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(delay: 220.ms, duration: 280.ms),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Cert cards ────────────────────────────────────────────────────────────────

class _HanteoCertCard extends StatelessWidget {
  const _HanteoCertCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF272727), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HANTEO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: Color(0xFFC8BCD4),
            ),
          ),
          const Divider(color: Color(0xFF222222), height: 14),
          const Text(
            'FAMILY MEMBER',
            style: TextStyle(fontSize: 9, color: Color(0xFF4A4555), letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 5, height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 5),
              const Flexible(
                child: Text(
                  'HF0001KPU001',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF7A6D8A),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'SINCE 1983 · CERTIFIED',
            style: TextStyle(fontSize: 9, color: Color(0xFF4A4555), letterSpacing: 0.8),
          ),
        ],
      ),
    );
  }
}

class _BillboardCertCard extends StatelessWidget {
  const _BillboardCertCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF272727), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 18, height: 18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Center(
                  child: Text(
                    'b',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'billboard',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: Color(0xFFC8BCD4),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF222222), height: 14),
          const Text(
            'CHART COUNTED',
            style: TextStyle(fontSize: 9, color: Color(0xFF4A4555), letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 5, height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 5),
              const Flexible(
                child: Text(
                  'ALBUMS & MERCH',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF7A6D8A),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'ALL PURCHASES ELIGIBLE',
            style: TextStyle(fontSize: 9, color: Color(0xFF4A4555), letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          letterSpacing: 2,
          color: Color(0xFF3D3849),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Social row ────────────────────────────────────────────────────────────────

class _SocialRow extends StatelessWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _SocialBtn(icon: FontAwesomeIcons.instagram, label: 'Instagram'),
          const SizedBox(width: 10),
          _SocialBtn(icon: FontAwesomeIcons.facebook, label: 'Facebook'),
          const SizedBox(width: 10),
          _SocialBtn(icon: FontAwesomeIcons.xTwitter, label: 'X / Twitter'),
          const SizedBox(width: 10),
          _SocialBtn(icon: FontAwesomeIcons.youtube, label: 'YouTube'),
        ],
      ),
    );
  }
}

class _SocialBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  const _SocialBtn({required this.icon, required this.label});

  @override
  State<_SocialBtn> createState() => _SocialBtnState();
}

class _SocialBtnState extends State<_SocialBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {},
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _pressed
                ? AppColors.primary.withValues(alpha: 0.12)
                : const Color(0xFF181818),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _pressed
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : const Color(0xFF252525),
              width: 0.5,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: _pressed ? AppColors.primary : const Color(0xFF9C94A8),
          ),
        ),
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _DrawerFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 24, right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF1A1A1A), width: 0.5)),
      ),
      child: const Text(
        'K-LUXE  ·  V1.0.0',
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 1.5,
          color: Color(0xFF2E2838),
        ),
      ),
    );
  }
}