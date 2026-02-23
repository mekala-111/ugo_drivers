enum RideStatus {
  searching,
  accepted,
  arrived,
  started,
  onTrip,
  completed,
  cancelled,
  rejected,
  unknown,
}

extension RideStatusX on RideStatus {
  String get value {
    switch (this) {
      case RideStatus.searching:
        return 'SEARCHING';
      case RideStatus.accepted:
        return 'ACCEPTED';
      case RideStatus.arrived:
        return 'ARRIVED';
      case RideStatus.started:
        return 'STARTED';
      case RideStatus.onTrip:
        return 'ONTRIP';
      case RideStatus.completed:
        return 'COMPLETED';
      case RideStatus.cancelled:
        return 'CANCELLED';
      case RideStatus.rejected:
        return 'REJECTED';
      default:
        return 'UNKNOWN';
    }
  }

  static RideStatus fromString(String? s) {
    if (s == null) return RideStatus.unknown;
    switch (s.toLowerCase()) {
      case 'searching':
        return RideStatus.searching;
      case 'accepted':
        return RideStatus.accepted;
      case 'arrived':
        return RideStatus.arrived;
      case 'started':
        return RideStatus.started;
      case 'ontrip':
      case 'on_trip':
        return RideStatus.onTrip;
      case 'completed':
        return RideStatus.completed;
      case 'cancelled':
      case 'canceled':
        return RideStatus.cancelled;
      case 'declined':
        return RideStatus.rejected;
      case 'rejected':
        return RideStatus.rejected;
      default:
        return RideStatus.unknown;
    }
  }
}
