import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;

  static Future<AuthResponse> signUp(String email, String password) async {
    return supabase.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return supabase.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  static User? get currentUser => supabase.auth.currentUser;

  static Session? get currentSession => supabase.auth.currentSession;

  static String? get accessToken => supabase.auth.currentSession?.accessToken;

  static Stream<AuthState> get authStateChanges =>
      supabase.auth.onAuthStateChange;

  static Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    return response as Map<String, dynamic>?;
  }

  static Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');
    await supabase.from('profiles').update(updates).eq('id', user.id);
  }
}
