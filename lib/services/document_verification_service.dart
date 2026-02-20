/// Uber-style document verification service.
/// Runs validations on all onboarding documents before allowing server submission.
import '../app_state.dart';
import '../flutter_flow/uploaded_file.dart';
import '../utils/input_validators.dart';

class DocumentVerificationResult {
  final bool isValid;
  final List<String> errors;

  DocumentVerificationResult({required this.isValid, required this.errors});

  String get errorSummary => errors.join('\n• ');
}

class DocumentVerificationService {
  DocumentVerificationService._();

  static DocumentVerificationResult verifyAll() {
    final errors = <String>[];

    // 1. Personal details
    if (FFAppState().firstName.trim().isEmpty) {
      errors.add('First name is required');
    }
    if (FFAppState().lastName.trim().isEmpty) {
      errors.add('Last name is required');
    }
    if (FFAppState().email.trim().isEmpty) {
      errors.add('Email is required');
    } else if (!FFAppState().email.contains('@')) {
      errors.add('Enter a valid email address');
    }
    if (FFAppState().mobileNo == 0 || FFAppState().mobileNo.toString().length < 10) {
      errors.add('Valid mobile number is required');
    } else if (!InputValidators.isValidIndianPhone(FFAppState().mobileNo.toString())) {
      errors.add('Enter a valid 10-digit Indian mobile number');
    }

    // 2. Driving License (required for onboarding)
    final hasLicenseFront = _hasDoc(FFAppState().licenseFrontImage) ||
        _hasDoc(FFAppState().imageLicense);
    final hasLicenseBack = _hasDoc(FFAppState().licenseBackImage);
    if (!hasLicenseFront) {
      errors.add('Driving License: Front image is required');
    }
    if (!hasLicenseBack) {
      errors.add('Driving License: Back image is required');
    }
    if (FFAppState().licenseNumber.trim().isEmpty) {
      errors.add('Driving License: License number is required');
    } else if (InputValidators.licenseError(FFAppState().licenseNumber) != null) {
      errors.add('Driving License: ${InputValidators.licenseError(FFAppState().licenseNumber)}');
    }
    if (FFAppState().licenseExpiryDate.isNotEmpty) {
      final expiryErr = InputValidators.licenseExpiryError(FFAppState().licenseExpiryDate);
      if (expiryErr != null) {
        errors.add('Driving License: $expiryErr');
      }
    }

    // 3. Profile Photo (required)
    if (!_hasDoc(FFAppState().profilePhoto)) {
      errors.add('Profile photo is required');
    }

    // 4. Aadhaar (required)
    final hasAadhaar = _hasDoc(FFAppState().aadharImage) ||
        _hasDoc(FFAppState().aadhaarFrontImage) ||
        _hasDoc(FFAppState().aadhaarBackImage);
    if (!hasAadhaar) {
      errors.add('Aadhaar: Front and/or back image is required');
    }
    if (FFAppState().aadharNumber.trim().isNotEmpty &&
        InputValidators.aadhaarError(FFAppState().aadharNumber) != null) {
      errors.add('Aadhaar: ${InputValidators.aadhaarError(FFAppState().aadharNumber)}');
    }

    // 5. PAN (required)
    if (!_hasDoc(FFAppState().panImage)) {
      errors.add('PAN card image is required');
    }
    if (FFAppState().panNumber.trim().isNotEmpty &&
        InputValidators.panError(FFAppState().panNumber) != null) {
      errors.add('PAN: ${InputValidators.panError(FFAppState().panNumber)}');
    }

    // 6. Vehicle
    if (FFAppState().selectvehicle.isEmpty) {
      errors.add('Please select a vehicle type');
    }

    // 7. Vehicle image (required)
    if (!_hasDoc(FFAppState().vehicleImage)) {
      errors.add('Vehicle photo is required');
    }

    // 8. RC (required)
    final hasRC = _hasDoc(FFAppState().registrationImage) ||
        _hasDoc(FFAppState().rcFrontImage) ||
        _hasDoc(FFAppState().rcBackImage);
    if (!hasRC) {
      errors.add('RC (Registration Certificate): Front and/or back image is required');
    }

    return DocumentVerificationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Less strict: for "Skip for now" - only validates critical fields
  static DocumentVerificationResult verifyMinimum() {
    final errors = <String>[];

    if (FFAppState().firstName.trim().isEmpty) errors.add('First name is required');
    if (FFAppState().lastName.trim().isEmpty) errors.add('Last name is required');
    if (FFAppState().email.trim().isEmpty) {
      errors.add('Email is required');
    } else if (!FFAppState().email.contains('@')) {
      errors.add('Enter a valid email');
    }
    if (!InputValidators.isValidIndianPhone(FFAppState().mobileNo.toString())) {
      errors.add('Valid 10-digit mobile number is required');
    }
    if (FFAppState().selectvehicle.isEmpty) {
      errors.add('Please select a vehicle type');
    }

    return DocumentVerificationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  static bool _hasDoc(dynamic doc) {
    if (doc == null) return false;
    if (doc is FFUploadedFile) {
      return doc.bytes != null && doc.bytes!.isNotEmpty;
    }
    if (doc is String) {
      return doc.isNotEmpty && doc != 'null';
    }
    return false;
  }
}
