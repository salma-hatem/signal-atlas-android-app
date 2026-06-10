import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/transaction_model.dart';

class SupabaseAuthService {
  SupabaseClient get _client => Supabase.instance.client;

  // -------------------------------------------------------
  // Auth
  // -------------------------------------------------------

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user == null) {
      throw Exception('Sign up failed: no user returned');
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) {
      throw Exception('Sign in failed: no user returned');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;

  StreamSubscription<AuthState> onAuthStateChange(
    void Function(AuthState data) callback,
  ) {
    return _client.auth.onAuthStateChange.listen(callback);
  }

  // -------------------------------------------------------
  // Profile
  // -------------------------------------------------------

  Future<Map<String, dynamic>> fetchProfile(String userId) async {
    final Map<String, dynamic> response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return response;
  }

  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    await _client
        .from('profiles')
        .update(updates)
        .eq('id', userId);
  }

  // -------------------------------------------------------
  // Devices
  // -------------------------------------------------------

  Future<List<Map<String, dynamic>>> fetchDevices(String userId) async {
    final response = await _client
        .from('user_devices')
        .select()
        .eq('user_id', userId);

    return (response as List).map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> registerDevice({
    required String userId,
    required String deviceId,
  }) async {
    await _client.from('user_devices').insert({
      'user_id': userId,
      'device_id': deviceId,
      'created_at': DateTime.now().toIso8601String(),
      'last_seen_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> unregisterDevice(int deviceId) async {
    await _client
        .from('user_devices')
        .delete()
        .eq('id', deviceId);
  }

  // -------------------------------------------------------
  // Wallet / Transactions
  // -------------------------------------------------------

  Future<List<TransactionModel>> fetchTransactions(String userId) async {
    final response = await _client
        .from('wallet_transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(5);

    return (response as List)
        .map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
        .toList();
  }
}
