import '../models/coverage_request.dart';
import '../models/coverage_request_detailed.dart';
import '../utilities/get_device_id.dart';
import 'api_service.dart';
import 'device_service.dart';

class CoverageRequestsService {

  // ------------------------------------------------
  // GET ALL REQUESTS
  // ------------------------------------------------

  Future<List<CoverageRequest>> fetchRequests() async {

    try {
      final response = await ApiService.get(
        "/coverage-requests",
      );

      final requests = response["requests"] as List<dynamic>;

      return requests
          .map((json) => CoverageRequest.fromJson(json))
          .toList();

    } catch (e, stack) {
      print("FETCH REQUESTS ERROR: $e");
      print(stack);
      rethrow;
    }
  }
  // ------------------------------------------------
  // GET SINGLE REQUEST
  // ------------------------------------------------

  Future<CoverageRequestDetail> fetchRequestDetails(
      int id,
      ) async {
    final response = await ApiService.get(
      "/coverage-requests/$id",
    );

    return CoverageRequestDetail.fromJson(
      response,
    );
  }


  // ------------------------------------------------
  // GET NEARBY REQUESTS
  // ------------------------------------------------

  Future<List<CoverageRequest>> fetchNearbyRequests({
    required double latitude,
    required double longitude,

    double radiusKm = 5,

    String? country,
    String? city,
  }) async {

    try {
      final response = await ApiService.get(
        "/coverage-requests/nearby",

        query: {
          "latitude": latitude,
          "longitude": longitude,
          "radius_km": radiusKm,

          if (country != null) "country": country,
          if (city != null) "city": city,
        },
      );

      final requests = response["requests"] as List<dynamic>;

      return requests
          .map((json) => CoverageRequest.fromJson(json))
          .toList();

    } catch (e, stack) {
      print("FETCH NEARBY REQUESTS ERROR: $e");
      print(stack);
      rethrow;
    }
  }

  // ------------------------------------------------
  // GET MY CONTRIBUTION
  // ------------------------------------------------

  Future<double> fetchUserContribution(
      int requestId,
      ) async {

    String deviceId;

    if (DeviceService.deviceId.value != null) {
      deviceId = DeviceService.deviceId.value!;
    } else {
      deviceId = await waitForDeviceId();
    }

    final response = await ApiService.get(
      "/coverage-requests/$requestId/my-contribution",

      query: {
        "device_id": deviceId,
      },
        auth: true,
    );

    final raw = response["density_contribution"];

    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0;

    return 0;
  }
}
