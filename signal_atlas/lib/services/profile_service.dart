import 'api_service.dart';
import 'supabase_auth_service.dart';

class ProfileService {
  final SupabaseAuthService _supabaseAuth;

  ProfileService(this._supabaseAuth);

  // -------------------------------------------------------
  // Auth
  // -------------------------------------------------------

  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
    String? deviceId,
  }) async {
    final result = await _supabaseAuth.signUp(
      email: email,
      password: password,
      username: username,
      deviceId: deviceId,
    );
    return result.userId;
  }

  Future<String?> signIn({
    required String email,
    required String password,
    String? deviceId,
  }) async {
    final result = await _supabaseAuth.signIn(
      email: email,
      password: password,
      deviceId: deviceId,
    );
    return result.userId;
  }

  Future<void> signOut() async {
    await _supabaseAuth.signOut();
  }

  Future<String?> get currentUserId async {
    return await _supabaseAuth.currentUserId;
  }

  Future<bool> get isSignedIn async {
    return await _supabaseAuth.isSignedIn;
  }

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

  Future<List<Map<String, dynamic>>> fetchTransactions(String userId) async {
    return await _supabaseAuth.fetchTransactions(userId);
  }

  Future<void> withdraw(double amount) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // -------------------------------------------------------
  // Device check (Android device-first flow)
  // -------------------------------------------------------

  Future<Map<String, dynamic>> getAccountByDevice(String deviceId) async {
    return await _supabaseAuth.checkDevice(deviceId);
  }

  // -------------------------------------------------------
  // Samples (backend API)
  // -------------------------------------------------------

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
