class TransactionModel {
  final String title;
  final double amount;
  final String date;

  TransactionModel({
    required this.title,
    required this.amount,
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      title: _capitalize(json["transaction_type"]),
      amount: double.tryParse(json["amount"].toString()) ?? 0.0,
      date: json["created_at"] ?? "",
    );
  }

  static String _capitalize(dynamic value) {
    final text = value?.toString().toLowerCase() ?? "";

    if (text.isEmpty) return "";

    return text[0].toUpperCase() + text.substring(1);
  }
}
