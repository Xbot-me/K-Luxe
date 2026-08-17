import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/cart/cart_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';

class HomeBottomNav extends ConsumerWidget {
  final int currentTab;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onSearchTap;

  const HomeBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartProvider).fold(0, (sum, i) => sum + i.quantity);
    return GlassContainer(
          height: 80,
          blur: 25,
          borderRadius: 40,
          color: AppColors.surface.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(horizontal: 8), // reduced from 16 to fit 5 items
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: LucideIcons.home,
                label: 'Home',
                isActive: currentTab == 0,
                onTap: () => onTabChanged(0),
              ),
              _NavItem(
                icon: LucideIcons.search,
                label: 'Explore',
                isActive: currentTab == 1,
                onTap: onSearchTap,
              ),
              // ── Shop (new) ──────────────────────────────────────────
              _NavItem(
                icon: LucideIcons.store,
                label: 'Shop',
                isActive: currentTab == 2,
                onTap: () => onTabChanged(2),
              ),
              // ── Cart (was index 2, now 3) ───────────────────────────
              _NavItem(
                icon: LucideIcons.shoppingBag,
                label: 'Cart',
                isActive: currentTab == 3,
                cartCount: cartCount,
                onTap: () => onTabChanged(3),
              ),
              // ── Profile (was index 3, now 4) ───────────────────────
              _NavItem(
                icon: LucideIcons.user,
                label: 'Profile',
                isActive: currentTab == 4,
                onTap: () => onTabChanged(4),
              ),
            ],
          ),
        );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int cartCount;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.cartCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                size: 24,
              ),
              if (cartCount > 0)
                Positioned(
                  top: -6,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedScale(
              scale: isActive ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}