class Session {
  final DateTime date;
  final Duration duration;
  final int sampleCount;

  final bool isCoverageRequest;

  final int? requestId;
  final String? requestTitle;

  late final double avgRatePerMin =
  duration.inMinutes > 0
      ? sampleCount / duration.inMinutes
      : sampleCount.toDouble();

  Session({
    required this.date,
    required this.duration,
    required this.sampleCount,

    this.isCoverageRequest = false,

    this.requestId,
    this.requestTitle,
  });

  String get dateString =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  String get durationString => "${duration.inMinutes} min";
}
