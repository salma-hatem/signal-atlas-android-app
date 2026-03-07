
class SignalThresholds {
  static const int excellent = -85;
  static const int good = -95;
  static const int fair = -105;
  static const int poor = -120;

  static int rsrpStrengthLevel(int rsrp) {
    if (rsrp >= excellent) return 4;
    if (rsrp >= good) return 3;
    if (rsrp >= fair) return 2;
    if (rsrp >= poor) return 1;
    return 0;
  }

  static String label(int strength) {
    if (strength <= 0) return "No Signal";
    if (strength == 1) return "Poor";
    if (strength == 2) return "Fair";
    if (strength == 3) return "Good";
    return "Excellent";
  }

  static const Map<String, MetricRange> kpiRanges = {
    'RSRP': MetricRange(-140, -43),
    'RSRQ': MetricRange(-20, -3),
    'RSSI': MetricRange(-113, -51),
    'ASU': MetricRange(0, 97),
  };
}

class MetricRange {
  final int min;
  final int max;

  const MetricRange(this.min, this.max);
}
