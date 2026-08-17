import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_application_1/features/checkout/models/shipping_rate.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/cart/cart_manager.dart';
import '../../core/constants/dummy_data.dart';
import '../order/order_confirm_screen.dart';
import 'models/address_model.dart';
import '../../features/order/repositories/order_repository.dart';
import '../../core/network/api_exception.dart';
import './services/shipping_service.dart';
import '../../shared/widgets/glass_container.dart';
import 'payment/hosted_payment_screen.dart';

enum PaymentMethod { card, bkash, cod }

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _shippingService = ShippingService();

  // Address State
  late List<Address> _addresses;
  late String _selectedAddressId;

  // Shipping State
  List<ShippingRate> _availableRates = [];
  ShippingRate? _selectedRate;
  bool _isLoadingRates = false;
  bool _isUpdatingShipping = false;

  // Payment State
  PaymentMethod _selectedPayment = PaymentMethod.bkash;
  bool _isPlacingOrder = false;

  // Dynamic Totals
  double get subtotal => ref.watch(cartProvider).fold(0.0, (sum, i) => sum + i.totalPrice);
  double get shippingCost => _selectedRate?.price ?? 0;
  double get total => subtotal + shippingCost;

  // Helper: get the currently selected Address object
  Address get _selectedAddress =>
      _addresses.firstWhere((a) => a.id == _selectedAddressId);

  @override
  void initState() {
    super.initState();
    _addresses = List.from(dummyAddresses);
    _selectedAddressId = _addresses
        .firstWhere((a) => a.isDefault, orElse: () => _addresses.first)
        .id;
    _fetchShippingRates(_selectedAddressId);
  }

  // ── 1. Fetch rates based on address ──
  Future<void> _fetchShippingRates(String addressId) async {
    setState(() {
      _isLoadingRates = true;
      _selectedRate = null;
      _availableRates = [];
    });

    try {
      final rates = await _shippingService.getRates(
        addressId: addressId,
        cartToken: ref.read(cartProvider.notifier).cartToken!,
      );
      if (!mounted) return;
      setState(() => _availableRates = rates);
      if (rates.isNotEmpty) await _selectShippingRate(rates.first);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingRates = false);
    }
  }

  // ── 2. Sync selected rate with BFF ──
  Future<void> _selectShippingRate(ShippingRate rate) async {
    setState(() {
      _selectedRate = rate;
      _isUpdatingShipping = true;
    });
    try {
      final confirmedRate = await _shippingService.selectRate(
        rateId: rate.id,
        cartToken: ref.read(cartProvider.notifier).cartToken!,
      );
      if (mounted) setState(() => _selectedRate = confirmedRate);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply shipping: ${e.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingShipping = false);
    }
  }

  void _onAddressChanged(String newAddressId) {
    if (_selectedAddressId == newAddressId) return;
    setState(() => _selectedAddressId = newAddressId);
    _fetchShippingRates(newAddressId);
  }

  // ── 3. Add New Address Flow ──
  void _showAddAddressModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddAddressBottomSheet(
        onSave: (Address newAddress) {
          setState(() {
            _addresses.insert(0, newAddress);
            _selectedAddressId = newAddress.id;
          });
          _fetchShippingRates(newAddress.id);
        },
      ),
    );
  }

  // ── 4. Build billing map from Address for Authorize.net ──
  //
  // Authorize.net's billTo requires:
  //   firstName, lastName, address, city, state, zip, country, phoneNumber
  //
  // Since we only have a shipping address (no separate billing), we use it
  // as billing. We split `name` into firstName/lastName and map our
  // address fields directly.
  Map<String, String> _buildBillingPayload(Address address) {
    // Split full name into first / last. If only one word, put it in firstName.
    final nameParts = address.name.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    // Combine line1 + line2 into a single address string for Authorize.net
    final streetAddress = address.line2.isNotEmpty
        ? '${address.line1}, ${address.line2}'
        : address.line1;

    return {
      'firstName': firstName,
      'lastName': lastName,
      'address': streetAddress,
      'city': address.city,
      // state/zip are required by Authorize.net but Bangladesh doesn't use
      // US-style state codes. We send empty strings — the sandbox accepts them.
      // For production, add a state/zip field to your Address model.
      'state': '',
      'zip': '',
      'country': 'BD',
      'phoneNumber': address.phone,
    };
  }

  // ── 5. Place order ──
  Future<void> _placeOrder() async {
    if (_selectedRate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a shipping method.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      // ── COD / bKash (normal BFF flow) ──
      if (_selectedPayment != PaymentMethod.card) {
        final orderId = await ref.read(orderRepositoryProvider).placeOrder(
          addressId: _selectedAddressId,
          paymentMethod: _selectedPayment.name,
        );
        _handleSuccessfulOrder(orderId);
        return;
      }

      // ── Card → Authorize.net Hosted Payment Flow ──

      // Step 1: Create session on BFF.
      // We pass the billing address so the BFF can prefill Authorize.net's
      // billTo fields. Without this the hosted page JS crashes on billTo = null.
      final billing = _buildBillingPayload(_selectedAddress);

      final sessionResponse = await ApiClient.post(
        ApiEndpoints.createPaymentSession,
        body: {
          'amount': total,
          'billing': billing, // ← the fix: always send billing
        },
      );

      final String hostedUrl = sessionResponse['hostedPaymentUrl'] as String;
      final String orderId = sessionResponse['orderId'] as String;
      final String paymentToken = sessionResponse['paymentToken'] as String;

      if (!mounted) return;

      // Step 2: Open Authorize.net hosted page in an in-app WebView.
      // We use flutter_inappwebview which handles Authorize.net's CSP correctly.
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => HostedPaymentScreen(
            hostedUrl: hostedUrl,
            paymentToken: paymentToken,
            // Deep-link scheme that Authorize.net redirects to after payment.
            // Configure this in AndroidManifest.xml & Info.plist too.
            redirectScheme: '',
          ),
        ),
      );

      if (!mounted) return;

      // Step 3: Handle WebView result
      
if (result == null || result == 'cancelled') {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Payment cancelled.'),
      backgroundColor: Colors.orange,
    ),
  );
  return;
}

// Verify with BFF using the orderId we already have
final verifyResponse = await ApiClient.get(
  ApiEndpoints.verifyPayment,
  queryParams: {'orderId': orderId},
);
final status = verifyResponse['status'] as String? ?? '';
if (status == 'processing' || status == 'pending') {
  _handleSuccessfulOrder(orderId);
} else {
  throw const ApiException('Payment verification failed.');
}
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  void _handleSuccessfulOrder(String orderId) {
    ref.read(cartProvider.notifier).clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => OrderConfirmScreen(orderId: orderId)),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CHECKOUT',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(letterSpacing: 2.0),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Addresses ──
            const _SectionHeader(
                icon: LucideIcons.mapPin, title: 'Delivery Address'),
            const SizedBox(height: 16),
            ..._addresses.map(
              (address) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ModernAddressCard(
                  address: address,
                  isSelected: address.id == _selectedAddressId,
                  onTap: () => _onAddressChanged(address.id),
                ),
              ),
            ),

            // Add Address Button
            GestureDetector(
              onTap: _showAddAddressModal,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.plus,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Add New Address',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Shipping Methods ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionHeader(
                    icon: LucideIcons.truck, title: 'Shipping Method'),
                if (_isUpdatingShipping)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ).animate().fade(),
              ],
            ),
            const SizedBox(height: 16),
            _buildShippingSection(),

            const SizedBox(height: 32),

            // ── Payment Methods ──
            const _SectionHeader(
                icon: LucideIcons.creditCard, title: 'Payment Method'),
            const SizedBox(height: 16),
            _buildPaymentSection(),

            const SizedBox(height: 32),

            // ── Order Summary ──
            const _SectionHeader(
                icon: LucideIcons.receipt, title: 'Order Summary'),
            const SizedBox(height: 16),
            _buildOrderSummary(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingSection() {
    if (_isLoadingRates) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ).animate().fade(duration: 300.ms);
    }

    if (_availableRates.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: Text(
            'No shipping rates available for this address.',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _availableRates.map((rate) {
          final isSelected = rate.id == _selectedRate?.id;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                if (!isSelected) _selectShippingRate(rate);
              },
              child: SizedBox(
                width: 160,
                child: _ModernDeliveryCard(
                  title: rate.title,
                  time: rate.estimatedDays,
                  provider: rate.provider,
                  price: rate.price == 0
                      ? 'Free'
                      : '${rate.currency}${rate.price.toStringAsFixed(0)}',
                  isActive: isSelected,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn().slideX(
          begin: 0.1,
          duration: 400.ms,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildPaymentSection() {
    final payments = [
      {
        'method': PaymentMethod.bkash,
        'title': 'bKash',
        'icon': LucideIcons.smartphone
      },
      {
        'method': PaymentMethod.card,
        'title': 'Card',
        'icon': LucideIcons.creditCard
      },
      {
        'method': PaymentMethod.cod,
        'title': 'Cash',
        'icon': LucideIcons.banknote
      },
    ];

    return Row(
      children: payments.map((p) {
        final method = p['method'] as PaymentMethod;
        final isActive = method == _selectedPayment;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedPayment = method),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.primary : Colors.white10,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      p['icon'] as IconData,
                      color: isActive ? AppColors.primary : Colors.white54,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p['title'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? AppColors.primary : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderSummary() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ...ref.watch(cartProvider).map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(item.product.featuredImage.url),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Qty: ${item.quantity}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '৳${item.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.white10, height: 32),
          _SummaryRow(
              label: 'Subtotal', value: '৳${subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Delivery',
            value: _isLoadingRates
                ? '...'
                : (shippingCost == 0
                    ? 'FREE'
                    : '৳${shippingCost.toStringAsFixed(0)}'),
            valueColor: shippingCost == 0 && !_isLoadingRates
                ? AppColors.primary
                : Colors.white,
          ),
          const Divider(color: Colors.white10, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontSize: 18, color: Colors.white54)),
              Text(
                '৳${total.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isDisabled = _isLoadingRates ||
        _isUpdatingShipping ||
        _availableRates.isEmpty ||
        _isPlacingOrder;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.9),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: GestureDetector(
        onTap: isDisabled ? null : _placeOrder,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: isDisabled
                ? LinearGradient(
                    colors: [Colors.grey.shade800, Colors.grey.shade900])
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!isDisabled)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: _isPlacingOrder
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.lock, color: Colors.white, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      'PAY ৳${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
        ).animate(target: _isPlacingOrder ? 0 : 1).shimmer(duration: 2.seconds),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Address Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddAddressBottomSheet extends StatefulWidget {
  final Function(Address) onSave;
  const _AddAddressBottomSheet({required this.onSave});

  @override
  State<_AddAddressBottomSheet> createState() => _AddAddressBottomSheetState();
}

class _AddAddressBottomSheetState extends State<_AddAddressBottomSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _line1Controller.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newAddress = Address(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      line1: _line1Controller.text.trim(),
      line2: _line2Controller.text.trim(),
      city: _cityController.text.trim(),
      isDefault: false,
    );

    widget.onSave(newAddress);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Add New Address',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildInputField(
                        label: 'Full Name',
                        icon: LucideIcons.user,
                        controller: _nameController),
                    const SizedBox(height: 16),
                    _buildInputField(
                        label: 'Phone Number',
                        icon: LucideIcons.phone,
                        controller: _phoneController,
                        isNumber: true),
                    const SizedBox(height: 16),
                    _buildInputField(
                        label: 'Address Line 1',
                        icon: LucideIcons.mapPin,
                        controller: _line1Controller),
                    const SizedBox(height: 16),
                    _buildInputField(
                        label: 'Address Line 2 (Optional)',
                        icon: LucideIcons.map,
                        controller: _line2Controller),
                    const SizedBox(height: 16),
                    _buildInputField(
                        label: 'City',
                        icon: LucideIcons.building,
                        controller: _cityController),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: _handleSave,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            'SAVE ADDRESS',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isNumber = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white30, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType:
                  isNumber ? TextInputType.phone : TextInputType.text,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: label,
                hintStyle:
                    const TextStyle(color: Colors.white30, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared UI Components
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
        ),
      ],
    );
  }
}

class _ModernAddressCard extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModernAddressCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color:
                isSelected ? AppColors.primary.withValues(alpha: 0.5) : Colors.white10,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? LucideIcons.checkCircle : LucideIcons.circle,
              color: isSelected ? AppColors.primary : Colors.white30,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                                fontSize: 9,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    address.phone,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.fullAddress,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernDeliveryCard extends StatelessWidget {
  final String title;
  final String time;
  final String provider;
  final String price;
  final bool isActive;

  const _ModernDeliveryCard({
    required this.title,
    required this.time,
    required this.provider,
    required this.price,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isActive ? AppColors.primary : Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                    color: isActive ? Colors.white : Colors.white70,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isActive ? LucideIcons.checkCircle : LucideIcons.circle,
                size: 14,
                color: isActive ? AppColors.primary : Colors.white30,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isActive ? AppColors.primary : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider,
            style: const TextStyle(
                color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Text(
            time,
            style: const TextStyle(color: Colors.white30, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}