import '../models/heatmap_points.dart';
import '../models/trend_points.dart';
import '../services/api_service.dart';

class DashboardService {
  double radius_km = 10;

  Future<Map<String, dynamic>> getDashboardStats({
    required String operator,
    required String networkType,
    required bool showPredictedData,
    required double lat,
    required double lon,
    required String period,
  }) async {
    bool health = await ApiService.checkHealth();
    print("server health $health");

    String source = showPredictedData ? "all" : "measured";
    final data = await ApiService.get(
      "/api/mobile/overview",
      query: {
        "operator": operator,
        "network_type": networkType,
        "source": source,
        "period": mapPeriodToApi(period),
        "lon": lon,
        "lat": lat,
        "radius_km": radius_km,
      },
    );

    return {
      "meanRSRP": data["mean_rsrp"],
      "meanRSRQ": data["mean_rsrq"],
      "coverage": data["coverage_quality_percent"],
      "count": data["measurements_count"],
    };
  }

  Future<List<HeatmapPoints>> getHeatmapPoints({
    required String operator,
    required String networkType,
    required bool showPredictedData,
    required double lat,
    required double lon,
    required String period,
  }) async {

    String source = showPredictedData ? "all" : "measured";
    final data = await ApiService.get(
      "/api/mobile/map",
      query: {
        "operator": operator,
        "network_type": networkType,
        "source": source,
        "period": mapPeriodToApi(period),
        "lon": lon,
        "lat": lat,
        "radius_km": radius_km,
      },
    );

    final List points = data["points"];

    return points.map((p) {
      return HeatmapPoints(
        latitude: p["latitude"],
        longitude: p["longitude"],
        rsrp: p["rsrp"],
        rsrq: p["rsrq"],
      );
    }).toList();
  }

  Future<List<TrendPoints>> getTrendPoints({
    required String operator,
    required String networkType,
    required bool showPredictedData,
    required double lat,
    required double lon,
    required String period,
  }) async {

    String source = showPredictedData ? "all" : "measured";
    final data = await ApiService.get(
      "/api/mobile/trends",
      query: {
        "operator": operator,
        "network_type": networkType,
        "source": source,
        "period": mapPeriodToApi(period),
        "lon": lon,
        "lat": lat,
        "radius_km": radius_km,
      },
    );

    final List points = data["points"];

    return points.map((p) {
      return TrendPoints(
        time: DateTime.parse(p["timestamp"]),
        rsrp: p["mean_rsrp"].round(),
        rsrq: p["mean_rsrq"].round(),
      );
    }).toList();
  }

  Future<List<String>> getOperators() async {
    final data = await ApiService.get("/api/mobile/operators/unique");

    final List operators = data["operators"];
    print("OPerator $operators");

    return operators.cast<String>();
  }

  String mapPeriodToApi(String period) {
    switch (period) {
      case "Past 24h":
        return "24h";
      case "Past week":
        return "week";
      case "Past month":
        return "month";
      default:
        return "24h"; // fallback
    }
  }
}
