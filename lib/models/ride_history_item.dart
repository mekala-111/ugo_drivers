class RideHistoryItem {
  final int id;
  final String pickupAddress;
  final String dropAddress;
  final double fare;
  final DateTime date;

  RideHistoryItem({
    required this.id,
    required this.pickupAddress,
    required this.dropAddress,
    required this.fare,
    required this.date,
  });

  factory RideHistoryItem.fromJson(Map<String, dynamic> json) {
    return RideHistoryItem(
      id: json['id'] ?? 0,
      pickupAddress: json['pickup_address'] ?? '',
      dropAddress: json['drop_address'] ?? '',
      fare: (json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
