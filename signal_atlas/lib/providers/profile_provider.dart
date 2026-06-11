import 'package:flutter/material.dart';

import '../models/device_model.dart';
import '../services/profile_service.dart';
import '../utilities/get_device_id.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service;

  ProfileProvider(this._service);

  // ----------------------------
  // Data
  // ----------------------------
  bool? _hasAccount;
  bool _isCreatingAccount = false;
  String? _createAccountError;
  String? _deviceId;

  String? _username;
  double? _credits;
  String? _profileId;

  bool _isUpdatingUsername = false;
  bool _isLoadingCredit = true;

  List<DeviceModel>? _devices;
  List<Map<String, dynamic>>? _transactions;

  // ----------------------------
  // Getters
  // ----------------------------

  String? get username => _username;
  double? get credits => _credits;
  String? get profileId => _profileId;
  String? get deviceId => _deviceId;

  bool get isUpdatingUsername => _isUpdatingUsername;
  bool get isLoadingCredit => _isLoadingCredit;

  List<DeviceModel>? get devices => _devices;
  List<Map<String, dynamic>>? get transactions => _transactions;

  bool? get hasAccount => _hasAccount;
  bool get isCreatingAccount => _isCreatingAccount;
  String? get createAccountError => _createAccountError;

  // ----------------------------
  // Initialize - check existing session
  // ----------------------------

  Future<void> initialize() async {
    _deviceId = await waitForDeviceId();

    final signedIn = await _service.isSignedIn;
    final userId = await _service.currentUserId;

    if (signedIn && userId != null) {
      _profileId = userId;
      _hasAccount = true;
      await loadProfile();
    } else {
      _hasAccount = false;
      notifyListeners();
    }
  }

  // ----------------------------
  // Create Account
  // ----------------------------

  Future<void> createAccount({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    if (_deviceId == null) {
      _createAccountError = "Unable to identify device";
      return;
    }

    if (password != confirmPassword) {
      _createAccountError = "Passwords do not match";
      notifyListeners();
      return;
    }

    _isCreatingAccount = true;
    _createAccountError = null;
    notifyListeners();

    try {
      await _service.signUp(
        email: email,
        password: password,
        username: username,
        deviceId: _deviceId,
      );

      final userId = await _service.currentUserId;
      if (userId == null) {
        _createAccountError = "Sign up succeeded but no user ID returned";
        return;
      }

      _profileId = userId;
      _hasAccount = true;

      await loadProfile();
    } catch (e) {
      _createAccountError = e.toString();
    } finally {
      _isCreatingAccount = false;
      notifyListeners();
    }
  }

  void clearCreateAccountError() {
    if (_createAccountError == null) return;
    _createAccountError = null;
    notifyListeners();
  }

  // ----------------------------
  // Sign In / Attach Device
  // ----------------------------
  Future<void> attachDeviceToAccount({
    required String email,
    required String password,
  }) async {
    if (_deviceId == null) {
      _createAccountError = "Unable to identify device";
      notifyListeners();
      return;
    }

    _isCreatingAccount = true;
    _createAccountError = null;
    notifyListeners();

    try {
      await _service.signIn(
        email: email,
        password: password,
        deviceId: _deviceId,
      );

      final userId = await _service.currentUserId;
      if (userId == null) {
        _createAccountError = "Sign in succeeded but no user ID returned";
        return;
      }

      _profileId = userId;
      _hasAccount = true;

      await loadProfile();
    } catch (e) {
      _createAccountError = e.toString();
      notifyListeners();
    } finally {
      _isCreatingAccount = false;
      notifyListeners();
    }
  }

  // ----------------------------
  // Load Profile
  // ----------------------------
  Future<void> loadProfile() async {
    if (_profileId == null) return;

    _isLoadingCredit = true;
    notifyListeners();

    try {
      final profile = await _service.fetchProfile(_profileId!);

      _username = profile["username"] as String?;
      _credits = double.tryParse(profile["credits"]?.toString() ?? "0") ?? 0.0;

      final deviceRows = await _service.fetchDevices(_profileId!);
      _devices = deviceRows
          .map((d) => DeviceModel(id: d["device_id"]?.toString() ?? ""))
          .toList();

      if (_devices != null) {
        for (final d in _devices!) {
          fetchDeviceSamples(d);
        }
      }

      _transactions = await _service.fetchTransactions(_profileId!);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoadingCredit = false;
      notifyListeners();
    }
  }

  // ----------------------------
  // Update Username
  // ----------------------------
  Future<void> updateUsername(String newUsername) async {
    if (_profileId == null) return;

    _isUpdatingUsername = true;
    notifyListeners();

    try {
      await _service.updateProfile(
        userId: _profileId!,
        updates: {"username": newUsername},
      );

      _username = newUsername;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isUpdatingUsername = false;
      notifyListeners();
    }
  }

  // ----------------------------
  // Withdraw
  // ----------------------------
  Future<void> withdraw(double amount) async {
    if ((_credits ?? 0) < amount) return;

    await _service.withdraw(amount);
    _credits = (_credits ?? 0) - amount;

    _credits = null;
    notifyListeners();

    await loadProfile();
  }

  // ----------------------------
  // Get Devices Sample Count
  // ----------------------------
  Future<void> fetchDeviceSamples(DeviceModel device) async {
    final index = _devices!.indexWhere((d) => d.id == device.id);
    if (index == -1) return;

    _devices![index].isLoadingSamples = true;
    notifyListeners();

    try {
      final samples = await _service.getDeviceSamples(device.id);
      _devices![index].samples = samples;
    } catch (e) {
      debugPrint("ERROR fetching samples: $e");
    } finally {
      _devices![index].isLoadingSamples = false;
      notifyListeners();
    }
  }

  // ----------------------------
  // Delete Device
  // ----------------------------
  Future<void> deleteDevice(DeviceModel device) async {
    final index = _devices!.indexWhere((d) => d.id == device.id);
    if (index == -1) return;

    _devices![index].isDeleting = true;
    notifyListeners();

    try {
      await _service.deleteDeviceSamples(device.id);
    } catch (e) {
      debugPrint("ERROR deleting device: $e");
      _devices![index].isDeleting = false;
    }

    notifyListeners();
  }
}
