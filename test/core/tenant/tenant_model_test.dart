import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/tenant/tenant_model.dart';

void main() {
  group('HexColor Extension Tests', () {
    test('parses standard 6-digit hex code with hash', () {
      final color = HexColor.fromHex('#E5A93C');
      expect(color, const Color(0xFFE5A93C));
    });

    test('parses 6-digit hex code without hash', () {
      final color = HexColor.fromHex('FF007F');
      expect(color, const Color(0xFFFF007F));
    });

    test('parses 8-digit hex code with alpha', () {
      final color = HexColor.fromHex('#80FF007F');
      expect(color, const Color(0x80FF007F));
    });

    test('parses 3-digit shorthand hex code', () {
      final color = HexColor.fromHex('#FFF');
      expect(color, const Color(0xFFFFFFFF));
    });

    test('returns default color on invalid hex input', () {
      final color = HexColor.fromHex('invalid', defaultColor: Colors.red);
      expect(color, Colors.red);
    });
  });

  group('TenantConfig JSON Serialization Tests', () {
    test('correctly deserializes full TenantConfig JSON', () {
      final json = {
        'id': 'monsta-x-store',
        'slug': 'monsta-x',
        'name': 'MONSTA X Official',
        'hasShopifyConfigured': true,
        'themePreset': 'playful_neon',
        'branding': {
          'appTitle': 'MONSTA X',
          'tagline': 'World Tour Official Merch',
          'logoUrl': 'https://example.com/logo.png',
          'bannerUrl': 'https://example.com/banner.jpg',
          'primaryColor': '#FF007F',
          'secondaryColor': '#00F5D4',
          'backgroundColor': '#0D0221',
          'surfaceColor': '#1A0933',
          'textColor': '#FFFFFF',
          'fontFamily': 'Montserrat',
          'borderRadius': 20.0,
        },
        'features': {
          'enableApplePay': true,
          'enableGooglePay': true,
          'enableReviews': false,
          'enableWishlist': true,
          'enableLoyaltyRewards': true,
          'enableOrderTracking': true,
        },
      };

      final config = TenantConfig.fromJson(json);

      expect(config.id, 'monsta-x-store');
      expect(config.slug, 'monsta-x');
      expect(config.name, 'MONSTA X Official');
      expect(config.hasShopifyConfigured, true);
      expect(config.themePreset, 'playful_neon');

      expect(config.branding.appTitle, 'MONSTA X');
      expect(config.branding.primaryColor, const Color(0xFFFF007F));
      expect(config.branding.secondaryColor, const Color(0xFF00F5D4));
      expect(config.branding.backgroundColor, const Color(0xFF0D0221));
      expect(config.branding.surfaceColor, const Color(0xFF1A0933));
      expect(config.branding.fontFamily, 'Montserrat');
      expect(config.branding.borderRadius, 20.0);

      expect(config.features.enableApplePay, true);
      expect(config.features.enableReviews, false);
    });

    test('falls back to default tenant config on empty or null values', () {
      final config = TenantConfig.fromJson({});
      expect(config.id, 'k-luxe');
      expect(config.branding.appTitle, 'K-LUXE');
      expect(config.branding.fontFamily, 'Cinzel');
    });
  });
}
