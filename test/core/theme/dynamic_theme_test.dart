import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/tenant/tenant_model.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  group('Dynamic AppTheme Tests', () {
    testWidgets('builds dark theme properly for dark background preset', (WidgetTester tester) async {
      const darkConfig = TenantConfig(
        id: 'dark-tenant',
        slug: 'dark-tenant',
        name: 'Dark Tenant',
        themePreset: 'bold_dark',
        branding: BrandingConfig(
          appTitle: 'DARK MERCH',
          primaryColorHex: '#E5A93C',
          secondaryColorHex: '#9D4EDD',
          backgroundColorHex: '#0A0A0C',
          surfaceColorHex: '#16161A',
          textColorHex: '#F4F4F6',
          fontFamily: 'Cinzel',
          borderRadius: 16.0,
        ),
        features: TenantFeatures(),
      );

      final themeData = AppTheme.buildDynamicTheme(darkConfig);

      expect(themeData.brightness, Brightness.dark);
      expect(themeData.colorScheme.primary, const Color(0xFFE5A93C));
      expect(themeData.colorScheme.secondary, const Color(0xFF9D4EDD));
      expect(themeData.scaffoldBackgroundColor, const Color(0xFF0A0A0C));
      expect(themeData.colorScheme.surface, const Color(0xFF16161A));
      expect(themeData.cardTheme.color, const Color(0xFF16161A));
    });

    testWidgets('builds light theme properly for light background preset', (WidgetTester tester) async {
      const lightConfig = TenantConfig(
        id: 'light-tenant',
        slug: 'light-tenant',
        name: 'Light Tenant',
        themePreset: 'minimal_light',
        branding: BrandingConfig(
          appTitle: 'MINIMAL STORE',
          primaryColorHex: '#111111',
          secondaryColorHex: '#666666',
          backgroundColorHex: '#FAFAFA',
          surfaceColorHex: '#FFFFFF',
          textColorHex: '#111111',
          fontFamily: 'Inter',
          borderRadius: 8.0,
        ),
        features: TenantFeatures(),
      );

      final themeData = AppTheme.buildDynamicTheme(lightConfig);

      expect(themeData.brightness, Brightness.light);
      expect(themeData.colorScheme.primary, const Color(0xFF111111));
      expect(themeData.scaffoldBackgroundColor, const Color(0xFFFAFAFA));
      expect(themeData.colorScheme.surface, const Color(0xFFFFFFFF));
    });
  });
}
