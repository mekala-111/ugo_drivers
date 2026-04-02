/// Normalized driver “captain” dashboard from GET /api/drivers/app/dashboard.
class DriverDashboardSummary {
  const DriverDashboardSummary({
    required this.driverName,
    this.profileImage,
    required this.onlineStatus,
    required this.todayEarnings,
    required this.todayTripCount,
    required this.weeklyEarnings,
    required this.walletBalance,
    this.rating,
    required this.totalRidesCompleted,
    this.acceptanceRate,
    this.cancellationRate,
    this.currentActiveRide,
    this.recentTrip,
  });

  final String driverName;
  final String? profileImage;
  final bool onlineStatus;
  final double todayEarnings;
  final int todayTripCount;
  final double weeklyEarnings;
  final double walletBalance;
  final double? rating;
  final int totalRidesCompleted;
  final double? acceptanceRate;
  final double? cancellationRate;
  final Map<String, dynamic>? currentActiveRide;
  final Map<String, dynamic>? recentTrip;

  factory DriverDashboardSummary.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    int n(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    Map<String, dynamic>? m(dynamic v) =>
        v is Map ? Map<String, dynamic>.from(v) : null;

    return DriverDashboardSummary(
      driverName: (json['driver_name'] ?? '').toString(),
      profileImage: json['profile_image']?.toString(),
      onlineStatus: json['online_status'] == true,
      todayEarnings: d(json['today_earnings']),
      todayTripCount: n(json['today_trip_count']),
      weeklyEarnings: d(json['weekly_earnings']),
      walletBalance: d(json['wallet_balance']),
      rating: json['rating'] != null ? d(json['rating']) : null,
      totalRidesCompleted: n(json['total_rides_completed']),
      acceptanceRate:
          json['acceptance_rate'] != null ? d(json['acceptance_rate']) : null,
      cancellationRate: json['cancellation_rate'] != null
          ? d(json['cancellation_rate'])
          : null,
      currentActiveRide: m(json['current_active_ride']),
      recentTrip: m(json['recent_trip']),
    );
  }
}
