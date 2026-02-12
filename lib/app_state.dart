import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/flutter_flow/uploaded_file.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  bool hasProfilePhoto = false;
  bool hasLicense = false;
  bool hasAadhar = false;
  bool hasPan = false;
  bool hasVehicleImage = false;
  bool hasRC = false;
  int _activeRideId = 0;
  String _activeRideStatus = '';
  int _mobileNo = 0;
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _referralCode = '';

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _accessToken = prefs.getString('ff_accessToken') ?? _accessToken;
    });
    _safeInit(() {
      _kycStatus = prefs.getString('ff_kycStatus') ?? _kycStatus;
    });
    _safeInit(() {
      _qrImage = prefs.getString('ff_qrImage') ?? _qrImage;
    });
    _safeInit(() {
      isLoggedIn = prefs.getBool('ff_isLoggedIn') ?? false;
    });
    _safeInit(() {
      _isRegistered = prefs.getBool('ff_isRegistered') ?? false;
    });
    _safeInit(() {
      _driverid = prefs.getInt('ff_driverid') ?? _driverid;
    });
    _safeInit(() {
      _isonline = prefs.getBool('ff_isonline') ?? false;
    });
    _safeInit(() {
      _activeRideId = prefs.getInt('ff_activeRideId') ?? 0;
    });
    _safeInit(() {
      _activeRideStatus = prefs.getString('ff_activeRideStatus') ?? '';
    });
    _safeInit(() {
      _mobileNo = prefs.getInt('ff_mobileNo') ?? 0;
    });
    _safeInit(() {
      _firstName = prefs.getString('ff_firstName') ?? '';
    });
    _safeInit(() {
      _lastName = prefs.getString('ff_lastName') ?? '';
    });
    _safeInit(() {
      _email = prefs.getString('ff_email') ?? '';
    });
    _safeInit(() {
      _referralCode = prefs.getString('ff_referralCode') ?? '';
    });
    _safeInit(() {
      _fcmToken = prefs.getString('ff_fcmToken') ?? '';
    });
    // Aadhaar number
    _safeInit(() {
      _aadharNumber = prefs.getString('ff_aadharNumber') ?? '';
    });
    // Aadhaar image URLs (persistent)
    _safeInit(() {
      _aadharFrontImageUrl = prefs.getString('ff_aadharFrontImageUrl') ?? '';
    });
    _safeInit(() {
      _aadharBackImageUrl = prefs.getString('ff_aadharBackImageUrl') ?? '';
    });
    // Base64 strings (for temporary persistence - optional)
    _safeInit(() {
      _aadharFrontBase64 = prefs.getString('ff_aadharFrontBase64') ?? '';
    });
    _safeInit(() {
      _aadharBackBase64 = prefs.getString('ff_aadharBackBase64') ?? '';
    });

    _safeInit(() {
      _panImageUrl = prefs.getString('ff_panImageUrl') ?? '';
    });
    _safeInit(() {
      _panBase64 = prefs.getString('ff_panBase64') ?? '';
    });
    _safeInit(() {
      _panNumber = prefs.getString('ff_panNumber') ?? '';
    });

    _safeInit(() {
      _profilePhotoUrl = prefs.getString('ff_profilePhotoUrl') ?? '';
    });
    _safeInit(() {
      _profilePhotoBase64 = prefs.getString('ff_profilePhotoBase64') ?? '';
    });

    _safeInit(() {
      _licenseFrontImageUrl = prefs.getString('ff_licenseFrontImageUrl') ?? '';
    });
    _safeInit(() {
      _licenseBackImageUrl = prefs.getString('ff_licenseBackImageUrl') ?? '';
    });
    _safeInit(() {
      _licenseFrontBase64 = prefs.getString('ff_licenseFrontBase64') ?? '';
    });
    _safeInit(() {
      _licenseBackBase64 = prefs.getString('ff_licenseBackBase64') ?? '';
    });
    _safeInit(() {
      _licenseNumber = prefs.getString('ff_licenseNumber') ?? '';
    });

    _safeInit(() {
      _rcFrontImageUrl = prefs.getString('ff_rcFrontImageUrl') ?? '';
    });
    _safeInit(() {
      _rcBackImageUrl = prefs.getString('ff_rcBackImageUrl') ?? '';
    });
    _safeInit(() {
      _rcFrontBase64 = prefs.getString('ff_rcFrontBase64') ?? '';
    });
    _safeInit(() {
      _rcBackBase64 = prefs.getString('ff_rcBackBase64') ?? '';
    });
    _safeInit(() {
      _registrationNumber = prefs.getString('ff_registrationNumber') ?? '';
    });

    _safeInit(() {
      _vehicleYear = prefs.getString('ff_vehicleYear') ?? '';
    });

    _safeInit(() {
      _vehicleImageUrl = prefs.getString('ff_vehicleImageUrl') ?? '';
    });
    _safeInit(() {
      _vehicleBase64 = prefs.getString('ff_vehicleBase64') ?? '';
    });
    _safeInit(() {
      _vehicleType = prefs.getString('ff_vehicleType') ?? '';
    });
    _safeInit(() {
      _vehicleMake = prefs.getString('ff_vehicleMake') ?? '';
    });
    _safeInit(() {
      _vehicleModel = prefs.getString('ff_vehicleModel') ?? '';
    });
    _safeInit(() {
      _vehicleColor = prefs.getString('ff_vehicleColor') ?? '';
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  int get activeRideId => _activeRideId;
  String get activeRideStatus => _activeRideStatus;

  set activeRideId(int value) {
    _activeRideId = value;
    prefs.setInt('ff_activeRideId', value);
    notifyListeners();
  }

  set activeRideStatus(String value) {
    _activeRideStatus = value;
    prefs.setString('ff_activeRideStatus', value);
    notifyListeners();
  }

  int _activeRideCount = 0;
  int get activeRideCount => _activeRideCount;

  set activeRideCount(int value) {
    _activeRideCount = value;
    notifyListeners();
  }

  int get mobileNo => _mobileNo;

  set mobileNo(int value) {
    _mobileNo = value;
    prefs.setInt('ff_mobileNo', value);
    notifyListeners();
  }

  String get firstName => _firstName;

  set firstName(String value) {
    _firstName = value;
    prefs.setString('ff_firstName', value);
    notifyListeners();
  }

  String _fcmToken = '';
  String get fcmToken => _fcmToken;
  set fcmToken(String value) {
    _fcmToken = value;
    prefs.setString('ff_fcmToken', value);
  }

  String get lastName => _lastName;

  set lastName(String value) {
    _lastName = value;
    prefs.setString('ff_lastName', value);
    notifyListeners();
  }

  String get email => _email;

  set email(String value) {
    _email = value;
    prefs.setString('ff_email', value);
    notifyListeners();
  }

  String get referralCode => _referralCode;

  set referralCode(String value) {
    _referralCode = value;
    prefs.setString('ff_referralCode', value);
    notifyListeners();
  }

  late SharedPreferences prefs;

  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    prefs.setBool('ff_isLoggedIn', value);
    notifyListeners();
  }

  bool _isRegistered = false;
  bool get isRegistered => _isRegistered;
  set isRegistered(bool value) {
    _isRegistered = value;
    prefs.setBool('ff_isRegistered', value);
    notifyListeners();
  }

  String _selectvehicle = '';
  String get selectvehicle => _selectvehicle;
  set selectvehicle(String value) {
    _selectvehicle = value;
    notifyListeners();
  }

  // ==========================================
  // DRIVING LICENSE IMAGE
  // ==========================================
  FFUploadedFile? _imageLicense;
  FFUploadedFile? get imageLicense => _imageLicense;
  set imageLicense(FFUploadedFile? value) {
    _imageLicense = value;
    notifyListeners();
  }

  // ==========================================
  // DRIVING LICENSE FRONT AND BACK IMAGES
  // ==========================================
  FFUploadedFile? _licenseFrontImage;
  FFUploadedFile? get licenseFrontImage => _licenseFrontImage;
  set licenseFrontImage(FFUploadedFile? value) {
    _licenseFrontImage = value;
    notifyListeners();
  }

  FFUploadedFile? _licenseBackImage;
  FFUploadedFile? get licenseBackImage => _licenseBackImage;
  set licenseBackImage(FFUploadedFile? value) {
    _licenseBackImage = value;
    notifyListeners();
  }

  // ==========================================
  // AADHAAR IMAGES (temporary in-memory)
  // ==========================================
  FFUploadedFile? _aadharImage;
  FFUploadedFile? get aadharImage => _aadharImage;
  set aadharImage(FFUploadedFile? value) {
    _aadharImage = value;
    notifyListeners();
  }

  FFUploadedFile? _aadharBackImage;
  FFUploadedFile? get aadharBackImage => _aadharBackImage;
  set aadharBackImage(FFUploadedFile? value) {
    _aadharBackImage = value;
    notifyListeners();
  }

  // ==========================================
  // AADHAAR FRONT AND BACK IMAGES
  // ==========================================
  FFUploadedFile? _aadhaarFrontImage;
  FFUploadedFile? get aadhaarFrontImage => _aadhaarFrontImage;
  set aadhaarFrontImage(FFUploadedFile? value) {
    _aadhaarFrontImage = value;
    notifyListeners();
  }

  FFUploadedFile? _aadhaarBackImage;
  FFUploadedFile? get aadhaarBackImage => _aadhaarBackImage;
  set aadhaarBackImage(FFUploadedFile? value) {
    _aadhaarBackImage = value;
    notifyListeners();
  }

  // ==========================================
  // RC (REGISTRATION CERTIFICATE) FRONT AND BACK IMAGES
  // ==========================================
  FFUploadedFile? _rcFrontImage;
  FFUploadedFile? get rcFrontImage => _rcFrontImage;
  set rcFrontImage(FFUploadedFile? value) {
    _rcFrontImage = value;
    notifyListeners();
  }

  FFUploadedFile? _rcBackImage;
  FFUploadedFile? get rcBackImage => _rcBackImage;
  set rcBackImage(FFUploadedFile? value) {
    _rcBackImage = value;
    notifyListeners();
  }

  // ==========================================
  // AADHAAR IMAGE URLs (persistent - from server)
  // ==========================================
  String _aadharFrontImageUrl = '';
  String get aadharFrontImageUrl => _aadharFrontImageUrl;
  set aadharFrontImageUrl(String value) {
    _aadharFrontImageUrl = value;
    if (value.isEmpty) {
      prefs.remove('ff_aadharFrontImageUrl');
    } else {
      prefs.setString('ff_aadharFrontImageUrl', value);
    }
    notifyListeners();
  }

  String _aadharBackImageUrl = '';
  String get aadharBackImageUrl => _aadharBackImageUrl;
  set aadharBackImageUrl(String value) {
    _aadharBackImageUrl = value;
    if (value.isEmpty) {
      prefs.remove('ff_aadharBackImageUrl');
    } else {
      prefs.setString('ff_aadharBackImageUrl', value);
    }
    notifyListeners();
  }

  // ==========================================
  // AADHAAR BASE64 (temporary persistence - for testing only)
  // WARNING: Not recommended for production
  // ==========================================
  String _aadharFrontBase64 = '';
  String get aadharFrontBase64 => _aadharFrontBase64;
  set aadharFrontBase64(String value) {
    _aadharFrontBase64 = value;
    if (value.isEmpty) {
      prefs.remove('ff_aadharFrontBase64');
    } else {
      prefs.setString('ff_aadharFrontBase64', value);
    }
    notifyListeners();
  }

  String _aadharBackBase64 = '';
  String get aadharBackBase64 => _aadharBackBase64;
  set aadharBackBase64(String value) {
    _aadharBackBase64 = value;
    if (value.isEmpty) {
      prefs.remove('ff_aadharBackBase64');
    } else {
      prefs.setString('ff_aadharBackBase64', value);
    }
    notifyListeners();
  }

  // ==========================================
  // AADHAAR NUMBER (persistent)
  // ==========================================
  String _aadharNumber = '';
  String get aadharNumber => _aadharNumber;
  set aadharNumber(String value) {
    _aadharNumber = value;
    if (value.isEmpty) {
      prefs.remove('ff_aadharNumber');
    } else {
      prefs.setString('ff_aadharNumber', value);
    }
    notifyListeners();
  }

// ==========================================
// PAN CARD (temporary in-memory)
// ==========================================
  FFUploadedFile? _panImage;
  FFUploadedFile? get panImage => _panImage;
  set panImage(FFUploadedFile? value) {
    _panImage = value;
    notifyListeners();
  }

// ==========================================
// PAN IMAGE URL (persistent - from server)
// ==========================================
  String _panImageUrl = '';
  String get panImageUrl => _panImageUrl;
  set panImageUrl(String value) {
    _panImageUrl = value;
    if (value.isEmpty) {
      prefs.remove('ff_panImageUrl');
    } else {
      prefs.setString('ff_panImageUrl', value);
    }
    notifyListeners();
  }

// ==========================================
// PAN BASE64 (temporary persistence)
// ==========================================
  String _panBase64 = '';
  String get panBase64 => _panBase64;
  set panBase64(String value) {
    _panBase64 = value;
    if (value.isEmpty) {
      prefs.remove('ff_panBase64');
    } else {
      prefs.setString('ff_panBase64', value);
    }
    notifyListeners();
  }

// ==========================================
// PAN NUMBER (persistent)
// ==========================================
  String _panNumber = '';
  String get panNumber => _panNumber;
  set panNumber(String value) {
    _panNumber = value;
    if (value.isEmpty) {
      prefs.remove('ff_panNumber');
    } else {
      prefs.setString('ff_panNumber', value);
    }
    notifyListeners();
  }

  // Vehicle Image
  FFUploadedFile? _vehicleImage;
  FFUploadedFile? get vehicleImage => _vehicleImage;
  set vehicleImage(FFUploadedFile? value) {
    _vehicleImage = value;
    notifyListeners();
  }

// Vehicle Image URL
  String _vehicleImageUrl = '';
  String get vehicleImageUrl => _vehicleImageUrl;
  set vehicleImageUrl(String value) {
    _vehicleImageUrl = value;
    if (value.isEmpty) {
      prefs.remove('ff_vehicleImageUrl');
    } else {
      prefs.setString('ff_vehicleImageUrl', value);
    }
    notifyListeners();
  }

// Vehicle Base64
  String _vehicleBase64 = '';
  String get vehicleBase64 => _vehicleBase64;
  set vehicleBase64(String value) {
    _vehicleBase64 = value;
    if (value.isEmpty) {
      prefs.remove('ff_vehicleBase64');
    } else {
      prefs.setString('ff_vehicleBase64', value);
    }
    notifyListeners();
  }

// Vehicle Type
  String _vehicleType = '';
  String get vehicleType => _vehicleType;
  set vehicleType(String value) {
    _vehicleType = value;
    if (value.isEmpty) {
      prefs.remove('ff_vehicleType');
    } else {
      prefs.setString('ff_vehicleType', value);
    }
    notifyListeners();
  }

// Vehicle Make
  String _vehicleMake = '';
  String get vehicleMake => _vehicleMake;
  set vehicleMake(String value) {
    _vehicleMake = value;
    if (value.isEmpty) {
      prefs.remove('ff_vehicleMake');
    } else {
      prefs.setString('ff_vehicleMake', value);
    }
    notifyListeners();
  }

// Vehicle Model
  String _vehicleModel = '';
  String get vehicleModel => _vehicleModel;
  set vehicleModel(String value) {
    _vehicleModel = value;
    if (value.isEmpty) {
      prefs.remove('ff_vehicleModel');
    } else {
      prefs.setString('ff_vehicleModel', value);
    }
    notifyListeners();
  }

// Vehicle Color
  String _vehicleColor = '';
  String get vehicleColor => _vehicleColor;
  set vehicleColor(String value) {
    _vehicleColor = value;
    if (value.isEmpty) {
      prefs.remove('ff_vehicleColor');
    } else {
      prefs.setString('ff_vehicleColor', value);
    }
    notifyListeners();
  }

// ==========================================
// PROFILE PHOTO URL (persistent - from server)
// ==========================================
  String _profilePhotoUrl = '';
  String get profilePhotoUrl => _profilePhotoUrl;
  set profilePhotoUrl(String value) {
    _profilePhotoUrl = value;
    if (value.isEmpty) {
      prefs.remove('ff_profilePhotoUrl');
    } else {
      prefs.setString('ff_profilePhotoUrl', value);
    }
    notifyListeners();
  }

// License URLs
  String _licenseFrontImageUrl = '';
  String get licenseFrontImageUrl => _licenseFrontImageUrl;
  set licenseFrontImageUrl(String value) {
    _licenseFrontImageUrl = value;
    if (value.isEmpty) {
      prefs.remove('ff_licenseFrontImageUrl');
    } else {
      prefs.setString('ff_licenseFrontImageUrl', value);
    }
    notifyListeners();
  }

  String _licenseBackImageUrl = '';
  String get licenseBackImageUrl => _licenseBackImageUrl;
  set licenseBackImageUrl(String value) {
    _licenseBackImageUrl = value;
    if (value.isEmpty) {
      prefs.remove('ff_licenseBackImageUrl');
    } else {
      prefs.setString('ff_licenseBackImageUrl', value);
    }
    notifyListeners();
  }

// License Base64
  String _licenseFrontBase64 = '';
  String get licenseFrontBase64 => _licenseFrontBase64;
  set licenseFrontBase64(String value) {
    _licenseFrontBase64 = value;
    if (value.isEmpty) {
      prefs.remove('ff_licenseFrontBase64');
    } else {
      prefs.setString('ff_licenseFrontBase64', value);
    }
    notifyListeners();
  }

  String _licenseBackBase64 = '';
  String get licenseBackBase64 => _licenseBackBase64;
  set licenseBackBase64(String value) {
    _licenseBackBase64 = value;
    if (value.isEmpty) {
      prefs.remove('ff_licenseBackBase64');
    } else {
      prefs.setString('ff_licenseBackBase64', value);
    }
    notifyListeners();
  }

// License Number
  String _licenseNumber = '';
  String get licenseNumber => _licenseNumber;
  set licenseNumber(String value) {
    _licenseNumber = value;
    if (value.isEmpty) {
      prefs.remove('ff_licenseNumber');
    } else {
      prefs.setString('ff_licenseNumber', value);
    }
    notifyListeners();
  }

// RC Front URL
  String _rcFrontImageUrl = '';
  String get rcFrontImageUrl => _rcFrontImageUrl;
  set rcFrontImageUrl(String value) {
    _rcFrontImageUrl = value;
    if (value.isEmpty) {
      prefs.remove('ff_rcFrontImageUrl');
    } else {
      prefs.setString('ff_rcFrontImageUrl', value);
    }
    notifyListeners();
  }

// RC Back URL (NEW)
  String _rcBackImageUrl = '';
  String get rcBackImageUrl => _rcBackImageUrl;
  set rcBackImageUrl(String value) {
    _rcBackImageUrl = value;
    if (value.isEmpty) {
      prefs.remove('ff_rcBackImageUrl');
    } else {
      prefs.setString('ff_rcBackImageUrl', value);
    }
    notifyListeners();
  }

// RC Front Base64
  String _rcFrontBase64 = '';
  String get rcFrontBase64 => _rcFrontBase64;
  set rcFrontBase64(String value) {
    _rcFrontBase64 = value;
    if (value.isEmpty) {
      prefs.remove('ff_rcFrontBase64');
    } else {
      prefs.setString('ff_rcFrontBase64', value);
    }
    notifyListeners();
  }

// RC Back Base64 (NEW)
  String _rcBackBase64 = '';
  String get rcBackBase64 => _rcBackBase64;
  set rcBackBase64(String value) {
    _rcBackBase64 = value;
    if (value.isEmpty) {
      prefs.remove('ff_rcBackBase64');
    } else {
      prefs.setString('ff_rcBackBase64', value);
    }
    notifyListeners();
  }

// Registration Number (existing)
  String _registrationNumber = '';
  String get registrationNumber => _registrationNumber;
  set registrationNumber(String value) {
    _registrationNumber = value;
    if (value.isEmpty) {
      prefs.remove('ff_registrationNumber');
    } else {
      prefs.setString('ff_registrationNumber', value);
    }
    notifyListeners();
  }

// Vehicle Year (NEW)
  String _vehicleYear = '';
  String get vehicleYear => _vehicleYear;
  set vehicleYear(String value) {
    _vehicleYear = value;
    if (value.isEmpty) {
      prefs.remove('ff_vehicleYear');
    } else {
      prefs.setString('ff_vehicleYear', value);
    }
    notifyListeners();
  }

// ==========================================
// PROFILE PHOTO BASE64 (temporary persistence)
// ==========================================
  String _profilePhotoBase64 = '';
  String get profilePhotoBase64 => _profilePhotoBase64;
  set profilePhotoBase64(String value) {
    _profilePhotoBase64 = value;
    if (value.isEmpty) {
      prefs.remove('ff_profilePhotoBase64');
    } else {
      prefs.setString('ff_profilePhotoBase64', value);
    }
    notifyListeners();
  }

  FFUploadedFile? _profilePhoto;
  FFUploadedFile? get profilePhoto => _profilePhoto;
  set profilePhoto(FFUploadedFile? value) {
    _profilePhoto = value;
    notifyListeners();
  }

  FFUploadedFile? _registrationImage;
  FFUploadedFile? get registrationImage => _registrationImage;
  set registrationImage(FFUploadedFile? value) {
    _registrationImage = value;
    notifyListeners();
  }

  FFUploadedFile? _insurenceImge;
  FFUploadedFile? get insurenceImge => _insurenceImge;
  set insurenceImge(FFUploadedFile? value) {
    _insurenceImge = value;
    notifyListeners();
  }

  FFUploadedFile? _pollutioncertificateImage;
  FFUploadedFile? get pollutioncertificateImage => _pollutioncertificateImage;
  set pollutioncertificateImage(FFUploadedFile? value) {
    _pollutioncertificateImage = value;
    notifyListeners();
  }

  int _driverid = 0;
  int get driverid => _driverid;

  set driverid(int value) {
    _driverid = value;
    prefs.setInt('ff_driverid', value);
  }

  bool _isonline = false;
  bool get isonline => _isonline;

  set isonline(bool value) {
    _isonline = value;
    prefs.setBool('ff_isonline', value);
    notifyListeners();
  }

  String _accessToken = '';
  String get accessToken => _accessToken;

  set accessToken(String value) {
    _accessToken = value;
    if (value.isEmpty) {
      prefs.remove('ff_accessToken');
    } else {
      prefs.setString('ff_accessToken', value);
    }
    notifyListeners();
  }

  String _kycStatus = '';
  String get kycStatus => _kycStatus;

  set kycStatus(String value) {
    final cleanValue = value.trim().toLowerCase() == 'null' ? '' : value.trim();

    _kycStatus = cleanValue;

    if (cleanValue.isEmpty) {
      prefs.remove('ff_kycStatus');
    } else {
      prefs.setString('ff_kycStatus', cleanValue);
    }

    notifyListeners();
  }

  String _qrImage = '';
  String get qrImage => _qrImage;
  set qrImage(String value) {
    _qrImage = value;
    prefs.setString('ff_qrImage', value);
    notifyListeners();
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}
