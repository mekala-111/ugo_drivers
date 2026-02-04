import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/flutter_flow/uploaded_file.dart';
import 'dart:convert';
import 'dart:typed_data';

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

  FFUploadedFile? _profilePhoto;
  FFUploadedFile? get profilePhoto => _profilePhoto;
  set profilePhoto(FFUploadedFile? value) {
    _profilePhoto = value;
    notifyListeners();
  }

  FFUploadedFile? _panImage;
  FFUploadedFile? get panImage => _panImage;
  set panImage(FFUploadedFile? value) {
    _panImage = value;
    notifyListeners();
  }

  FFUploadedFile? _vehicleImage;
  FFUploadedFile? get vehicleImage => _vehicleImage;
  set vehicleImage(FFUploadedFile? value) {
    _vehicleImage = value;
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
    final cleanValue =
    value.trim().toLowerCase() == 'null' ? '' : value.trim();

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

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
