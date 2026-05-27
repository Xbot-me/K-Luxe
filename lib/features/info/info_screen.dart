import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';

enum InfoPageType {
  about,
  faq,
  storeAddress,
  contact,
  returnPolicy,
  terms,
  privacy,
  submitClaim,
}

class InfoScreen extends StatelessWidget {
  final InfoPageType type;
  const InfoScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final config = _pageConfig(type);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _InfoAppBar(title: config.title, accent: config.accent),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
            sliver: SliverList(
              delegate: SliverChildListDelegate(config.buildContent(context)),
            ),
          ),
        ],
      ),
    );
  }

  _PageConfig _pageConfig(InfoPageType t) {
    switch (t) {
      case InfoPageType.about:
        return _PageConfig(
          title: 'About K-Luxe',
          accent: AppColors.primary,
          buildContent: (_) => [
            const _SectionHeading('Who We Are'),
            const _BodyText(
              'K-LUXE is your premier destination for 100% official, licensed K-pop merchandise and music. '
              'We carry only authentic albums, photocards, lightsticks, and branded merch directly sourced '
              'from official distributors.',
            ),
            const SizedBox(height: 24),
            const _SectionHeading('Chart-Certified Store'),
            const _BodyText(
              'Every album purchase at K-LUXE counts toward both Hanteo Chart and Billboard Chart rankings. '
              'We are a proud member of the 2026 Hanteo Family (HF0001KPU001), ensuring your support '
              'reaches your favorite artists directly.',
            ),
            const SizedBox(height: 24),
            _CertBanner(),
            const SizedBox(height: 24),
            const _SectionHeading('Our Mission'),
            const _BodyText(
              'To bring the K-pop experience closer to fans around the world — with authentic products, '
              'fast shipping, and a community built on passion for Korean music and culture.',
            ),
          ],
        );

      case InfoPageType.faq:
        return _PageConfig(
          title: 'FAQ',
          accent: AppColors.primary,
          buildContent: (_) => [
            const _FaqItem(
              q: 'Do purchases count toward Hanteo and Billboard charts?',
              a: 'Yes! All album purchases at K-LUXE are counted toward both Hanteo Chart and Billboard Chart. '
                 'We are a certified Hanteo Family member (HF0001KPU001).',
            ),
            const _FaqItem(
              q: 'How long does shipping take?',
              a: 'We ship every day. Domestic orders typically arrive in 3–7 business days. '
                 'International orders vary by destination but are usually 7–21 business days.',
            ),
            const _FaqItem(
              q: 'Are all products official and licensed?',
              a: 'Absolutely. K-LUXE carries only 100% official, licensed merchandise sourced directly '
                 'from authorized distributors. No bootlegs, ever.',
            ),
            const _FaqItem(
              q: 'Can I get a free photocard?',
              a: 'Yes! Spend \$50 or more in a single order and receive a free official photocard. '
                 'Check our current promotions on the home screen for details.',
            ),
            const _FaqItem(
              q: 'What payment methods do you accept?',
              a: 'We accept Mastercard, Visa, and Discover. Gift cards and international cards are not accepted at this time.',
            ),
            const _FaqItem(
              q: 'Can I cancel or modify my order?',
              a: 'Orders can be cancelled or modified within 1 hour of placement. After that, '
                 'please use the Submit a Claim option to request changes.',
            ),
          ],
        );

      case InfoPageType.storeAddress:
        return _PageConfig(
          title: 'Store Address',
          accent: AppColors.primary,
          buildContent: (context) => [
            _AddressCard(),
            const SizedBox(height: 24),
            const _SectionHeading('Customer Service Hours'),
            _HoursTable(),
            const SizedBox(height: 24),
            const _SectionHeading('Get In Touch'),
            const _BodyText(
              'Visit us in-store or reach out via the Contact Us page for any inquiries. '
              'Our staff are happy to help you find the perfect K-pop merch.',
            ),
          ],
        );

      case InfoPageType.contact:
        return _PageConfig(
          title: 'Contact Us',
          accent: AppColors.primary,
          buildContent: (_) => [
            const _BodyText(
              'Have a question or need help with your order? Reach out to us through any of the channels below.',
            ),
            const SizedBox(height: 24),
            _ContactTile(
              icon: LucideIcons.mail,
              label: 'Email',
              value: 'support@kluxe.com',
            ),
            _ContactTile(
              icon: LucideIcons.phone,
              label: 'Phone',
              value: '+1 (800) K-LUXE-01',
            ),
            _ContactTile(
              icon: LucideIcons.clock,
              label: 'Hours',
              value: 'Mon–Sat 11AM–7PM\nSun 11AM–6PM',
            ),
            const SizedBox(height: 24),
            const _SectionHeading('Social Media'),
            const _BodyText(
              'DM us on Instagram @kluxe.official for the fastest response. '
              'We typically reply within a few hours during business hours.',
            ),
          ],
        );

      case InfoPageType.returnPolicy:
        return _PageConfig(
          title: 'Return Policy',
          accent: AppColors.secondary,
          buildContent: (_) => [
            _PolicyHighlight(
              text: '14-day return window on most items',
              color: AppColors.secondary,
            ),
            const SizedBox(height: 24),
            const _SectionHeading('Eligible Items'),
            const _BodyText(
              'Items may be returned within 14 days of delivery if they are unused, unopened, '
              'and in original packaging. Albums with broken seals or opened photocards are not eligible for return.',
            ),
            const SizedBox(height: 20),
            const _SectionHeading('Non-Returnable Items'),
            const _BulletList(items: [
              'Opened albums or music media',
              'Photocards removed from original packaging',
              'Digital downloads or codes',
              'Items marked as final sale',
              'Customized or personalized merchandise',
            ]),
            const SizedBox(height: 20),
            const _SectionHeading('How to Return'),
            const _BodyText(
              'To initiate a return, use the Submit a Claim option in this menu or contact our support team. '
              'Once approved, ship the item back with your order number clearly marked. '
              'Refunds are processed within 5–10 business days of receiving the return.',
            ),
            const SizedBox(height: 20),
            const _SectionHeading('Damaged or Incorrect Items'),
            const _BodyText(
              'If you received a damaged or incorrect item, please contact us within 48 hours of delivery '
              'with photos of the item and packaging. We will arrange a replacement or full refund at no cost.',
            ),
          ],
        );

      case InfoPageType.terms:
        return _PageConfig(
          title: 'Terms & Conditions',
          accent: AppColors.secondary,
          buildContent: (_) => [
            const _LastUpdated('January 1, 2025'),
            const _SectionHeading('1. Acceptance of Terms'),
            const _BodyText(
              'By accessing and using the K-LUXE application, you accept and agree to be bound by '
              'these Terms and Conditions. If you do not agree, please discontinue use of the app.',
            ),
            const SizedBox(height: 20),
            const _SectionHeading('2. Products & Availability'),
            const _BodyText(
              'All products listed are subject to availability. Prices are shown in USD and may change '
              'without notice. K-LUXE reserves the right to limit quantities or refuse service.',
            ),
            const SizedBox(height: 20),
            const _SectionHeading('3. Orders & Payment'),
            const _BodyText(
              'By placing an order, you represent that you are of legal age to form a binding contract. '
              'All payments are processed securely. K-LUXE accepts Mastercard, Visa, and Discover only.',
            ),
            const SizedBox(height: 20),
            const _SectionHeading('4. Chart Counting'),
            const _BodyText(
              'Album purchases made through K-LUXE are eligible for Hanteo and Billboard chart counting '
              'per the rules set by each respective chart organization. K-LUXE is not responsible for '
              'chart rule changes made by third parties.',
            ),
            const SizedBox(height: 20),
            const _SectionHeading('5. Intellectual Property'),
            const _BodyText(
              'All content within the K-LUXE app, including logos, images, and text, is the property '
              'of K-LUXE or its content suppliers and is protected by applicable copyright laws.',
            ),
            const SizedBox(height: 20),
            const _SectionHeading('6. Limitation of Liability'),
            const _BodyText(
              'K-LUXE shall not be liable for any indirect, incidental, or consequential damages '
              'arising from the use or inability to use our products or services.',
            ),
            const SizedBox(height: 20),
            const _SectionHeading('7. Changes to Terms'),
            const _BodyText(
              'K-LUXE reserves the right to update these terms at any time. Continued use of the '
              'app after changes constitutes acceptance of the new terms.',
            ),
          ],
        );

      case InfoPageType.privacy:
        return _PageConfig(
          title: 'Privacy Policy',
          accent: AppColors.secondary,
          buildContent: (_) => [
            const _LastUpdated('January 1, 2025'),
            const _BodyText(
              'K-LUXE is committed to protecting your privacy. This policy explains how we collect, '
              'use, and safeguard your personal information.',
            ),
            const SizedBox(height: 20),
            const _SectionHeading('Information We Collect'),
            const _BulletList(items: [
              'Name, email address, and password (account creation)',
              'Shipping address and billing information (orders)',
              'Purchase history and wishlist items',
              'Device information and app usage data (analytics)',
            ]),
            const SizedBox(height: 20),
            const _SectionHeading('How We Use Your Information'),
            const _BulletList(items: [
              'Processing and fulfilling your orders',
              'Sending order confirmations and shipping updates',
              'Personalizing your in-app experience',
              'Improving our products and services',
              'Complying with legal obligations',
            ]),
            const SizedBox(height: 20),
            const _SectionHeading('Data Sharing'),
            const _BodyText(
              'We do not sell your personal data to third parties. We may share data with '
              'trusted service providers (payment processors, shipping carriers) solely to '
              'fulfill your orders. Hanteo and Billboard chart data is reported in aggregate '
              'form only — no personal information is shared.',
            ),
            const SizedBox(height: 20),
            const _SectionHeading('Data Security'),
            const _BodyText(
              'We use industry-standard encryption and security measures to protect your data. '
              'Payment information is processed by PCI-compliant providers and never stored on our servers.',
            ),
            const SizedBox(height: 20),
            const _SectionHeading('Your Rights'),
            const _BodyText(
              'You may request access to, correction of, or deletion of your personal data at any time '
              'by contacting our support team. Account deletion removes all personal data within 30 days.',
            ),
            const SizedBox(height: 20),
            const _SectionHeading('Contact'),
            const _BodyText('For privacy inquiries: privacy@kluxe.com'),
          ],
        );

      case InfoPageType.submitClaim:
        return _PageConfig(
          title: 'Submit a Claim',
          accent: AppColors.secondary,
          buildContent: (context) => [
            const _BodyText(
              'Use this form for damaged items, incorrect orders, missing photocards, '
              'or any other order issues. Our team responds within 1–2 business days.',
            ),
            const SizedBox(height: 28),
            _ClaimForm(),
          ],
        );
    }
  }
}

// ── App Bar ──────────────────────────────────────────────────────────────────

class _InfoAppBar extends StatelessWidget {
  final String title;
  final Color accent;
  const _InfoAppBar({required this.title, required this.accent});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, size: 20),
        color: AppColors.onBackground,
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.onBackground,
          letterSpacing: 0.3,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(
          height: 1,
          color: const Color(0xFF1C1C1C),
        ),
      ),
    );
  }
}

// ── Content building blocks ──────────────────────────────────────────────────

class _SectionHeading extends StatelessWidget {
  final String text;
  const _SectionHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.onBackground,
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.7,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _LastUpdated extends StatelessWidget {
  final String date;
  const _LastUpdated(this.date);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        'Last updated: $date',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF4A4555),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Container(
                  width: 4, height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _expanded
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : const Color(0xFF1E1E1E),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.q,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onBackground,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    _expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 16,
                    color: _expanded ? AppColors.primary : const Color(0xFF4A4555),
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                const Divider(color: Color(0xFF1E1E1E), height: 1),
                const SizedBox(height: 10),
                Text(
                  widget.a,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.65,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyHighlight extends StatelessWidget {
  final String text;
  final Color color;
  const _PolicyHighlight({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.info, size: 16, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── About page specific ──────────────────────────────────────────────────────

class _CertBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CertChip(
            title: 'HANTEO',
            sub: 'HF0001KPU001',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _CertChip(
            title: 'billboard',
            sub: 'Chart Counted',
            color: AppColors.secondary,
            italic: true,
          ),
        ),
      ],
    );
  }
}

class _CertChip extends StatelessWidget {
  final String title;
  final String sub;
  final Color color;
  final bool italic;
  const _CertChip({
    required this.title,
    required this.sub,
    required this.color,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: italic ? 0.5 : 1.5,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Store Address specific ───────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E1E), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.mapPin, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'K-LUXE Store',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '123 Hallyu Boulevard\nSuite 4B\nLos Angeles, CA 90001\nUnited States',
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoursTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const rows = [
      ('Monday – Saturday', '11:00 AM – 7:00 PM'),
      ('Sunday', '11:00 AM – 6:00 PM'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E1E), width: 0.5),
      ),
      child: Column(
        children: rows.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(row.$1,
                    style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                Text(row.$2,
                    style: const TextStyle(fontSize: 13, color: AppColors.onBackground,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Contact specific ─────────────────────────────────────────────────────────

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ContactTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E1E1E), width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF4A4555),
                        letterSpacing: 1)),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(fontSize: 13,
                        color: AppColors.onBackground, fontWeight: FontWeight.w500,
                        height: 1.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Claim Form ───────────────────────────────────────────────────────────────

class _ClaimForm extends StatefulWidget {
  @override
  State<_ClaimForm> createState() => _ClaimFormState();
}

class _ClaimFormState extends State<_ClaimForm> {
  final _orderCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _claimType = 'Damaged Item';
  bool _submitted = false;

  final _types = [
    'Damaged Item',
    'Incorrect Item',
    'Missing Photocard',
    'Missing Item',
    'Other',
  ];

  @override
  void dispose() {
    _orderCtrl.dispose();
    _emailCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_orderCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Column(
          children: [
            Icon(LucideIcons.checkCircle2, size: 40, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Claim Submitted',
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our team will respond within 1–2 business days.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormLabel('Claim Type'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E1E), width: 0.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _claimType,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              style: const TextStyle(fontSize: 14, color: AppColors.onBackground),
              onChanged: (v) => setState(() => _claimType = v!),
              items: _types.map((t) {
                return DropdownMenuItem(value: t, child: Text(t));
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _FormLabel('Order Number'),
        const SizedBox(height: 8),
        _FormField(controller: _orderCtrl, hint: 'e.g. KLX-00123'),
        const SizedBox(height: 16),
        _FormLabel('Email Address'),
        const SizedBox(height: 8),
        _FormField(
          controller: _emailCtrl,
          hint: 'your@email.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _FormLabel('Description'),
        const SizedBox(height: 8),
        _FormField(
          controller: _descCtrl,
          hint: 'Describe the issue in detail...',
          maxLines: 4,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Submit Claim',
              style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;

  const _FormField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: AppColors.onBackground),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF4A4555)),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E1E1E), width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E1E1E), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 1),
        ),
      ),
    );
  }
}

// ── Internal config helper ───────────────────────────────────────────────────

class _PageConfig {
  final String title;
  final Color accent;
  final List<Widget> Function(BuildContext) buildContent;

  const _PageConfig({
    required this.title,
    required this.accent,
    required this.buildContent,
  });
}