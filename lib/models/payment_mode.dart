/// Payment mode for a ride - determines post-ride flow (cash collection vs online received).
enum PaymentMode {
  cash,
  online,
  unknown,
}

extension PaymentModeX on PaymentMode {
  bool get isCash => this == PaymentMode.cash;
  bool get isOnline => this == PaymentMode.online;
}

/// Parse from API string (payment_mode, payment_method, payment_type).
PaymentMode parsePaymentMode(dynamic value) {
  if (value == null) return PaymentMode.unknown;
  final s = value.toString().toLowerCase();
  if (s == 'cash') return PaymentMode.cash;
  if (s == 'online' || s == 'wallet' || s == 'upi' || s == 'card') return PaymentMode.online;
  return PaymentMode.unknown;
}
