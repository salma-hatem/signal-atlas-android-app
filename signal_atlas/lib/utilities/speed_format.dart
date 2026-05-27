String formatSpeed(double? speed) {
  if (speed == null) return "--";

  if (speed < 1) return "0";
  return speed.toStringAsFixed(1);
}
