import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../tenant/tenant_model.dart';
import '../tenant/tenant_repository.dart';
import 'app_theme.dart';

class TenantConfigNotifier extends StateNotifier<TenantConfig> {
  TenantConfigNotifier() : super(TenantConfig.defaultTenant) {
    _init();
  }

  Future<void> _init() async {
    // 1. Load from local cache instantly
    final cached = await TenantRepository.getCachedTenantConfig();
    state = cached;

    // 2. Fetch fresh config from BFF asynchronously
    await fetchLatestConfig();
  }

  Future<void> fetchLatestConfig({String? tenantId}) async {
    try {
      final remote = await TenantRepository.fetchTenantConfig(tenantId: tenantId);
      state = remote;
    } catch (_) {}
  }

  void updateConfig(TenantConfig config) {
    state = config;
  }
}

/// Active Tenant Configuration State
final tenantConfigProvider =
    StateNotifierProvider<TenantConfigNotifier, TenantConfig>((ref) {
  return TenantConfigNotifier();
});

/// Live Dynamic ThemeData Provider
final appThemeDataProvider = Provider<ThemeData>((ref) {
  final tenant = ref.watch(tenantConfigProvider);
  return AppTheme.buildDynamicTheme(tenant);
});

/// Direct Branding Token Provider
final tenantBrandingProvider = Provider<BrandingConfig>((ref) {
  final tenant = ref.watch(tenantConfigProvider);
  return tenant.branding;
});

/// Feature Flags Provider
final tenantFeaturesProvider = Provider<TenantFeatures>((ref) {
  final tenant = ref.watch(tenantConfigProvider);
  return tenant.features;
});
