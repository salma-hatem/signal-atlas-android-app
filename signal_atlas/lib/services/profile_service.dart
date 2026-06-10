import '../models/transaction_model.dart';
import 'api_service.dart';
import 'supabase_auth_service.dart';

class ProfileService {
  final SupabaseAuthService _supabaseAuth;

  ProfileService(this._supabaseAuth);

  // -------------------------------------------------------
  // Auth
  // -------------------------------------------------------

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _supabaseAuth.signUp(email: email, password: password);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _supabaseAuth.signIn(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabaseAuth.signOut();
  }

  String? get currentUserId => _supabaseAuth.currentUser?.id;

  bool get isSignedIn => _supabaseAuth.currentSession != null;

  // -------------------------------------------------------
  // Profile
  // -------------------------------------------------------

  Future<Map<String, dynamic>> fetchProfile(String userId) async {
    return await _supabaseAuth.fetchProfile(userId);
  }

  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    await _supabaseAuth.updateProfile(userId: userId, updates: updates);
  }

  // -------------------------------------------------------
  // Devices
  // -------------------------------------------------------

  Future<List<Map<String, dynamic>>> fetchDevices(String userId) async {
    return await _supabaseAuth.fetchDevices(userId);
  }

  Future<void> registerDevice({
    required String userId,
    required String deviceId,
  }) async {
    await _supabaseAuth.registerDevice(userId: userId, deviceId: deviceId);
  }

  // -------------------------------------------------------
  // Wallet
  // -------------------------------------------------------

  Future<List<TransactionModel>> fetchTransactions(String userId) async {
    return await _supabaseAuth.fetchTransactions(userId);
  }

  Future<void> withdraw(double amount) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // -------------------------------------------------------
  // Backend API calls (still use ApiService)
  // -------------------------------------------------------

  Future<Map<String, dynamic>> getAccountByDevice(String deviceId) async {
    return await ApiService.post(
      "/api/account/by-device",
      body: {"device_id": deviceId},
    );
  }

  Future<int> getDeviceSamples(String deviceId) async {
    final res = await ApiService.get(
      "/api/mobile/users_samples",
      query: {"device_id": deviceId},
    );

    return (res["total_samples_count"] ?? 0) as int;
  }

  Future<void> deleteDeviceSamples(String deviceId) async {
    await ApiService.delete(
      "/api/mobile/users_samples",
      query: {"device_id": deviceId},
    );
  }
}
