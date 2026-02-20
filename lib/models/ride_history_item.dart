class RideHistoryItem {
  final int id;
  final String pickupAddress;
  final String dropAddress;
  final double fare;
  final DateTime date;
  final String status;
  final String paymentMode;
  final String rideType;
  final double? distanceKm;

  RideHistoryItem({
    required this.id,
    required this.pickupAddress,
    required this.dropAddress,
    required this.fare,
    required this.date,
    this.status = 'completed',
    this.paymentMode = 'cash',
    this.rideType = 'bike',
    this.distanceKm,
  });

  factory RideHistoryItem.fromJson(Map<String, dynamic> json) {
    final idVal = json['rideId'] ?? json['id'];
    final id = idVal is int ? idVal : int.tryParse(idVal?.toString() ?? '0') ?? 0;
    final fareVal = json['fare'] ?? json['amount'];
    final fare = (fareVal is num) ? fareVal.toDouble() : double.tryParse(fareVal?.toString() ?? '0') ?? 0.0;
    final dateStr = json['createdAt'] ?? json['created_at'] ?? json['completedAt'] ?? json['date'];
    final date = DateTime.tryParse(dateStr?.toString() ?? '') ?? DateTime.now();
    return RideHistoryItem(
      id: id,
      pickupAddress: json['pickupAddress'] ?? json['pickup_address'] ?? '',
      dropAddress: json['dropAddress'] ?? json['drop_address'] ?? '',
      fare: fare,
      date: date,
      status: (json['status'] ?? 'completed').toString(),
      paymentMode: (json['paymentMode'] ?? json['payment_mode'] ?? 'cash').toString(),
      rideType: (json['rideType'] ?? json['ride_type'] ?? 'bike').toString(),
      distanceKm: _toDouble(json['distanceKm'] ?? json['distance_km']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
