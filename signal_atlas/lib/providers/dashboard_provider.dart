import 'package:flutter/material.dart';
import '../models/network_reading.dart';
import '../models/heatmap_points.dart';
import '../models/trend_points.dart';
import '../services/dashboard_service.dart';
import '../utilities/signal_thresholds.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService service;
  NetworkReading? reading;

  DashboardProvider({required this.service,});

  Future<void> initializeDashboard() async {
    await loadOperators();
    await loadDashboard();
  }

  String networkType = "LTE"; // limited by project scope
  String selectedKPI = "RSRP";
  String selectedOperator = "Vodafone";
  String selectedPeriod = "Past month";
  bool showPredictedData = false;

  String timeUnits = "hours";

  List<String> operatorList = [];

  List<String> kpiList = [
    "RSRP",
    "RSRQ",
  ];
  List<String> periodList = [
    "Past 24h",
    "Past week",
    "Past month",
  ];

  bool isLoading = false;

  List<HeatmapPoints> heatmapPoints = [];
  List<WeightedLatLng> weightedLatLngPoints = [];
  List<TrendPoints> trendPoints = [];

  double? meanRSRP;
  double? meanRSRQ;
  double? coverage;
  int? measurementsCount;

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        service.getHeatmapPoints(
          operator: selectedOperator,
          networkType: networkType,
          period: selectedPeriod,
          showPredictedData: showPredictedData,
          lat: reading!.latitude,
          lon: reading!.longitude,
        ).catchError((e) {
          debugPrint("heatmap error: $e");
          return <HeatmapPoints>[];
        }),
        service.getTrendPoints(
          operator: selectedOperator,
          networkType: networkType,
          period: selectedPeriod,
          showPredictedData: showPredictedData,
          lat: reading!.latitude,
          lon: reading!.longitude,
        ).catchError((e) {
          debugPrint("trend error: $e");
          return <TrendPoints>[];
        }),
        service.getDashboardStats(
          operator: selectedOperator,
          networkType: networkType,
          period: selectedPeriod,
          showPredictedData: showPredictedData,
          lat: reading!.latitude,
          lon: reading!.longitude,
        ).catchError((e) {
          debugPrint("stats error: $e");
          return <String, dynamic>{};
        }),
      ]);

      debugPrint("heatmap raw: ${results[0]}");
      debugPrint("trend raw: ${results[1]}");
      debugPrint("stats raw: ${results[2]}");


      heatmapPoints = (results[0] as List<HeatmapPoints>? ?? []);

      if (selectedKPI == "RSRP") {
        weightedLatLngPoints = heatmapPoints.map((p) {
          final normalized = SignalThresholds.normalize("RSRP", p.rsrp.toInt());

          return WeightedLatLng(
            LatLng(p.latitude, p.longitude),
            normalized,
          );
        }).toList();
      } else if (selectedKPI == "RSRQ") {
        weightedLatLngPoints = heatmapPoints.map((p) {
          final normalized = SignalThresholds.normalize("RSRQ", p.rsrq.toInt());

          return WeightedLatLng(
            LatLng(p.latitude, p.longitude),
            normalized,
          );
        }).toList();
      }

      trendPoints = (results[1] as List<TrendPoints>? ?? []);

      final stats = results[2] as Map<String, dynamic>? ?? {};
      meanRSRP = (stats["meanRSRP"] as num?)?.toDouble();
      meanRSRQ = (stats["meanRSRQ"] as num?)?.toDouble();
      coverage = (stats["coverage"] as num?)?.toDouble();
      measurementsCount = (stats["count"] as num?)?.toInt();

    } catch (e) {
      debugPrint("Dashboard error: $e");
    }

    updateTimeUnits();
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadOperators() async {
    try {
      operatorList = await service.getOperators();

      if (operatorList.isNotEmpty && !operatorList.contains(selectedOperator)) {
        selectedOperator = operatorList.first;
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Operator load error: $e");
    }
  }

  void updateOperator(String value) {
    selectedOperator = value;
    loadDashboard();
  }

  void updatePeriod(String value) {
    selectedPeriod = value;
    loadDashboard();
  }

  void updateKPI(String value) {
    selectedKPI = value;
    notifyListeners();
  }

  void updatePrediction(bool value) {
    showPredictedData = value;
    loadDashboard();
  }
  void setReading(NetworkReading initialReading)
  {
    reading = initialReading;
    selectedOperator = initialReading.operatorName.trim();
  }

  void updateTimeUnits()
  {
    switch(selectedPeriod) {
      case "Past 24h":
        timeUnits = "hours";
        break;
      case "Past week":
        timeUnits = "days";
        break;
      case "Past month":
        timeUnits = "days";
        break;
      default:
        timeUnits = "hours";
        break;
    }
  }
}
