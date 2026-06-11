import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String? username;

  AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    this.username,
  });
}

class SupabaseAuthService {
  // -------------------------------------------------------
  // Auth — now uses backend API instead of Supabase directly
  // -------------------------------------------------------

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String username,
    String? deviceId,
  }) async {
    final data = await ApiService.post(
      '/api/auth/register',
      body: {
        'email': email,
        'password': password,
        'username': username,
        if (deviceId != null) 'device_id': deviceId,
      },
      auth: false,
    );

    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;
    final userId = data['user']['id'] as String;

    await ApiService.storeTokens(accessToken, refreshToken);

    return AuthResult(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      username: data['user']?['username'] as String?,
    );
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
    String? deviceId,
  }) async {
    final data = await ApiService.post(
      '/api/auth/login',
      body: {
        'email': email,
        'password': password,
        if (deviceId != null) 'device_id': deviceId,
      },
      auth: false,
    );

    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;
    final userId = data['user']['id'] as String;

    await ApiService.storeTokens(accessToken, refreshToken);

    return AuthResult(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      username: data['user']?['username'] as String?,
    );
  }

  Future<void> signOut() async {
    try {
      await ApiService.post('/api/auth/logout', auth: true);
    } catch (_) {
      // Ignore errors on logout
    }
    await ApiService.clearTokens();
  }

  Future<String?> get currentUserId async {
    final authenticated = await ApiService.isAuthenticated();
    if (!authenticated) return null;

    try {
      final data = await ApiService.get('/api/users/me', auth: true);
      return data['id'] as String?;
    } catch (e) {
      debugPrint('currentUserId error: $e');
      return null;
    }
  }

  Future<bool> get isSignedIn async {
    return await ApiService.isAuthenticated();
  }

  // -------------------------------------------------------
  // Profile
  // -------------------------------------------------------

  Future<Map<String, dynamic>> fetchProfile(String userId) async {
    final data = await ApiService.get('/api/profile/$userId', auth: true);
    return data as Map<String, dynamic>;
  }

  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    await ApiService.patch('/api/profile/$userId', body: updates, auth: true);
  }

  // -------------------------------------------------------
  // Devices
  // -------------------------------------------------------

  Future<List<Map<String, dynamic>>> fetchDevices(String userId) async {
    final data = await ApiService.get('/api/users/me/devices', auth: true);
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> registerDevice({
    required String userId,
    required String deviceId,
  }) async {
    await ApiService.post(
      '/api/users/me/devices',
      body: {'device_id': deviceId},
      auth: true,
    );
  }

  Future<void> unregisterDevice(int deviceId) async {
    await ApiService.delete('/api/users/me/devices/$deviceId', auth: true);
  }

  // -------------------------------------------------------
  // Device check (for Android device-first flow)
  // -------------------------------------------------------

  Future<Map<String, dynamic>> checkDevice(String deviceId) async {
    final data = await ApiService.post(
      '/api/account/by-device',
      body: {'device_id': deviceId},
      auth: false,
    );
    return data as Map<String, dynamic>;
  }

  // -------------------------------------------------------
  // Wallet / Transactions
  // -------------------------------------------------------

  Future<List<Map<String, dynamic>>> fetchTransactions(String userId) async {
    final data = await ApiService.get(
      '/api/wallet/$userId/transactions?limit=50',
      auth: true,
    );
    final transactions = data['transactions'];
    if (transactions is List) {
      return transactions.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
