class CoverageRequest {
  final int id;
  final String title;
  final String city;
  final String country;
  final String status;
  final DateTime createdAt;
  final double rewardAmount;

  CoverageRequest({
    required this.id,
    required this.title,
    required this.city,
    required this.country,
    required this.status,
    required this.createdAt,
    required this.rewardAmount,
  });

  factory CoverageRequest.fromJson(Map<String, dynamic> json) {
    return CoverageRequest(
      id: json['id'] ?? 0,

      title: json['title'] ?? "Untitled Request",

      city: json['city'] ?? "Unknown City",

      country: json['country'] ?? "Unknown Country",

      status: json['status'] ?? "Open",

      createdAt: DateTime.tryParse(json['created_at'] ?? "") ?? DateTime.now(),

      rewardAmount: (json['reward_amount'] ?? 0).toDouble(),

    );
  }

  String get location => "$city, $country";
}
