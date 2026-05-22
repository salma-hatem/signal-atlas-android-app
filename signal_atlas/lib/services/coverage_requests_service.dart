import 'package:latlong2/latlong.dart';

import '../models/coverage_request.dart';
import '../models/coverage_request_detailed.dart';

class CoverageRequestsService {
  Future<List<CoverageRequest>> fetchRequests() async {
    await Future.delayed(const Duration(seconds: 2)); // simulation

    return [
      CoverageRequest(
        id: 0,
        title: "4G Coverage Expansion",
        city: "Tanta",
        country: "Egypt",
        status: "Completed",
        createdAt: DateTime(2026, 5, 12),
        rewardAmount: 120,
      ),

      CoverageRequest(
        id: 1,
        title: "Weak Signal Area",
        city: "Mahalla",
        country: "Egypt",
        status: "Open",
        createdAt: DateTime(2026, 5, 10),
        rewardAmount: 75,
      ),

      CoverageRequest(
        id: 2,
        title: "Fiber Connection Request",
        city: "Mansoura",
        country: "Egypt",
        status: "Cancelled",
        createdAt: DateTime(2026, 5, 8),
        rewardAmount: 0,
      ),
    ];
  }

  Future<CoverageRequestDetail> fetchRequestDetails(
      int id,
      ) async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    print("ID: $id");
    if(id == 0) {
      return CoverageRequestDetail(
        id: id,

        title: "4G Coverage Expansion",

        description:
        "This request aims to improve 4G coverage quality "
            "in dense residential areas with weak signal readings.",

        createdBy: "admin",

        city: "Tanta",
        country: "Egypt",

        initialDensityScore: 20,
        currentDensityScore: 65,
        targetDensityScore: 100,

        rewardAmount: 250,

        status: "Open",

        createdAt: DateTime.now(),

        area: [
          LatLng(30.7905, 31.0004),
          LatLng(30.7920, 31.0040),
          LatLng(30.7880, 31.0060),
          LatLng(30.7855, 31.0020),
        ],
      );
    }
    else {
      return CoverageRequestDetail(
        id: id,

        title: "4G Coverage Expansion!!!",

        description:
        "This request aims to improve 4G coverage quality "
            "in dense residential areas with weak signal readings.",

        createdBy: "admin",

        city: "Tanta",
        country: "Egypt",

        initialDensityScore: 20,
        currentDensityScore: 65,
        targetDensityScore: 100,

        rewardAmount: 250,

        status: "Open",

        createdAt: DateTime.now(),

        area: [
          LatLng(30.7905, 31.0004),
          LatLng(30.7920, 31.0040),
          LatLng(30.7880, 31.0060),
          LatLng(30.7855, 31.0020),
        ],
      );
    }
  }

  Future<double> fetchUserContribution(int requestId) async {
    await Future.delayed(const Duration(seconds: 1));

    // simulate API response
    return 5.8;
  }
}
