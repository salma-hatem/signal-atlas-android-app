
import 'package:flutter/material.dart';

import '../models/device_model.dart';
import '../models/transaction_model.dart';
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
  List<TransactionModel>? _transactions;


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
  List<TransactionModel>? get transactions => _transactions;

  bool? get hasAccount => _hasAccount;
  bool get isCreatingAccount => _isCreatingAccount;
  String? get createAccountError => _createAccountError;

  // ----------------------------
  // Create Account if it doesnt exist
  // ----------------------------

  Future<void> initialize() async {
    _deviceId = await waitForDeviceId();

    if (_deviceId == null) {
      _hasAccount = false;
      notifyListeners();
      return;
    }

    try {
      final result = await _service.getAccountByDevice(_deviceId!);

      _hasAccount = result["account_exists"];

      if (_hasAccount == true) {
        final profile = result["profile"];

        _profileId = profile["id"];

        await loadProfile();
      }
    } catch (_) {
      _hasAccount = false;
    } finally {
      notifyListeners();
    }
  }

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
      // TODO: here pass email and password for authentication
      // TODO: then use username to create new profile
      final result = await _service.createAccount(
        username: username,
        password: password,
        deviceId: _deviceId ?? "",
      );

      final success = result["success"] as bool;

      if (!success) {
        _createAccountError = result["message"] as String?;
        return;
      }

      final data = result["data"] as Map<String, dynamic>;

      _profileId = data["id"];
      _hasAccount = true;

      await loadProfile();
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
  // Register the Device to existing Account
  // ----------------------------
  Future<void> attachDeviceToAccount({
    required String email,
    required String password,
  }) async {
    // TODO: use email and password for authentication then call api to attach the device to the account
    if (_deviceId == null) {
      _createAccountError = "Unable to identify device";
      notifyListeners();
      return;
    }

    _isCreatingAccount = true;
    _createAccountError = null;
    notifyListeners();

    try {
      // Login
      final result = await _service.login(
        username: email,
        password: password,
      );

      if (result["success"] != true) {
        _createAccountError = result["message"] ?? "Login failed";
        notifyListeners();
        return;
      }

      final profile = result["profile"] as Map<String, dynamic>;

      final userId = profile["id"] as String;

      // Attach Device
      final attachRes = await _service.attachDeviceToAccount(
        userId: userId,
        deviceId: _deviceId!,
      );

      if (attachRes["success"] != true) {
        throw Exception(attachRes["message"] ?? "Failed to attach device");
      }

      _profileId = userId;
      _hasAccount = true;

      // Update State
      _username = profile["username"];
      _credits = double.parse(profile["credits"].toString());

      _devices = (profile["device_ids"] as List<dynamic>? ?? [])
          .map((id) => DeviceModel(id: id as String))
          .toList();

      _transactions = (profile["transactions"] as List)
          .map((t) => TransactionModel.fromJson(t))
          .toList();

      notifyListeners();
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
      final profile = await _service.loadProfile(_profileId!);

      _username = profile["username"];
      _credits = double.parse(profile["credits"].toString());

      _devices = (profile["device_ids"] as List)
          .map((id) => DeviceModel(id: id.toString()))
          .toList();

      if(_devices != null) {
        for (final d in _devices!) {
          fetchDeviceSamples(d);
        }
      }

      _transactions = await _service.getTransactions(_profileId!);
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
      final data = await _service.updateUsername(
        profileId: _profileId!,
        username: newUsername,
      );

      _username = data["username"];
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

    _transactions ??= [];
    _transactions!.insert(
      0,
      TransactionModel(
        title: "Withdrawal",
        amount: -amount,
        date: "Just now",
      ),
    );

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
