class ProfileService {
  Future<void> updateUsername(String username) async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  Future<void> withdraw(double amount) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> deleteDevice(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<Map<String, dynamic>> loadProfile() async {
    await Future.delayed(const Duration(seconds: 2));

    return {
      "username": "User Name",
      "credits": 180.50,
      "devices": [
        {"id": "device_01", "samples": 120},
        {"id": "device_02", "samples": 340},
        {"id": "device_03", "samples": 89},
      ],
      "transactions": [
        {
          "title": "Request Contribution",
          "amount": 50,
          "date": "Today, 14:22",
        },
        {
          "title": "Withdrawal",
          "amount": -20,
          "date": "Today, 11:08",
        },
      ],
    };
  }

  Future<Map<String, dynamic>> createAccount({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 5));

    // simulate username conflict
    if (username.toLowerCase() == "admin") {
      return {
        "success": false,
        "message": "Username already exists",
      };
    }

    return {
      "success": true,
      "message": null,
      "data": {
        "username": username,
        "credits": 0.0,
        "devices": [],
        "transactions": [],
      }
    };
  }
}
