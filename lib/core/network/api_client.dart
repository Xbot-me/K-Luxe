import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Needed for kDebugMode
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._();

  static const Duration _timeout = Duration(seconds: 15);

  // ── Build headers ──
  static Future<Map<String, String>> _headers({
    bool requiresAuth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      //'ngrok-skip-browser-warning': 'true' //for ngork
    };

    if (requiresAuth) {
      final token = await TokenStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ── The Central Network Logger ──
  // This executes the request, times it, and prints beautifully formatted logs.
  static Future<http.Response> _executeLoggedRequest(
    String method,
    Uri uri,
    Map<String, String> headers, {
    String? body,
  }) async {
    final stopwatch = Stopwatch()..start();

    // 1. Log the Outgoing Request
    if (kDebugMode) {
      debugPrint('┌── 🌐 API REQUEST [${method.toUpperCase()}]');
      debugPrint('│ URL: $uri');
      if (body != null) debugPrint('│ BODY: $body');
      debugPrint('│ WAITING FOR RESPONSE...');
    }

    try {
      late http.Response response;

      // Execute the appropriate HTTP method
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers).timeout(_timeout);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: body).timeout(_timeout);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: body).timeout(_timeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers).timeout(_timeout);
          break;
        default:
          throw UnsupportedError('Unsupported HTTP method: $method');
      }

      stopwatch.stop();

      // 2. Log the Successful Response (even if it's a 400/500, the network call succeeded)
      if (kDebugMode) {
        final timeMs = stopwatch.elapsedMilliseconds;
        final icon = response.statusCode >= 200 && response.statusCode < 300 ? '✅' : '⚠️';
        
        debugPrint('├── $icon API RESPONSE [${response.statusCode}] | ⏱️ ${timeMs}ms');
        // Optional: If response bodies are massive, you can truncate this:
        // final shortBody = response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body;
        debugPrint('│ DATA: ${response.body}');
        debugPrint('└───────────────────────────────────────────────────');
      }

      return response;
    } catch (e) {
      stopwatch.stop();
      
      // 3. Log Network/Timeout Failures
      if (kDebugMode) {
        debugPrint('├── ❌ API ERROR | ⏱️ ${stopwatch.elapsedMilliseconds}ms');
        debugPrint('│ ERROR MESSAGE: $e');
        debugPrint('└───────────────────────────────────────────────────');
      }
      rethrow;
    }
  }

  // ── Parse response ──
  static Map<String, dynamic> _parse(http.Response response) {
    late Map<String, dynamic> body;

    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Invalid response from server.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final serverMessage = body['message'] as String? ?? body['error'] as String?;
    throw ApiException.fromStatus(response.statusCode, serverMessage);
  }

  // ── Wrap every call to catch network errors ──
  static Future<T> _safe<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException.noInternet();
    } on HttpException {
      throw ApiException.noInternet();
    } on FormatException {
      throw const ApiException('Unexpected response format.');
    } on Exception {
      throw ApiException.timeout();
    }
  }

  // ── GET ──
  static Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    return _safe(() async {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await _executeLoggedRequest(
        'GET',
        uri,
        await _headers(requiresAuth: requiresAuth),
      );
      return _parse(response);
    });
  }

  // ── POST ──
  static Future<Map<String, dynamic>> post(
    String url, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    return _safe(() async {
      final response = await _executeLoggedRequest(
        'POST',
        Uri.parse(url),
        await _headers(requiresAuth: requiresAuth),
        body: jsonEncode(body),
      );
      return _parse(response);
    });
  }

  // ── PUT ──
  static Future<Map<String, dynamic>> put(
    String url, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    return _safe(() async {
      final response = await _executeLoggedRequest(
        'PUT',
        Uri.parse(url),
        await _headers(requiresAuth: requiresAuth),
        body: jsonEncode(body),
      );
      return _parse(response);
    });
  }

  // ── DELETE ──
  static Future<Map<String, dynamic>> delete(
    String url, {
    bool requiresAuth = true,
  }) async {
    return _safe(() async {
      final response = await _executeLoggedRequest(
        'DELETE',
        Uri.parse(url),
        await _headers(requiresAuth: requiresAuth),
      );
      return _parse(response);
    });
  }
}