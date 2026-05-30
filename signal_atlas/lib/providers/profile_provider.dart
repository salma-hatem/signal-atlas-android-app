import 'package:flutter/material.dart';

import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service;

  ProfileProvider(this._service);

  // ----------------------------
  // Data
  // ----------------------------
  String? _username;
  double? _credits;

  List<Map<String, dynamic>>? _devices;
  List<Map<String, dynamic>>? _transactions;


  // ----------------------------
  // Getters
  // ----------------------------

  String? get username => _username;
  double? get credits => _credits;

  List<Map<String, dynamic>>? get devices => _devices;
  List<Map<String, dynamic>>? get transactions => _transactions;

  // ----------------------------
  // Load Profile
  // ----------------------------
  Future<void> loadProfile() async {
    final data = await _service.loadProfile();

    _username = data["username"];
    _credits = data["credits"];
    _devices = data["devices"];
    _transactions = data["transactions"];

    notifyListeners();
  }

  // ----------------------------
  // Update Username
  // ----------------------------
  Future<void> updateUsername(String value) async {
    await _service.updateUsername(value);

    _username = value;
    notifyListeners();
  }

  // ----------------------------
  // Withdraw
  // ----------------------------
  Future<void> withdraw(double amount) async {
    await _service.withdraw(amount);

    _credits = (_credits ?? 0) - amount;

    _transactions ??= [];

    _transactions!.insert(0, {
      "title": "Withdrawal",
      "amount": -amount,
      "date": "Just now",
    });

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
