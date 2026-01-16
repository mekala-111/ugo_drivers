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


  static void reset() {
    _instance = FFAppState._internal();
  }

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
  _isLoggedIn = prefs.getBool('ff_isLoggedIn') ?? false;
});
_safeInit(() {
  _isRegistered = prefs.getBool('ff_isRegistered') ?? false;
});
 _safeInit(() {
    _driverid = prefs.getInt('ff_driverid') ?? _driverid; // 🔥 MISSING LINE
  });
  _safeInit(() {
  _isonline = prefs.getBool('ff_isonline') ?? false;
});



  }


  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }


  late SharedPreferences prefs;
  bool _isLoggedIn = false;
bool get isLoggedIn => _isLoggedIn;
set isLoggedIn(bool value) {
  _isLoggedIn = value;
  prefs.setBool('ff_isLoggedIn', value);
}
bool _isRegistered = false;
bool get isRegistered => _isRegistered;
set isRegistered(bool value) {
  _isRegistered = value;
  prefs.setBool('ff_isRegistered', value);
}



  

  String _selectvehicle = '';
  String get selectvehicle => _selectvehicle;
  set selectvehicle(String value) {
    _selectvehicle = value;
  }

   // DRIVING LICENSE IMAGE
  // --------------------------------
  FFUploadedFile? _imageLicense;
  FFUploadedFile? get imageLicense => _imageLicense;
  set imageLicense(FFUploadedFile? value) {
    _imageLicense = value;
    notifyListeners();
  }

  
  FFUploadedFile? _aadharImage;
  FFUploadedFile? get aadharImage => _aadharImage;
  set aadharImage(FFUploadedFile? value) {
    _aadharImage = value;
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

  // --------------------------------
  // INSURANCE IMAGE
  // --------------------------------
  FFUploadedFile? _insurenceImge;
  FFUploadedFile? get insurenceImge => _insurenceImge;
  set insurenceImge(FFUploadedFile? value) {
    _insurenceImge = value;
    notifyListeners();
  }

  // --------------------------------
  // POLLUTION CERTIFICATE IMAGE
  // --------------------------------
  FFUploadedFile? _pollutioncertificateImage;
  FFUploadedFile? get pollutioncertificateImage =>
      _pollutioncertificateImage;
  set pollutioncertificateImage(FFUploadedFile? value) {
    _pollutioncertificateImage = value;
    notifyListeners();
  }
  

  

  // int _driverid = 0;
  // int get driverid => _driverid;
  // set driverid(int value) {
  //   _driverid = value;
  // }
  int _driverid = 0;
int get driverid => _driverid;

set driverid(int value) {
  _driverid = value;
  prefs.setInt('ff_driverid', value); // 🔥 REQUIRED
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
  final cleanValue = value.trim().toLowerCase() == 'null'
      ? ''
      : value.trim();

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
