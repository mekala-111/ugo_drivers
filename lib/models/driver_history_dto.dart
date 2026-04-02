/// One row from GET /api/drivers/app/history (privacy-safe; no phone).
class DriverHistoryDto {
  const DriverHistoryDto({
    required this.rideId,
    this.rideType,
    required this.riderName,
    this.pickupArea,
    this.dropArea,
    required this.fare,
    this.paymentMethod,
    required this.status,
    required this.tripDate,
    this.distanceKm,
    this.durationMinutes,
    this.durationLabel,
  });

  final int rideId;
  final String? rideType;
  final String riderName;
  final String? pickupArea;
  final String? dropArea;
  final double fare;
  final String? paymentMethod;
  final String status;
  final DateTime tripDate;
  final double? distanceKm;
  final int? durationMinutes;
  final String? durationLabel;

  factory DriverHistoryDto.fromJson(Map<String, dynamic> json) {
    final idVal = json['ride_id'] ?? json['id'];
    final id = idVal is int
        ? idVal
        : int.tryParse(idVal?.toString() ?? '0') ?? 0;
    final fareVal = json['fare'] ?? json['amount'];
    final fare = (fareVal is num)
        ? fareVal.toDouble()
        : double.tryParse(fareVal?.toString() ?? '0') ?? 0.0;
    final tripRaw = json['trip_date'] ?? json['date'];
    final tripDate =
        DateTime.tryParse(tripRaw?.toString() ?? '') ?? DateTime.now();
    final dist = json['distance_km'] ?? json['distanceKm'];
    double? dkm;
    if (dist != null) {
      dkm = dist is num ? dist.toDouble() : double.tryParse(dist.toString());
    }
    final dur = json['duration_minutes'];
    int? dm;
    if (dur != null) {
      dm = dur is int ? dur : int.tryParse(dur.toString());
    }
    return DriverHistoryDto(
      rideId: id,
      rideType: json['ride_type']?.toString(),
      riderName: (json['rider_name'] ?? 'Rider').toString(),
      pickupArea: json['pickup_area']?.toString(),
      dropArea: json['drop_area']?.toString(),
      fare: fare,
      paymentMethod: json['payment_method']?.toString(),
      status: (json['status'] ?? 'completed').toString().toLowerCase(),
      tripDate: tripDate,
      distanceKm: dkm,
      durationMinutes: dm,
      durationLabel: json['duration_label']?.toString(),
    );
  }
}
