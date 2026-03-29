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
  final s = value.toString().trim().toLowerCase();
  if (s.isEmpty || s == 'null') return PaymentMode.unknown;

  // Accept common cash variants from backend / sockets.
  if (s == 'cash' ||
      s == 'cod' ||
      s == 'cash_payment' ||
      s == 'cash on delivery' ||
      s == 'cash_on_delivery' ||
      s.contains('cash')) {
    return PaymentMode.cash;
  }

  // Treat all non-cash digital modes as online.
  if (s == 'online' ||
      s == 'wallet' ||
      s == 'upi' ||
      s == 'card' ||
      s.contains('upi') ||
      s.contains('wallet') ||
      s.contains('card') ||
      s.contains('online')) {
    return PaymentMode.online;
  }
  return PaymentMode.unknown;
}
