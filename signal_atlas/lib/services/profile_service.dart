import '../models/transaction_model.dart';
import 'api_service.dart';

class ProfileService {
  Future<void> withdraw(double amount) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<Map<String, dynamic>> loadProfile(
      String profileId,
      ) async {
    return await ApiService.get(
      "/api/profile/$profileId",
    );
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final res = await ApiService.post(
        "/api/auth/login",
        body: {
          "username": username,
          "password": password,
        },
      );

      return {
        "success": true,
        "profile": res["profile"],
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> createAccount({
    required String username,
    required String password,
    required String deviceId,
  }) async {
    try {
      final data = await ApiService.post(
        "/api/account/create",
        body: {
          "username": username,
          "password": password,
          "device_id": deviceId,
        },
      );

      return {
        "success": true,
        "message": null,
        "data": data,
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getAccountByDevice(
      String deviceId,
      ) async {
    return await ApiService.post(
      "/api/account/by-device",
      body: {
        "device_id": deviceId,
      },
    );
  }

  Future<Map<String, dynamic>> attachDeviceToAccount({
    required String userId,
    required String deviceId,
  }) async {
    try {
      final data = await ApiService.post(
        "/api/devices/register",
        body: {
          "user_id": userId,
          "device_id": deviceId,
        },
      );

      return {
        "success": true,
        "data": data,
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateUsername({
    required String profileId,
    required String username,
  }) async {
    return await ApiService.patch(
      "/api/profile/$profileId",
      body: {
        "username": username,
      },
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

  // --------------------------------------------------------
  // WALLET
  // --------------------------------------------------------

  Future<Map<String, dynamic>> getWallet(
      String profileId,
      ) async {
    return await ApiService.get(
      "/api/wallet/$profileId",
    );
  }

  Future<List<TransactionModel>> getTransactions(
      String profileId,
      ) async {
    final data = await ApiService.get(
      "/api/wallet/$profileId/transactions",
    );

    return (data["transactions"] as List)
        .map(
          (t) => TransactionModel.fromJson(
        t as Map<String, dynamic>,
      ),
    )
        .toList();
  }

}
