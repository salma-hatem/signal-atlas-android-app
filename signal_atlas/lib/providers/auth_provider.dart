import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

  User? get user => _user;
  Map<String, dynamic>? get profile => _profile;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _user = SupabaseService.currentUser;
    _loading = false;
    if (_user != null) {
      _fetchProfile();
    }
    SupabaseService.authStateChanges.listen((AuthState authState) {
      _user = authState.session?.user;
      if (_user != null) {
        _fetchProfile();
      } else {
        _profile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchProfile() async {
    try {
      _profile = await SupabaseService.getProfile();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      _profile = null;
    }
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      await SupabaseService.signUp(email, password);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      await SupabaseService.signIn(email, password);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    _user = null;
    _profile = null;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      await SupabaseService.updateProfile(updates);
      _profile?.addAll(updates);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
