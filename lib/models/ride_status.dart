enum RideStatus {
  searching,
  accepted,
  arrived,
  started,
  onTrip,
  completed,
  cancelled,
  rejected,
  expired,
  pickedUp,
  inProgress,
  driverAssigned,
  qrScanned,
  fetching,
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
      case RideStatus.expired:
        return 'EXPIRED';
      case RideStatus.pickedUp:
        return 'PICKEDUP';
      case RideStatus.inProgress:
        return 'INPROGRESS';
      case RideStatus.driverAssigned:
        return 'DRIVERASSIGNED';
      case RideStatus.qrScanned:
        return 'QRSCANNED';
      case RideStatus.fetching:
        return 'FETCHING';
      default:
        return 'UNKNOWN';
    }
  }

  static RideStatus fromString(String? s) {
    if (s == null) return RideStatus.unknown;
    final normalized = s.trim().toUpperCase().replaceAll('_', '');
    switch (normalized) {
      case 'SEARCHING':
        return RideStatus.searching;
      case 'ACCEPTED':
        return RideStatus.accepted;
      case 'ARRIVED':
        return RideStatus.arrived;
      case 'STARTED':
        return RideStatus.started;
      case 'ONTRIP':
        return RideStatus.onTrip;
      case 'COMPLETED':
        return RideStatus.completed;
      case 'CANCELLED':
      case 'CANCELED':
        return RideStatus.cancelled;
      case 'DECLINED':
      case 'REJECTED':
        return RideStatus.rejected;
      case 'EXPIRED':
        return RideStatus.expired;
      case 'PICKEDUP':
        return RideStatus.pickedUp;
      case 'INPROGRESS':
        return RideStatus.inProgress;
      case 'DRIVERASSIGNED':
        return RideStatus.driverAssigned;
      case 'QRSCANNED':
        return RideStatus.qrScanned;
      case 'FETCHING':
        return RideStatus.fetching;
      default:
        return RideStatus.unknown;
    }
  }
}
