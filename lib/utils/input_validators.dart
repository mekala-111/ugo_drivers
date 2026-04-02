/// Input validation utilities for production safety.
/// Used for phone, OTP, PAN, Aadhaar, license before API/UI submission.
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

  /// Strips separators for storage/API checks (Sarathi / Parivahan style).
  static String normalizeDrivingLicense(String value) {
    return value.trim().toUpperCase().replaceAll(RegExp(r'[\s\-\.\/]'), '');
  }

  /// Indian driving licence — Sarathi/Parivahan (2-letter state + digits) plus
  /// legacy prefixes seen on TG/AP smart cards (e.g. DLFAP0222632005 — 5 letters + 10 digits).
  ///
  /// After normalization: length 13–18, ASCII A–Z and digits only.
  static bool isValidLicense(String? value) {
    if (value == null || value.isEmpty) return false;
    final s = normalizeDrivingLicense(value);
    if (s.length < 13 || s.length > 18) return false;
    if (RegExp(r'^[A-Z]{2}\d{11,16}$').hasMatch(s)) return true;
    if (RegExp(r'^[A-Z]{3,5}\d{10,12}$').hasMatch(s)) return true;
    return false;
  }

  /// Contiguous DL string for the text field (no spaces; separators stripped).
  static String formatDrivingLicenseForDisplay(String normalized) =>
      normalizeDrivingLicense(normalized);

  static String get licenseInvalidFormatMessage =>
      'Invalid format (e.g. TS022018001234 or legacy DLFAP0222632005)';

  /// License expiry: YYYY-MM-DD or DD/MM/YYYY, must not be in past
  static bool isValidLicenseExpiry(String? value) {
    if (value == null || value.isEmpty) return false;
    final date = _parseDate(value);
    return date != null && date.isAfter(DateTime.now());
  }

  static DateTime? _parseDate(String value) {
    final trimmed = value.trim();
    // YYYY-MM-DD
    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
    var m = iso.firstMatch(trimmed);
    if (m != null) {
      final y = int.tryParse(m.group(1)!);
      final mo = int.tryParse(m.group(2)!);
      final d = int.tryParse(m.group(3)!);
      if (y != null && mo != null && d != null) {
        return DateTime(y, mo, d);
      }
    }
    // DD/MM/YYYY
    final dmy = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
    m = dmy.firstMatch(trimmed);
    if (m != null) {
      final d = int.tryParse(m.group(1)!);
      final mo = int.tryParse(m.group(2)!);
      final y = int.tryParse(m.group(3)!);
      if (d != null && mo != null && y != null) {
        return DateTime(y, mo, d);
      }
    }
    return null;
  }

  /// Date of birth: valid date, driver must be 18+
  static bool isValidDateOfBirth(String? value) {
    if (value == null || value.isEmpty) return false;
    final date = _parseDate(value);
    if (date == null) return false;
    final age = DateTime.now().year - date.year;
    return age >= 18 && age <= 100;
  }

  static String? phoneError(String? value) =>
      isValidIndianPhone(value) ? null : 'Enter a valid 10-digit mobile number';

  static String? otpError(String? value) =>
      isValidOtp(value) ? null : 'Enter a valid OTP (4-6 digits)';

  static String? panError(String? value) =>
      isValidPan(value) ? null : 'Enter valid PAN (e.g. ABCDE1234F)';

  static String? aadhaarError(String? value) =>
      isValidAadhaar(value) ? null : 'Enter valid 12-digit Aadhaar number';

  static String? licenseError(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'License number is required';
    }
    if (!isValidLicense(value)) return licenseInvalidFormatMessage;
    return null;
  }

  static String? licenseExpiryError(String? value) {
    if (value == null || value.isEmpty) return null;
    final date = _parseDate(value);
    if (date == null) return 'Enter valid date (YYYY-MM-DD or DD/MM/YYYY)';
    if (!date.isAfter(DateTime.now())) {
      return 'License has expired. Please renew before registering.';
    }
    return null;
  }

  static String? dateOfBirthError(String? value) {
    if (value == null || value.isEmpty) return null;
    final date = _parseDate(value);
    if (date == null) return 'Enter valid date (YYYY-MM-DD or DD/MM/YYYY)';
    final age = DateTime.now().year - date.year;
    if (age < 18) return 'You must be at least 18 years old';
    if (age > 100) return 'Please enter a valid date of birth';
    return null;
  }
}
