// incentive_model.dart

class IncentiveTier {
  final int id;
  final int targetRides;
  /// Rides counted toward this quest (per incentive row — not shared across quests).
  final int completedRides;
  final double rewardAmount;
  final bool isLocked;
  final String? description;
  /// Raw time strings from API (e.g. "06:00:00") for slot-based quests.
  final String? startTime;
  final String? endTime;
  final String? recurrenceType;

  IncentiveTier({
    required this.id,
    required this.targetRides,
    this.completedRides = 0,
    required this.rewardAmount,
    this.isLocked = false,
    this.description,
    this.startTime,
    this.endTime,
    this.recurrenceType,
  });

  int get ridesRemaining =>
      (targetRides - completedRides).clamp(0, targetRides);

  // Parse from API JSON response
  factory IncentiveTier.fromJson(Map<String, dynamic> json) {
    return IncentiveTier(
      id: json['id'] ?? 0,
      targetRides: json['target_rides'] ?? json['targetRides'] ?? 0,
      completedRides: json['completed_rides'] ?? json['completedRides'] ?? 0,
      rewardAmount:
          (json['reward_amount'] ?? json['rewardAmount'] ?? 0).toDouble(),
      isLocked: json['is_locked'] ?? json['isLocked'] ?? false,
      description: json['description'],
      startTime: json['start_time']?.toString() ?? json['startTime']?.toString(),
      endTime: json['end_time']?.toString() ?? json['endTime']?.toString(),
      recurrenceType: json['recurrence_type']?.toString() ??
          json['recurrenceType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'target_rides': targetRides,
      'completed_rides': completedRides,
      'reward_amount': rewardAmount,
      'is_locked': isLocked,
      'description': description,
      'start_time': startTime,
      'end_time': endTime,
      'recurrence_type': recurrenceType,
    };
  }
}

class IncentiveData {
  final int currentRides;
  final double totalEarned;
  final List<IncentiveTier> tiers;

  IncentiveData({
    required this.currentRides,
    required this.totalEarned,
    required this.tiers,
  });

  factory IncentiveData.fromJson(Map<String, dynamic> json) {
    var tiersJson = json['incentive_tiers'] ?? json['tiers'] ?? [];
    List<IncentiveTier> tiersList = [];

    if (tiersJson is List) {
      tiersList =
          tiersJson.map((tier) => IncentiveTier.fromJson(tier)).toList();
    }

    return IncentiveData(
      currentRides: json['current_rides'] ?? json['currentRides'] ?? 0,
      totalEarned:
          (json['total_earned'] ?? json['totalEarned'] ?? 0).toDouble(),
      tiers: tiersList,
    );
  }
}
