import 'package:flutter/material.dart';

import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service;

  ProfileProvider(this._service);

  // ----------------------------
  // Data
  // ----------------------------
  bool? _hasAccount;
  bool _isCreatingAccount = false;
  String? _createAccountError;

  String? _username;
  double? _credits;

  bool _isUpdatingUsername = false;
  bool _isLoadingCredit = true;

  List<Map<String, dynamic>>? _devices;
  List<Map<String, dynamic>>? _transactions;


  // ----------------------------
  // Getters
  // ----------------------------

  String? get username => _username;
  double? get credits => _credits;

  bool get isUpdatingUsername => _isUpdatingUsername;
  bool get isLoadingCredit => _isLoadingCredit;

  List<Map<String, dynamic>>? get devices => _devices;
  List<Map<String, dynamic>>? get transactions => _transactions;

  bool? get hasAccount => _hasAccount;
  bool get isCreatingAccount => _isCreatingAccount;
  String? get createAccountError => _createAccountError;

  // ----------------------------
  // Create Account if it doesnt exist
  // ----------------------------
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));

    // simulate lookup by device id
    _hasAccount = false;

    if (_hasAccount!) {
      await loadProfile();
    }

    notifyListeners();
  }

  Future<void> createAccount({
    required String username,
    required String password,
  }) async {
    _isCreatingAccount = true;
    _createAccountError = null;

    notifyListeners();

    try {
      final result = await _service.createAccount(
        username: username,
        password: password,
      );

      final success = result["success"] as bool;

      if (!success) {
        _createAccountError = result["message"] as String?;
        return;
      }

      final data = result["data"] as Map<String, dynamic>;

      _username = data["username"];
      _credits = (data["credits"] as num).toDouble();
      _devices = List<Map<String, dynamic>>.from(data["devices"]);
      _transactions = List<Map<String, dynamic>>.from(data["transactions"]);

      _hasAccount = true;
    } finally {
      _isCreatingAccount = false;
      await loadProfile();
      notifyListeners();
    }
  }

  void clearCreateAccountError() {
    if (_createAccountError == null) return;

    _createAccountError = null;
    notifyListeners();
  }

  // ----------------------------
  // Load Profile
  // ----------------------------
  Future<void> loadProfile() async {
    _isLoadingCredit = true;
    final data = await _service.loadProfile();

    _username = data["username"];
    _credits = data["credits"];
    _devices = data["devices"];
    _transactions = data["transactions"];

    _isLoadingCredit = false;
    notifyListeners();
  }

  // ----------------------------
  // Update Username
  // ----------------------------
  Future<void> updateUsername(String newUsername) async {
    _isUpdatingUsername = true;
    notifyListeners();

    try {
      await _service.updateUsername(newUsername);

      _username = newUsername;
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
    _transactions!.insert(0, <String, Object>{
      "title": "Withdrawal",
      "amount": -amount,
      "date": "Just now",
    });

    _credits = null;
    notifyListeners();

    await loadProfile();

    notifyListeners();
  }

  // ----------------------------
  // Delete Device
  // ----------------------------
  Future<void> deleteDevice(String id) async {
    await _service.deleteDevice(id);

    _devices?.removeWhere(
          (device) => device["id"] == id,
    );

    notifyListeners();
  }
}
