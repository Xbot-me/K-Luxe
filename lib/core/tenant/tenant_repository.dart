import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import 'tenant_model.dart';

class TenantRepository {
  static const String _cacheKey = 'cached_tenant_config_v1';
  static TenantConfig? _memoryCache;

  /// Returns the current active tenant ID configured via .env or null
  static String? get configuredTenantId => dotenv.env['TENANT_ID'];

  /// Returns the cached tenant config from memory or local disk, or default
  static Future<TenantConfig> getCachedTenantConfig() async {
    if (_memoryCache != null) return _memoryCache!;

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null) {
        final map = jsonDecode(cachedJson) as Map<String, dynamic>;
        _memoryCache = TenantConfig.fromJson(map);
        return _memoryCache!;
      }
    } catch (e) {
      debugPrint('[TenantRepository] Error loading cached tenant: $e');
    }

    _memoryCache = TenantConfig.defaultTenant;
    return _memoryCache!;
  }

  /// Fetches the latest tenant configuration from the BFF
  static Future<TenantConfig> fetchTenantConfig({String? tenantId}) async {
    final targetTenant = tenantId ?? configuredTenantId;

    try {
      final headers = <String, String>{};
      if (targetTenant != null && targetTenant.isNotEmpty) {
        headers['X-Tenant-Id'] = targetTenant;
      }

      final res = await ApiClient.get(
        ApiEndpoints.tenantConfig,
        requiresAuth: false,
        extraHeaders: headers.isNotEmpty ? headers : null,
      );

      if (res['success'] == true && res['tenant'] != null) {
        final tenantMap = res['tenant'] as Map<String, dynamic>;
        final config = TenantConfig.fromJson(tenantMap);

        // Update memory and disk cache
        _memoryCache = config;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cacheKey, jsonEncode(config.toJson()));
        } catch (_) {}

        return config;
      }
    } catch (e) {
      debugPrint('[TenantRepository] Failed to fetch remote tenant config: $e');
    }

    return getCachedTenantConfig();
  }
}
