import 'package:latlong2/latlong.dart';

class CoverageRequestDetail {
  final int id;
  final String title;
  final String description;
  final String createdBy;

  final String city;
  final String country;

  final double initialDensityScore;
  final double currentDensityScore;
  final double targetDensityScore;

  final double rewardAmount;

  final String status;

  final DateTime createdAt;
  final DateTime? completedAt;

  final List<LatLng> area;

  CoverageRequestDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.city,
    required this.country,
    required this.initialDensityScore,
    required this.currentDensityScore,
    required this.targetDensityScore,
    required this.rewardAmount,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.area,
  });

  factory CoverageRequestDetail.fromJson(Map<String, dynamic> json) {
    return CoverageRequestDetail(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      createdBy: json['created_by_display'],

      city: json['city'],
      country: json['country'],

      initialDensityScore: (json['initial_density_score'] ?? 0).toDouble(),
      currentDensityScore: (json['current_density_score'] ?? 0).toDouble(),
      targetDensityScore: (json['target_density_score'] ?? 0).toDouble(),

      rewardAmount: (json['reward_amount'] ?? 0).toDouble(),
      status: json['status'],

      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,

      area: ((json['area']?['coordinates']?[0] ?? [])
      as List<dynamic>)
          .map(
            (point) => LatLng(
          point[1].toDouble(),
          point[0].toDouble(),
        ),
      ).toList(),

    );
  }

  double userRewardShare(double userContribution) {
    if (targetDensityScore == 0) return 0;

    final ratio = userContribution / targetDensityScore;
    return (ratio * rewardAmount).clamp(0, rewardAmount);
  }

  String get location => "$city, $country";
}
