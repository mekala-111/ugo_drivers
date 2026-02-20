/// Input validation utilities for production safety.
/// Used for phone, OTP, PAN, Aadhaar before API/UI submission.
class InputValidators {
  InputValidators._();

  /// Indian mobile: 10 digits, optionally prefixed with +91
  static bool isValidIndianPhone(String? value) {
    if (value == null || value.isEmpty) return false;
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final digits = cleaned.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length == 12) return true;
    if (digits.length == 10 && digits.startsWith(RegExp(r'[6-9]'))) return true;
    return false;
  }

  /// OTP: 4-6 digits
  static bool isValidOtp(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r'^\d{4,6}$').hasMatch(value);
  }

  /// PAN: AAAAA9999A format
  static bool isValidPan(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(value.toUpperCase());
  }

  /// Aadhaar: 12 digits, optional spaces
  static bool isValidAadhaar(String? value) {
    if (value == null || value.isEmpty) return false;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length == 12;
  }

  static String? phoneError(String? value) =>
      isValidIndianPhone(value) ? null : 'Enter a valid 10-digit mobile number';

  static String? otpError(String? value) =>
      isValidOtp(value) ? null : 'Enter a valid OTP (4-6 digits)';

  static String? panError(String? value) =>
      isValidPan(value) ? null : 'Enter valid PAN (e.g. ABCDE1234F)';

  static String? aadhaarError(String? value) =>
      isValidAadhaar(value) ? null : 'Enter valid 12-digit Aadhaar number';
}
