// incentive_model.dart

class IncentiveTier {
  final int id;
  final int targetRides;
  final double rewardAmount;
  final bool isLocked;
  final String? description;

  IncentiveTier({
    required this.id,
    required this.targetRides,
    required this.rewardAmount,
    this.isLocked = false,
    this.description,
  });

  // Parse from API JSON response
  factory IncentiveTier.fromJson(Map<String, dynamic> json) {
    return IncentiveTier(
      id: json['id'] ?? 0,
      targetRides: json['target_rides'] ?? json['targetRides'] ?? 0,
      rewardAmount: (json['reward_amount'] ?? json['rewardAmount'] ?? 0).toDouble(),
      isLocked: json['is_locked'] ?? json['isLocked'] ?? false,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'target_rides': targetRides,
      'reward_amount': rewardAmount,
      'is_locked': isLocked,
      'description': description,
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
      tiersList = tiersJson.map((tier) => IncentiveTier.fromJson(tier)).toList();
    }

    return IncentiveData(
      currentRides: json['current_rides'] ?? json['currentRides'] ?? 0,
      totalEarned: (json['total_earned'] ?? json['totalEarned'] ?? 0).toDouble(),
      tiers: tiersList,
    );
  }
}
