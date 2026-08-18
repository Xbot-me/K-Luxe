import 'package:flutter/material.dart';

extension HexColor on Color {
  static Color fromHex(String hexString, {Color defaultColor = const Color(0xFFE5A93C)}) {
    final buffer = StringBuffer();
    var clean = hexString.replaceAll('#', '').trim();
    if (clean.length == 6) {
      buffer.write('ff');
      buffer.write(clean);
    } else if (clean.length == 8) {
      buffer.write(clean);
    } else if (clean.length == 3) {
      buffer.write('ff');
      for (final char in clean.split('')) {
        buffer.write(char);
        buffer.write(char);
      }
    } else {
      return defaultColor;
    }

    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return defaultColor;
    }
  }

  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${(a * 255).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(r * 255).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(g * 255).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(b * 255).toInt().toRadixString(16).padLeft(2, '0')}';
}

class BrandingConfig {
  final String appTitle;
  final String tagline;
  final String logoUrl;
  final String bannerUrl;
  final String primaryColorHex;
  final String secondaryColorHex;
  final String backgroundColorHex;
  final String surfaceColorHex;
  final String textColorHex;
  final String fontFamily;
  final double borderRadius;

  const BrandingConfig({
    required this.appTitle,
    this.tagline = '',
    this.logoUrl = '',
    this.bannerUrl = '',
    required this.primaryColorHex,
    required this.secondaryColorHex,
    required this.backgroundColorHex,
    required this.surfaceColorHex,
    required this.textColorHex,
    this.fontFamily = 'Cinzel',
    this.borderRadius = 16.0,
  });

  Color get primaryColor => HexColor.fromHex(primaryColorHex, defaultColor: const Color(0xFFE5A93C));
  Color get secondaryColor => HexColor.fromHex(secondaryColorHex, defaultColor: const Color(0xFF9D4EDD));
  Color get backgroundColor => HexColor.fromHex(backgroundColorHex, defaultColor: const Color(0xFF0A0A0C));
  Color get surfaceColor => HexColor.fromHex(surfaceColorHex, defaultColor: const Color(0xFF16161A));
  Color get textColor => HexColor.fromHex(textColorHex, defaultColor: const Color(0xFFF4F4F6));

  factory BrandingConfig.fromJson(Map<String, dynamic> json) {
    return BrandingConfig(
      appTitle: json['appTitle'] as String? ?? 'K-LUXE',
      tagline: json['tagline'] as String? ?? '',
      logoUrl: json['logoUrl'] as String? ?? '',
      bannerUrl: json['bannerUrl'] as String? ?? '',
      primaryColorHex: json['primaryColor'] as String? ?? '#E5A93C',
      secondaryColorHex: json['secondaryColor'] as String? ?? '#9D4EDD',
      backgroundColorHex: json['backgroundColor'] as String? ?? '#0A0A0C',
      surfaceColorHex: json['surfaceColor'] as String? ?? '#16161A',
      textColorHex: json['textColor'] as String? ?? '#F4F4F6',
      fontFamily: json['fontFamily'] as String? ?? 'Cinzel',
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 16.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appTitle': appTitle,
      'tagline': tagline,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'primaryColor': primaryColorHex,
      'secondaryColor': secondaryColorHex,
      'backgroundColor': backgroundColorHex,
      'surfaceColor': surfaceColorHex,
      'textColor': textColorHex,
      'fontFamily': fontFamily,
      'borderRadius': borderRadius,
    };
  }

  static const defaultBranding = BrandingConfig(
    appTitle: 'K-LUXE',
    tagline: 'Official K-Pop Merchandise & Collectibles',
    logoUrl: 'https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/08/e7/c8/08e7c854-fdaa-f7c2-7551-a98e226f9809/25UMGIM90866.rgb.jpg/600x600bb.jpg',
    bannerUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=1200&auto=format&fit=crop',
    primaryColorHex: '#D7BAFF',
    secondaryColorHex: '#FFB1C7',
    backgroundColorHex: '#050505',
    surfaceColorHex: '#131313',
    textColorHex: '#E5E2E1',
    fontFamily: 'Cinzel',
    borderRadius: 16.0,
  );
}

class TenantFeatures {
  final bool enableApplePay;
  final bool enableGooglePay;
  final bool enableReviews;
  final bool enableWishlist;
  final bool enableLoyaltyRewards;
  final bool enableOrderTracking;

  const TenantFeatures({
    this.enableApplePay = true,
    this.enableGooglePay = true,
    this.enableReviews = true,
    this.enableWishlist = true,
    this.enableLoyaltyRewards = true,
    this.enableOrderTracking = true,
  });

  factory TenantFeatures.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TenantFeatures();
    return TenantFeatures(
      enableApplePay: json['enableApplePay'] as bool? ?? true,
      enableGooglePay: json['enableGooglePay'] as bool? ?? true,
      enableReviews: json['enableReviews'] as bool? ?? true,
      enableWishlist: json['enableWishlist'] as bool? ?? true,
      enableLoyaltyRewards: json['enableLoyaltyRewards'] as bool? ?? true,
      enableOrderTracking: json['enableOrderTracking'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableApplePay': enableApplePay,
      'enableGooglePay': enableGooglePay,
      'enableReviews': enableReviews,
      'enableWishlist': enableWishlist,
      'enableLoyaltyRewards': enableLoyaltyRewards,
      'enableOrderTracking': enableOrderTracking,
    };
  }
}

class TenantConfig {
  final String id;
  final String slug;
  final String name;
  final bool hasShopifyConfigured;
  final String themePreset;
  final BrandingConfig branding;
  final TenantFeatures features;
  final String? updatedAt;

  const TenantConfig({
    required this.id,
    required this.slug,
    required this.name,
    this.hasShopifyConfigured = false,
    this.themePreset = 'bold_dark',
    required this.branding,
    required this.features,
    this.updatedAt,
  });

  factory TenantConfig.fromJson(Map<String, dynamic> json) {
    return TenantConfig(
      id: json['id'] as String? ?? 'k-luxe',
      slug: json['slug'] as String? ?? 'k-luxe',
      name: json['name'] as String? ?? 'K-LUXE Premium Merch',
      hasShopifyConfigured: json['hasShopifyConfigured'] as bool? ?? false,
      themePreset: json['themePreset'] as String? ?? 'bold_dark',
      branding: json['branding'] != null
          ? BrandingConfig.fromJson(json['branding'] as Map<String, dynamic>)
          : BrandingConfig.defaultBranding,
      features: json['features'] != null
          ? TenantFeatures.fromJson(json['features'] as Map<String, dynamic>)
          : const TenantFeatures(),
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'hasShopifyConfigured': hasShopifyConfigured,
      'themePreset': themePreset,
      'branding': branding.toJson(),
      'features': features.toJson(),
      'updatedAt': updatedAt,
    };
  }

  static const defaultTenant = TenantConfig(
    id: 'k-luxe',
    slug: 'k-luxe',
    name: 'K-LUXE Premium Merch',
    hasShopifyConfigured: false,
    themePreset: 'bold_dark',
    branding: BrandingConfig.defaultBranding,
    features: TenantFeatures(),
  );
}
