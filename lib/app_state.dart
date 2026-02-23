import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/flutter_flow/uploaded_file.dart';
import '/services/secure_storage_service.dart';

class FFAppState extends ChangeNotifier {
  static final FFAppState _instance = FFAppState._internal();

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

  /// Set when user taps ride request notification (Rapido-style). HomeWidget fetches and shows.
  int pendingRideIdFromNotification = 0;
  bool _overlayBubbleEnabled = false;
  bool get overlayBubbleEnabled => _overlayBubbleEnabled;
  set overlayBubbleEnabled(bool value) {
    _overlayBubbleEnabled = value;
    prefs.setBool('ff_overlayBubbleEnabled', value);
    notifyListeners();
  }
  int _mobileNo = 0;
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _referralCode = '';
  String _usedReferralCode = '';
  int _preferredCityId = 0;
  String _preferredCityName = '';
  String _preferredEarningMode = '';

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    SecureStorageService.instance.init();
    try {
      final sec = SecureStorageService.instance;
      var token = await sec.read(SecureStorageService.keyAccessToken);
      if (token == null || token.isEmpty) {
        token = prefs.getString('ff_accessToken');
        if (token != null && token.isNotEmpty) {
          await sec.write(SecureStorageService.keyAccessToken, token);
          await prefs.remove('ff_accessToken');
        }
      }
      if (token != null && token.isNotEmpty) _accessToken = token;
    } catch (_) {}
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
      _registrationStep = prefs.getInt('ff_registrationStep') ?? _registrationStep;
    });
    _safeInit(() {
      _selectvehicle = prefs.getString('ff_selectvehicle') ?? _selectvehicle;
    });
    _safeInit(() {
      _adminVehicleId = prefs.getInt('ff_adminVehicleId') ?? _adminVehicleId;
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
      _usedReferralCode = prefs.getString('ff_usedReferralCode') ?? '';
    });
    _safeInit(() {
      _preferredCityId = prefs.getInt('ff_preferredCityId') ?? 0;
    });
    _safeInit(() {
      _preferredCityName = prefs.getString('ff_preferredCityName') ?? '';
    });
    _safeInit(() {
      _preferredEarningMode = prefs.getString('ff_preferredEarningMode') ?? '';
    });
    _safeInit(() {
      _dateOfBirth = prefs.getString('ff_dateOfBirth') ?? '';
    });
    _safeInit(() {
      _address = prefs.getString('ff_address') ?? '';
    });
    _safeInit(() {
      _city = prefs.getString('ff_city') ?? '';
    });
    _safeInit(() {
      _state = prefs.getString('ff_state') ?? '';
    });
    _safeInit(() {
      _postalCode = prefs.getString('ff_postalCode') ?? '';
    });
    _safeInit(() {
      _emergencyContactName = prefs.getString('ff_emergencyContactName') ?? '';
    });
    _safeInit(() {
      _emergencyContactPhone = prefs.getString('ff_emergencyContactPhone') ?? '';
    });
    _safeInit(() {
      _fcmToken = prefs.getString('ff_fcmToken') ?? '';
    });
    _safeInit(() {
      _overlayBubbleEnabled = prefs.getBool('ff_overlayBubbleEnabled') ?? false;
    });
    // Aadhaar/PAN: migrate from SharedPreferences then load from secure storage
    await _loadAadharPanFromSecureStorage();

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
      _licenseExpiryDate = prefs.getString('ff_licenseExpiryDate') ?? '';
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
    _safeInit(() {
      _vehicleName = prefs.getString('ff_vehicleName') ?? '';
    });
    _safeInit(() {
      _licensePlate = prefs.getString('ff_licensePlate') ?? '';
    });
    _safeInit(() {
      _registrationDate = prefs.getString('ff_registrationDate') ?? '';
    });
    _safeInit(() {
      _insuranceNumber = prefs.getString('ff_insuranceNumber') ?? '';
    });
    _safeInit(() {
      _insuranceExpiryDate = prefs.getString('ff_insuranceExpiryDate') ?? '';
    });
    _safeInit(() {
      _pollutionExpiryDate = prefs.getString('ff_pollutionExpiryDate') ?? '';
    });
    _safeInit(() {
      _insuranceBase64 = prefs.getString('ff_insuranceBase64') ?? '';
    });
    _safeInit(() {
      _pollutionBase64 = prefs.getString('ff_pollutionBase64') ?? '';
    });
  }

  Future<void> _loadAadharPanFromSecureStorage() async {
    final sec = SecureStorageService.instance;
    try {
      var v = await sec.read(SecureStorageService.keyAadharNumber);
      if (v == null || v.isEmpty) {
        final fromPrefs = prefs.getString('ff_aadharNumber');
        if (fromPrefs != null && fromPrefs.isNotEmpty) {
          await sec.write(SecureStorageService.keyAadharNumber, fromPrefs);
          await prefs.remove('ff_aadharNumber');
        }
        v = fromPrefs ?? '';
      }
      _aadharNumber = v;
    } catch (_) {}
    try {
      var v = await sec.read(SecureStorageService.keyAadharFrontImageUrl);
      if (v == null || v.isEmpty) {
        final fromPrefs = prefs.getString('ff_aadharFrontImageUrl');
        if (fromPrefs != null && fromPrefs.isNotEmpty) {
          await sec.write(SecureStorageService.keyAadharFrontImageUrl, fromPrefs);
          await prefs.remove('ff_aadharFrontImageUrl');
          v = fromPrefs;
        } else {
          v = '';
        }
      }
      _aadharFrontImageUrl = v;
    } catch (_) {}
    try {
      var v = await sec.read(SecureStorageService.keyAadharBackImageUrl);
      if (v == null || v.isEmpty) {
        final fromPrefs = prefs.getString('ff_aadharBackImageUrl');
        if (fromPrefs != null && fromPrefs.isNotEmpty) {
          await sec.write(SecureStorageService.keyAadharBackImageUrl, fromPrefs);
          await prefs.remove('ff_aadharBackImageUrl');
        }
        v = fromPrefs ?? '';
      }
      _aadharBackImageUrl = v;
    } catch (_) {}
    try {
      var v = await sec.read(SecureStorageService.keyAadharFrontBase64);
      if (v == null || v.isEmpty) {
        final fromPrefs = prefs.getString('ff_aadharFrontBase64');
        if (fromPrefs != null && fromPrefs.isNotEmpty) {
          await sec.write(SecureStorageService.keyAadharFrontBase64, fromPrefs);
          await prefs.remove('ff_aadharFrontBase64');
        }
        v = fromPrefs ?? '';
      }
      _aadharFrontBase64 = v;
    } catch (_) {}
    try {
      var v = await sec.read(SecureStorageService.keyAadharBackBase64);
      if (v == null || v.isEmpty) {
        final fromPrefs = prefs.getString('ff_aadharBackBase64');
        if (fromPrefs != null && fromPrefs.isNotEmpty) {
          await sec.write(SecureStorageService.keyAadharBackBase64, fromPrefs);
          await prefs.remove('ff_aadharBackBase64');
        }
        v = fromPrefs ?? '';
      }
      _aadharBackBase64 = v;
    } catch (_) {}
    try {
      var v = await sec.read(SecureStorageService.keyPanImageUrl);
      if (v == null || v.isEmpty) {
        final fromPrefs = prefs.getString('ff_panImageUrl');
        if (fromPrefs != null && fromPrefs.isNotEmpty) {
          await sec.write(SecureStorageService.keyPanImageUrl, fromPrefs);
          await prefs.remove('ff_panImageUrl');
        }
        v = fromPrefs ?? '';
      }
      _panImageUrl = v;
    } catch (_) {}
    try {
      var v = await sec.read(SecureStorageService.keyPanBase64);
      if (v == null || v.isEmpty) {
        final fromPrefs = prefs.getString('ff_panBase64');
        if (fromPrefs != null && fromPrefs.isNotEmpty) {
          await sec.write(SecureStorageService.keyPanBase64, fromPrefs);
          await prefs.remove('ff_panBase64');
        }
        v = fromPrefs ?? '';
      }
      _panBase64 = v;
    } catch (_) {}
    try {
      var v = await sec.read(SecureStorageService.keyPanNumber);
      if (v == null || v.isEmpty) {
        final fromPrefs = prefs.getString('ff_panNumber');
        if (fromPrefs != null && fromPrefs.isNotEmpty) {
          await sec.write(SecureStorageService.keyPanNumber, fromPrefs);
          await prefs.remove('ff_panNumber');
        }
        v = fromPrefs ?? '';
      }
      _panNumber = v;
    } catch (_) {}
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

  String get usedReferralCode => _usedReferralCode;
  set usedReferralCode(String value) {
    _usedReferralCode = value;
    if (value.isEmpty) {
      prefs.remove('ff_usedReferralCode');
    } else {
      prefs.setString('ff_usedReferralCode', value);
    }
    notifyListeners();
  }

  int get preferredCityId => _preferredCityId;
  set preferredCityId(int value) {
    _preferredCityId = value;
    if (value <= 0) {
      prefs.remove('ff_preferredCityId');
    } else {
      prefs.setInt('ff_preferredCityId', value);
    }
    notifyListeners();
  }

  String get preferredCityName => _preferredCityName;
  set preferredCityName(String value) {
    _preferredCityName = value;
    if (value.isEmpty) {
      prefs.remove('ff_preferredCityName');
    } else {
      prefs.setString('ff_preferredCityName', value);
    }
    notifyListeners();
  }

  String get preferredEarningMode => _preferredEarningMode;
  set preferredEarningMode(String value) {
    _preferredEarningMode = value;
    if (value.isEmpty) {
      prefs.remove('ff_preferredEarningMode');
    } else {
      prefs.setString('ff_preferredEarningMode', value);
    }
    notifyListeners();
  }

  /// Date of birth (YYYY-MM-DD)
  String _dateOfBirth = '';
  String get dateOfBirth => _dateOfBirth;
  set dateOfBirth(String value) {
    _dateOfBirth = value;
    if (value.isEmpty) {
      prefs.remove('ff_dateOfBirth');
    } else {
      prefs.setString('ff_dateOfBirth', value);
    }
    notifyListeners();
  }

  String _address = '';
  String get address => _address;
  set address(String value) {
    _address = value;
    if (value.isEmpty) {
      prefs.remove('ff_address');
    } else {
      prefs.setString('ff_address', value);
    }
    notifyListeners();
  }

  String _city = '';
  String get city => _city;
  set city(String value) {
    _city = value;
    if (value.isEmpty) {
      prefs.remove('ff_city');
    } else {
      prefs.setString('ff_city', value);
    }
    notifyListeners();
  }

  String _state = '';
  String get state => _state;
  set state(String value) {
    _state = value;
    if (value.isEmpty) {
      prefs.remove('ff_state');
    } else {
      prefs.setString('ff_state', value);
    }
    notifyListeners();
  }

  String _postalCode = '';
  String get postalCode => _postalCode;
  set postalCode(String value) {
    _postalCode = value;
    if (value.isEmpty) {
      prefs.remove('ff_postalCode');
    } else {
      prefs.setString('ff_postalCode', value);
    }
    notifyListeners();
  }

  String _emergencyContactName = '';
  String get emergencyContactName => _emergencyContactName;
  set emergencyContactName(String value) {
    _emergencyContactName = value;
    if (value.isEmpty) {
      prefs.remove('ff_emergencyContactName');
    } else {
      prefs.setString('ff_emergencyContactName', value);
    }
    notifyListeners();
  }

  String _emergencyContactPhone = '';
  String get emergencyContactPhone => _emergencyContactPhone;
  set emergencyContactPhone(String value) {
    _emergencyContactPhone = value;
    if (value.isEmpty) {
      prefs.remove('ff_emergencyContactPhone');
    } else {
      prefs.setString('ff_emergencyContactPhone', value);
    }
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

  /// Registration step tracking for resume functionality:
  /// 0: No registration started
  /// 1: FirstDetails completed
  /// 2: AddressDetails completed
  /// 3: ChooseVehicle completed
  /// 4: OnBoarding (final step)
  int _registrationStep = 0;
  int get registrationStep => _registrationStep;
  set registrationStep(int value) {
    _registrationStep = value;
    prefs.setInt('ff_registrationStep', value);
    notifyListeners();
  }

  String _selectvehicle = '';
  String get selectvehicle => _selectvehicle;
  set selectvehicle(String value) {
    _selectvehicle = value;
    if (value.isEmpty) {
      prefs.remove('ff_selectvehicle');
    } else {
      prefs.setString('ff_selectvehicle', value);
    }
    notifyListeners();
  }

  /// Admin vehicle ID from API (used for signup-with-vehicle)
  int _adminVehicleId = 0;
  int get adminVehicleId => _adminVehicleId;
  set adminVehicleId(int value) {
    _adminVehicleId = value;
    if (value == 0) {
      prefs.remove('ff_adminVehicleId');
    } else {
      prefs.setInt('ff_adminVehicleId', value);
    }
    notifyListeners();
  }

  /// Created vehicle record ID from signup response (data.vehicle.id)
  int _vehicleId = 0;
  int get vehicleId => _vehicleId;
  set vehicleId(int value) {
    _vehicleId = value;
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

  // AADHAAR IMAGE URLs - stored in secure storage
  String _aadharFrontImageUrl = '';
  String get aadharFrontImageUrl => _aadharFrontImageUrl;
  set aadharFrontImageUrl(String value) {
    _aadharFrontImageUrl = value;
    SecureStorageService.instance.write(SecureStorageService.keyAadharFrontImageUrl, value);
    notifyListeners();
  }

  String _aadharBackImageUrl = '';
  String get aadharBackImageUrl => _aadharBackImageUrl;
  set aadharBackImageUrl(String value) {
    _aadharBackImageUrl = value;
    SecureStorageService.instance.write(SecureStorageService.keyAadharBackImageUrl, value);
    notifyListeners();
  }

  // AADHAAR BASE64 - stored in secure storage
  String _aadharFrontBase64 = '';
  String get aadharFrontBase64 => _aadharFrontBase64;
  set aadharFrontBase64(String value) {
    _aadharFrontBase64 = value;
    SecureStorageService.instance.write(SecureStorageService.keyAadharFrontBase64, value);
    notifyListeners();
  }

  String _aadharBackBase64 = '';
  String get aadharBackBase64 => _aadharBackBase64;
  set aadharBackBase64(String value) {
    _aadharBackBase64 = value;
    SecureStorageService.instance.write(SecureStorageService.keyAadharBackBase64, value);
    notifyListeners();
  }

  // AADHAAR NUMBER - stored in secure storage
  String _aadharNumber = '';
  String get aadharNumber => _aadharNumber;
  set aadharNumber(String value) {
    _aadharNumber = value;
    SecureStorageService.instance.write(SecureStorageService.keyAadharNumber, value);
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

// PAN IMAGE URL - stored in secure storage
  String _panImageUrl = '';
  String get panImageUrl => _panImageUrl;
  set panImageUrl(String value) {
    _panImageUrl = value;
    SecureStorageService.instance.write(SecureStorageService.keyPanImageUrl, value);
    notifyListeners();
  }

// PAN BASE64 - stored in secure storage
  String _panBase64 = '';
  String get panBase64 => _panBase64;
  set panBase64(String value) {
    _panBase64 = value;
    SecureStorageService.instance.write(SecureStorageService.keyPanBase64, value);
    notifyListeners();
  }

// PAN NUMBER - stored in secure storage
  String _panNumber = '';
  String get panNumber => _panNumber;
  set panNumber(String value) {
    _panNumber = value;
    SecureStorageService.instance.write(SecureStorageService.keyPanNumber, value);
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

// License Expiry Date (YYYY-MM-DD or DD/MM/YYYY)
  String _licenseExpiryDate = '';
  String get licenseExpiryDate => _licenseExpiryDate;
  set licenseExpiryDate(String value) {
    _licenseExpiryDate = value;
    if (value.isEmpty) {
      prefs.remove('ff_licenseExpiryDate');
    } else {
      prefs.setString('ff_licenseExpiryDate', value);
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

// Vehicle Year
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

// Vehicle Name (vehicles.vehicle_name)
  String _vehicleName = '';
  String get vehicleName => _vehicleName;
  set vehicleName(String value) {
    _vehicleName = value;
    if (value.isEmpty) {
      prefs.remove('ff_vehicleName');
    } else {
      prefs.setString('ff_vehicleName', value);
    }
    notifyListeners();
  }

// License Plate (vehicles.license_plate)
  String _licensePlate = '';
  String get licensePlate => _licensePlate;
  set licensePlate(String value) {
    _licensePlate = value;
    if (value.isEmpty) {
      prefs.remove('ff_licensePlate');
    } else {
      prefs.setString('ff_licensePlate', value);
    }
    notifyListeners();
  }

// Registration Date (vehicles.registration_date)
  String _registrationDate = '';
  String get registrationDate => _registrationDate;
  set registrationDate(String value) {
    _registrationDate = value;
    if (value.isEmpty) {
      prefs.remove('ff_registrationDate');
    } else {
      prefs.setString('ff_registrationDate', value);
    }
    notifyListeners();
  }

// Insurance Number (vehicles.insurance_number)
  String _insuranceNumber = '';
  String get insuranceNumber => _insuranceNumber;
  set insuranceNumber(String value) {
    _insuranceNumber = value;
    if (value.isEmpty) {
      prefs.remove('ff_insuranceNumber');
    } else {
      prefs.setString('ff_insuranceNumber', value);
    }
    notifyListeners();
  }

// Insurance Expiry Date (vehicles.insurance_expiry_date)
  String _insuranceExpiryDate = '';
  String get insuranceExpiryDate => _insuranceExpiryDate;
  set insuranceExpiryDate(String value) {
    _insuranceExpiryDate = value;
    if (value.isEmpty) {
      prefs.remove('ff_insuranceExpiryDate');
    } else {
      prefs.setString('ff_insuranceExpiryDate', value);
    }
    notifyListeners();
  }

// Pollution Expiry Date (vehicles.pollution_expiry_date)
  String _pollutionExpiryDate = '';
  String get pollutionExpiryDate => _pollutionExpiryDate;
  set pollutionExpiryDate(String value) {
    _pollutionExpiryDate = value;
    if (value.isEmpty) {
      prefs.remove('ff_pollutionExpiryDate');
    } else {
      prefs.setString('ff_pollutionExpiryDate', value);
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

  FFUploadedFile? _insuranceImage;
  FFUploadedFile? get insuranceImage => _insuranceImage;
  set insuranceImage(FFUploadedFile? value) {
    _insuranceImage = value;
    notifyListeners();
  }

  FFUploadedFile? _insurancePdf;
  FFUploadedFile? get insurancePdf => _insurancePdf;
  set insurancePdf(FFUploadedFile? value) {
    _insurancePdf = value;
    notifyListeners();
  }

  String _insuranceBase64 = '';
  String get insuranceBase64 => _insuranceBase64;
  set insuranceBase64(String value) {
    _insuranceBase64 = value;
    if (value.isEmpty) {
      prefs.remove('ff_insuranceBase64');
    } else {
      prefs.setString('ff_insuranceBase64', value);
    }
    notifyListeners();
  }

  FFUploadedFile? _pollutioncertificateImage;
  FFUploadedFile? get pollutioncertificateImage => _pollutioncertificateImage;
  set pollutioncertificateImage(FFUploadedFile? value) {
    _pollutioncertificateImage = value;
    notifyListeners();
  }

  FFUploadedFile? get pollutionImage => _pollutioncertificateImage;
  set pollutionImage(FFUploadedFile? value) {
    _pollutioncertificateImage = value;
    notifyListeners();
  }

  String _pollutionBase64 = '';
  String get pollutionBase64 => _pollutionBase64;
  set pollutionBase64(String value) {
    _pollutionBase64 = value;
    if (value.isEmpty) {
      prefs.remove('ff_pollutionBase64');
    } else {
      prefs.setString('ff_pollutionBase64', value);
    }
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
    final sec = SecureStorageService.instance;
    if (value.isEmpty) {
      sec.delete(SecureStorageService.keyAccessToken);
    } else {
      sec.write(SecureStorageService.keyAccessToken, value);
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
  
  Future<void> clearAppState() async {
  await prefs.clear();

  // Auth
  _accessToken = '';
  _driverid = 0;
  _isLoggedIn = false;
  _isRegistered = false;
  _registrationStep = 0;
  _selectvehicle = '';
  _adminVehicleId = 0;

  // Basic info
  _mobileNo = 0;
  _firstName = '';
  _lastName = '';
  _email = '';
  _referralCode = '';
  _usedReferralCode = '';
  _preferredCityId = 0;
  _preferredCityName = '';
  _preferredEarningMode = '';

  // Ride
  _activeRideId = 0;
  _activeRideStatus = '';
  _kycStatus = '';
  _isonline = false;

  // 🔥 Profile
  _profilePhotoUrl = '';
  _profilePhotoBase64 = '';
  _profilePhoto = null;

  // 🔥 PAN
  _panImageUrl = '';
  _panBase64 = '';
  _panNumber = '';
  _panImage = null;

  // 🔥 Aadhar
  _aadharFrontImageUrl = '';
  _aadharBackImageUrl = '';
  _aadharFrontBase64 = '';
  _aadharBackBase64 = '';
  _aadharNumber = '';
  _aadharBackImage = null;

  // Clear secure storage for JWT, Aadhaar/PAN
  final sec = SecureStorageService.instance;
  await sec.delete(SecureStorageService.keyAccessToken);
  await sec.delete(SecureStorageService.keyAadharNumber);
  await sec.delete(SecureStorageService.keyAadharFrontImageUrl);
  await sec.delete(SecureStorageService.keyAadharBackImageUrl);
  await sec.delete(SecureStorageService.keyAadharFrontBase64);
  await sec.delete(SecureStorageService.keyAadharBackBase64);
  await sec.delete(SecureStorageService.keyPanImageUrl);
  await sec.delete(SecureStorageService.keyPanBase64);
  await sec.delete(SecureStorageService.keyPanNumber);

  // 🔥 License
  _licenseFrontImageUrl = '';
  _licenseBackImageUrl = '';
  _licenseFrontBase64 = '';
  _licenseBackBase64 = '';
  _licenseFrontImage = null;
  _licenseBackImage = null;

  // 🔥 Vehicle / RC
  _vehicleImageUrl = '';
  _vehicleImage = null;
  _vehicleName = '';
  _licensePlate = '';
  _registrationDate = '';
  _insuranceNumber = '';
  _insuranceExpiryDate = '';
  _pollutionExpiryDate = '';
  _overlayBubbleEnabled = false;

  _rcFrontImageUrl = '';
  _rcBackImageUrl = '';
  _rcFrontBase64 = '';
  _rcBackBase64 = '';
  _rcFrontImage = null;
  _rcBackImage = null;
  _insuranceBase64 = '';
  _insurancePdf = null;
  _pollutionBase64 = '';

  // Reset registration step
  _registrationStep = 0;

  notifyListeners();
}


}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}