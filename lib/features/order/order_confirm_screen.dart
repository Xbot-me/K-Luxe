import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/primary_button.dart';
import '../home/home_screen.dart';

class OrderConfirmScreen extends StatefulWidget {
  final String orderId;

  const OrderConfirmScreen({super.key, required this.orderId});

  @override
  State<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen>
    with TickerProviderStateMixin {
  // We use TickerProviderStateMixin (not Single...) because
  // we have multiple AnimationControllers on one screen

  // 1 — checkmark circle scale pop
  late AnimationController _checkController;
  late Animation<double> _checkScale;

  // 2 — content block fade + slide up
  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  // 3 — buttons fade in last
  late AnimationController _btnController;
  late Animation<double> _btnFade;

  @override
  void initState() {
    super.initState();

    // ── Check animation: fast scale pop ──
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut, // bouncy pop effect
    );

    // ── Content slides up after check appears ──
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));

    // ── Buttons appear last ──
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _btnFade = CurvedAnimation(
      parent: _btnController,
      curve: Curves.easeIn,
    );

    // Sequence: check → content → buttons
    // Each starts after the previous one is partway through
    _checkController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _contentController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _btnController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _contentController.dispose();
    _btnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // No AppBar — this is a celebration screen, full canvas
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Animated checkmark ──
              _buildCheckmark(),

              const SizedBox(height: 24),

              // ── Title + subtitle ──
              _buildHeading(),

              const SizedBox(height: 32),

              // ── Order details card ──
              _buildOrderCard(),

              const Spacer(flex: 2),

              // ── Action buttons ──
              _buildButtons(context),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bouncy checkmark circle ──
  Widget _buildCheckmark() {
    return ScaleTransition(
      scale: _checkScale,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.successLight,
          border: Border.all(
            color: AppColors.success.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }

  // ── "Order Placed!" heading ──
  Widget _buildHeading() {
    return FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: _contentSlide,
        child: Column(
          children: [
            const Text(
              'Order Placed!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your order has been confirmed.\nWe\'ll deliver it in 2–3 business days.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Order detail card ──
  Widget _buildOrderCard() {
    return FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: _contentSlide,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            children: [
              // Order ID row — highlighted
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order ID',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '#${widget.orderId}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Detail rows
              _detailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Order Date',
                value: _formatDate(DateTime.now()),
              ),
              const Divider(height: 20, color: AppColors.border),
              _detailRow(
                icon: Icons.local_shipping_outlined,
                label: 'Estimated Delivery',
                value: _formatDate(
                  DateTime.now().add(const Duration(days: 3)),
                ),
              ),
              const Divider(height: 20, color: AppColors.border),
              _detailRow(
                icon: Icons.payment_outlined,
                label: 'Payment',
                value: 'bKash',
              ),
              const Divider(height: 20, color: AppColors.border),

              // Total row — larger
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.receipt_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Total Paid',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  // We can't read CartManager here since it was cleared.
                  // In a real app you'd pass the total as a parameter.
                  const Text(
                    'See receipt',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Icon(icon, size: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ── Track Order + Continue Shopping buttons ──
  Widget _buildButtons(BuildContext context) {
    return FadeTransition(
      opacity: _btnFade,
      child: Column(
        children: [
          // Primary — track order
          PrimaryButton(
            label: 'Track Order',
            onPressed: () {
              // TODO: Navigate to order tracking screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order tracking coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Secondary — go back to shopping
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                // pushAndRemoveUntil clears everything and goes to Home
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  ),
                  (route) => false, // remove ALL previous routes
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppColors.border,
                  width: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue Shopping',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Formats DateTime to "Apr 28, 2026" style
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}