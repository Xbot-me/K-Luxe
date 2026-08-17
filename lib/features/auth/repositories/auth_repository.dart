import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthRepository {
  AuthRepository();

  // Holds the logged-in user in memory for the session
  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // ── Login ──
  // Returns the User on success, throws ApiException on failure
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final data = await ApiClient.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
      requiresAuth: false,
    );

    // Save token from response
    final token = data['token'] as String;
    await TokenStorage.saveToken(token);

    // Parse user from nested "user" key — matches your JSON shape
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    await TokenStorage.saveUserId(user.id);
    _currentUser = user;

    return user;
  }

  // ── Signup ──
  Future<User> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final data = await ApiClient.post(
      ApiEndpoints.signup,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      },
      requiresAuth: false,
    );

    final token = data['token'] as String;
    await TokenStorage.saveToken(token);

    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    await TokenStorage.saveUserId(user.id);
    _currentUser = user;

    return user;
  }

  // ── Logout ──
  Future<void> logout() async {
    try {
      // Best effort — don't block logout if server is down
      await ApiClient.post(ApiEndpoints.logout, body: {});
    } catch (_) {}
    await TokenStorage.clear();
    _currentUser = null;
  }

  // ── Restore session on app start ──
  // Called in SplashScreen to check if user is already logged in
  Future<bool> tryRestoreSession() async {
    final hasToken = await TokenStorage.hasToken();
    if (!hasToken) return false;

    try {
      final data = await ApiClient.get(ApiEndpoints.me);
      _currentUser = User.fromJson(data['user'] as Map<String, dynamic>);
      return true;
    } catch (_) {
      // Token expired or invalid — clear it
      await TokenStorage.clear();
      return false;
    }
  }
}