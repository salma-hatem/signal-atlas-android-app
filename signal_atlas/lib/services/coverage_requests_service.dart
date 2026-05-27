import '../models/coverage_request.dart';
import '../models/coverage_request_detailed.dart';
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

    final deviceId = DeviceService.deviceId.value;

    if (deviceId == null) {
      return 0;
    }

    final response = await ApiService.get(
      "/coverage-requests/$requestId/my-contribution",

      query: {
        "device_id": deviceId,
      },
    );

    return (
        response["density_contribution"] ?? 0
    ).toDouble();
  }
}
