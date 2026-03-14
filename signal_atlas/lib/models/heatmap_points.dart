/* Heatmap Points
This class is holds KPI values for each location, which are then used to draw the heatmaps

Variables:
Location (Latitude, Longitude, Altitude),  RSRP, RSRQ

*/

import '../utilities/signal_thresholds.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

class HeatmapPoints {
  // Location
  final double latitude;
  final double longitude;

  // Network KPIs
  final int rsrp;
  final int rsrq;


  HeatmapPoints({
    required this.latitude,
    required this.longitude,
    required this.rsrp,
    required this.rsrq,
  });

  double get normalisedRsrp => SignalThresholds.normalize("RSRP", rsrp);
  double get normalisedRsrq => SignalThresholds.normalize("RSRQ", rsrq);

  WeightedLatLng get rsrpWeightedLatLng => WeightedLatLng(LatLng(latitude, longitude), rsrp.toDouble());
  WeightedLatLng get rsrqWeightedLatLng => WeightedLatLng(LatLng(latitude, longitude), rsrq.toDouble());

  // Factory constructor to create from JSON
  factory HeatmapPoints.fromJson(Map<String, dynamic> json) {
    return HeatmapPoints(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      rsrp: (json['rsrp'] ?? 0) as int,
      rsrq: (json['rsrq'] ?? 0) as int,
    );
  }

}
