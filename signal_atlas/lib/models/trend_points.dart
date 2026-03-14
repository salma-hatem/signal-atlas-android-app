/* Trend Points
This class is holds the values for line charts

Variables:
Timestamp,  RSRP, RSRQ

*/


import '../utilities/signal_thresholds.dart';

class TrendPoints {
  // Timestamp
  final DateTime time;

  // Network KPIs
  final int rsrp;
  final int rsrq;


  TrendPoints({
    required this.time,
    required this.rsrp,
    required this.rsrq,
  });

  double get timeMs => time.millisecondsSinceEpoch.toDouble();

  double get normalisedRsrp => SignalThresholds.normalize("RSRP", rsrp);
  double get normalisedRsrq => SignalThresholds.normalize("RSRQ", rsrq);

  // Factory constructor to create from JSON
  factory TrendPoints.fromJson(Map<String, dynamic> json) {
    return TrendPoints(
      time: DateTime.parse(json['time'] ?? DateTime.now().toIso8601String()),
      rsrp: (json['rsrp'] ?? 0) as int,
      rsrq: (json['rsrq'] ?? 0) as int,
    );
  }
}
