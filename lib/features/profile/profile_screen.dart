import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../auth/login_screen.dart';
import '../order/order_history_screen.dart';
import '../../shared/widgets/glass_container.dart';
import '../auth/models/user_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  // ── Live user from AuthRepository ──
  User? get _user => ref.read(authRepositoryProvider).currentUser;

  // ── Mock data ──
  final int _orderCount = 7;
  final int _wishlistCount = 4;
  final int _reviewCount = 12;
  final int _loyaltyPoints = 12450;
  final int _pointsToNextTier = 2550;
  final String _tierName = 'VIP ULTRA';
  final double _loyaltyProgress = 0.83; // 12450 / 15000

  // ── Derived display values from live user ──
  String get _displayName {
    final u = _user;
    if (u == null) return 'Guest';
    if (u.displayName.isNotEmpty) return u.displayName;
    return u.email.split('@').first;
  }

  String get _displayEmail => _user?.email ?? '';

  String get _initials {
    final u = _user;
    if (u == null) return 'G';
    return u.initials.isNotEmpty ? u.initials : '?';
  }

  // ── Sign out ──
  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text(
          'Sign out?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'You will need to sign in again to access your account.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await ref.read(authRepositoryProvider).logout();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Hero header ──
            _buildHeroHeader(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // ── Stats row ──
                  _buildStatsRow()
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // ── Loyalty card ──
                  _buildLoyaltyCard()
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // ── Menu sections ──
                  _buildSectionLabel('Orders & Wishlist'),
                  const SizedBox(height: 12),
                  _buildMenuGroup([
                    _MenuItemData(
                      icon: LucideIcons.receipt,
                      label: 'My Orders',
                      badge: '$_orderCount',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OrderHistoryScreen(),
                        ),
                      ),
                    ),
                    _MenuItemData(
                      icon: LucideIcons.heart,
                      label: 'Wishlist',
                      badge: '$_wishlistCount',
                      onTap: () {},
                    ),
                  ]).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 20),
                  _buildSectionLabel('Account'),
                  const SizedBox(height: 12),
                  _buildMenuGroup([
                    _MenuItemData(
                      icon: LucideIcons.user,
                      label: 'Edit Profile',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      icon: LucideIcons.mapPin,
                      label: 'Saved Addresses',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      icon: LucideIcons.creditCard,
                      label: 'Payment Methods',
                      onTap: () {},
                    ),
                  ]).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

                  const SizedBox(height: 20),
                  _buildSectionLabel('Support'),
                  const SizedBox(height: 12),
                  _buildMenuGroup([
                    _MenuItemData(
                      icon: LucideIcons.bell,
                      label: 'Notifications',
                      trailing: Switch(
                        value: true,
                        onChanged: (_) {},
                        activeColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onTap: () {},
                    ),
                    _MenuItemData(
                      icon: LucideIcons.helpCircle,
                      label: 'Help & Support',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      icon: LucideIcons.info,
                      label: 'About',
                      onTap: () {},
                    ),
                  ]).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

                  const SizedBox(height: 20),

                  // ── Sign out ──
                  _buildMenuGroup([
                    _MenuItemData(
                      icon: LucideIcons.logOut,
                      label: 'Sign Out',
                      labelColor: AppColors.error,
                      iconColor: AppColors.error,
                      onTap: _signOut,
                    ),
                  ]).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 24),

                  Text(
                    'kpopusa v1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.2),
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero header with avatar + name ──
  Widget _buildHeroHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background gradient banner
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.3),
                AppColors.background,
              ],
            ),
          ),
        ),

        // Safe area padding for status bar
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 24,
          right: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROFILE',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              IconButton(
                icon: const Icon(
                  LucideIcons.settings,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // Avatar + info centered
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 56,
            bottom: 60,
          ),
          child: Center(
            child: Column(
              children: [
                // Avatar ring
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Text(
                        _initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 12),

                Text(
                  _displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3),

                const SizedBox(height: 4),

                Text(
                  _displayEmail,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 10),

                // Tier badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: const Text(
                    'LUXE MEMBER',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Stats row ──
  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatCard(
          value: '$_orderCount',
          label: 'Orders',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
          ),
        ),
        const SizedBox(width: 12),
        _StatCard(value: '$_wishlistCount', label: 'Wishlist', onTap: () {}),
        const SizedBox(width: 12),
        _StatCard(value: '$_reviewCount', label: 'Reviews', onTap: () {}),
      ],
    );
  }

  // ── Loyalty points card ──
  Widget _buildLoyaltyCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LOYALTY POINTS',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(LucideIcons.star, color: AppColors.primary, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _loyaltyPoints.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (m) => '${m[1]},',
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'PTS',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                FractionallySizedBox(
                  widthFactor: _loyaltyProgress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_pointsToNextTier points to $_tierName',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.3),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildMenuGroup(List<_MenuItemData> items) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isLast = index == items.length - 1;
            return Column(
              children: [
                _buildMenuTile(item),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 56,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMenuTile(_MenuItemData item) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: (item.iconColor ?? AppColors.primary).withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.icon,
                size: 16,
                color: item.iconColor ?? AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: item.labelColor ?? Colors.white,
                ),
              ),
            ),
            item.trailing ??
                (item.badge != null
                    ? _buildBadge(item.badge!)
                    : Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.2),
                      )),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        count,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── Stat card ──
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback onTap;

  const _StatCard({
    required this.value,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Menu item data class ──
class _MenuItemData {
  final IconData icon;
  final String label;
  final String? badge;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _MenuItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.trailing,
    this.iconColor,
    this.labelColor,
  });
}
