import 'package:ugo_driver/account_support/documents.dart';
import 'package:ugo_driver/account_support/editg_address.dart';
import 'package:ugo_driver/app_settings/app_setting_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_requests/api_calls.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'account_support_model.dart';
export 'account_support_model.dart';

class AccountSupportWidget extends StatefulWidget {
  const AccountSupportWidget({super.key});

  static String routeName = 'Account_support';
  static String routePath = '/accountSupport';

  @override
  State<AccountSupportWidget> createState() => _AccountSupportWidgetState();
}

class _AccountSupportWidgetState extends State<AccountSupportWidget> {
  late AccountSupportModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  Map<String, dynamic>? driverData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AccountSupportModel());
    fetchDriverDetails();
  }
  String getFullImageUrl(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) {
    return '';
  }
  
  // If the path already contains http/https, return as is
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return imagePath;
  }
  
  // Base URL for your API
  const String baseUrl = 'https://ugotaxi.icacorp.org';
  
  // Remove 'uploads/' prefix if it exists, as it's not in the working URL
  String cleanPath = imagePath;
  if (imagePath.startsWith('uploads/')) {
    cleanPath = imagePath.substring('uploads/'.length);
  }
  
  // Construct full URL
  return '$baseUrl/$cleanPath';
}

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> fetchDriverDetails() async {
    setState(() => isLoading = true);
    
    try {
      final response = await DriverIdfetchCall.call(
        token: FFAppState().accessToken,
        id: FFAppState().driverid,
      );

      if (response.succeeded) {
        setState(() {
          driverData = DriverIdfetchCall.driverData(response.jsonBody);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String getFullAddress() {
    if (driverData == null) return 'No address available';
    
    final address = driverData!['address'] ?? '';
    final city = driverData!['city'] ?? '';
    final state = driverData!['state'] ?? '';
    final postalCode = driverData!['postal_code'] ?? '';
    
    List<String> parts = [];
    if (address.isNotEmpty) parts.add(address);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (postalCode.isNotEmpty) parts.add(postalCode);
    
    return parts.isEmpty ? 'No address available' : parts.join(', ');
  }

  String getDriverName() {
    if (driverData == null) return 'Driver Name';
    
    final firstName = driverData!['first_name'] ?? '';
    final lastName = driverData!['last_name'] ?? '';
    
    return '${firstName} ${lastName}'.trim().isEmpty 
        ? 'Driver Name' 
        : '${firstName} ${lastName}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            FFLocalizations.of(context).getText(
              'ysdtmrd0' /* Account */,
            ),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.w500,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Colors.white,
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: fetchDriverDetails,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Profile Header with Image and Name
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 25.0, 0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(-1.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      30.0, 0.0, 0.0, 0.0),
                                  child: Container(
                                    width: 70.0,
                                    height: 70.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context).primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(35.0),
                                      child: driverData?['profile_image'] != null &&
                                              driverData!['profile_image']
                                                  .toString()
                                                  .isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: getFullImageUrl(driverData!['profile_image']),
                                              width: 70.0,
                                              height: 70.0,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                              errorWidget: (context, url, error) =>
                                                  Container(
                                                color: Colors.grey[300],
                                                child: Icon(
                                                  Icons.person,
                                                  size: 35,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            )
                                          : Container(
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.person,
                                                size: 35,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      25.0, 1.0, 15.0, 15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        getDriverName(),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FlutterFlowTheme.of(context)
                                                    .bodyLarge
                                                    .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FlutterFlowTheme.of(context)
                                                  .bodyLarge
                                                  .fontStyle,
                                            ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        driverData?['mobile_number'] ?? '',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              font: GoogleFonts.inter(),
                                              color: Colors.grey[600],
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Address Display Section
                        if (driverData != null)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                30.0, 15.0, 30.0, 0.0),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Color(0xFFF0F8FF),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 18.0,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Current Address',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  // Text(
                                  //   getFullAddress(),
                                  //   style: TextStyle(
                                  //     fontSize: 11,
                                  //     color: Colors.grey[700],
                                  //     height: 1.4,
                                  //   ),
                                  // ),
                                  if (driverData!['current_location_latitude'] != null &&
                                      driverData!['current_location_longitude'] != null) ...[
                                    SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.gps_fixed,
                                              size: 12, color: Colors.blue),
                                          SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              'Lat: ${driverData!['current_location_latitude']}, Long: ${driverData!['current_location_longitude']}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.blue[900],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                        // Menu Items
                        Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(18.0, 25.0, 10.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  // context.pushNamed(InboxPageWidget.routeName);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DocumentsScreen(
                                         
                                        ),
                                      ),
                                    );
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF9F9F9),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 16.0, 0.0, 16.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              Icons.edit_document,
                                              color: Colors.black,
                                              size: 24.0,
                                            ),
                                            Text(
                                              FFLocalizations.of(context).getText(
                                                '9bn2wxvo' /* Documents */,
                                              ),
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: Colors.black,
                                                    fontSize: 12.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 16.0)),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.black,
                                          size: 20.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                thickness: 2.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  // context.pushNamed(InboxPageWidget.routeName);
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF9F9F9),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 16.0, 0.0, 16.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              Icons.payment_outlined,
                                              color: Colors.black,
                                              size: 24.0,
                                            ),
                                            Text(
                                              FFLocalizations.of(context).getText(
                                                '34o7vjtz' /* Payment */,
                                              ),
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: Colors.black,
                                                    fontSize: 12.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 16.0)),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.black,
                                          size: 20.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                thickness: 2.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  if (driverData != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditAddressScreen(
                                          driverData: driverData!,
                                          onUpdate: () {
                                            fetchDriverDetails();
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF9F9F9),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 16.0, 0.0, 16.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              Icons.edit_calendar,
                                              color: Colors.black,
                                              size: 24.0,
                                            ),
                                            Text(
                                              FFLocalizations.of(context).getText(
                                                'd1egk9by' /* Edit Address */,
                                              ),
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: Colors.black,
                                                    fontSize: 12.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 16.0)),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.black,
                                          size: 20.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                thickness: 2.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  // context.pushNamed(InboxPageWidget.routeName);
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF9F9F9),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 16.0, 0.0, 16.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              Icons.draw_outlined,
                                              color: Colors.black,
                                              size: 24.0,
                                            ),
                                            Text(
                                              FFLocalizations.of(context).getText(
                                                'huk3perd' /* About */,
                                              ),
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: Colors.black,
                                                    fontSize: 12.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 16.0)),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.black,
                                          size: 20.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                thickness: 2.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  // context.pushNamed(InboxPageWidget.routeName);
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF9F9F9),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 16.0, 0.0, 16.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            FaIcon(
                                              FontAwesomeIcons.userSecret,
                                              color: Colors.black,
                                              size: 24.0,
                                            ),
                                            Text(
                                              FFLocalizations.of(context).getText(
                                                '1gepgp40' /* Security */,
                                              ),
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: Colors.black,
                                                    fontSize: 12.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 16.0)),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.black,
                                          size: 20.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                thickness: 2.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AppSettingsWidget(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF9F9F9),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 16.0, 0.0, 16.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              Icons.app_settings_alt_outlined,
                                              color: Colors.black,
                                              size: 24.0,
                                            ),
                                            Text(
                                              FFLocalizations.of(context).getText(
                                                'glh63usn' /* App Settings */,
                                              ),
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: Colors.black,
                                                    fontSize: 12.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 16.0)),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.black,
                                          size: 20.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

// import 'package:ugo_driver/app_settings/app_setting_widget.dart';

// import '/flutter_flow/flutter_flow_icon_button.dart';
// import '/flutter_flow/flutter_flow_theme.dart';
// import '/flutter_flow/flutter_flow_util.dart';
// import '/index.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'account_support_model.dart';
// export 'account_support_model.dart';


// class AccountSupportWidget extends StatefulWidget {
//   const AccountSupportWidget({super.key});

//   static String routeName = 'Account_support';
//   static String routePath = '/accountSupport';

//   @override
//   State<AccountSupportWidget> createState() => _AccountSupportWidgetState();
// }

// class _AccountSupportWidgetState extends State<AccountSupportWidget> {
//   late AccountSupportModel _model;

//   final scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   void initState() {
//     super.initState();
//     _model = createModel(context, () => AccountSupportModel());
//   }

//   @override
//   void dispose() {
//     _model.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).unfocus();
//         FocusManager.instance.primaryFocus?.unfocus();
//       },
//       child: Scaffold(
//         key: scaffoldKey,
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: FlutterFlowTheme.of(context).primary,
//           automaticallyImplyLeading: false,
//           leading: FlutterFlowIconButton(
//             borderColor: Colors.transparent,
//             borderRadius: 30.0,
//             borderWidth: 1.0,
//             buttonSize: 60.0,
//             icon: Icon(
//               Icons.arrow_back_rounded,
//               color: Colors.white,
//               size: 30.0,
//             ),
//             onPressed: () async {
//               context.pop();
//             },
//           ),
//           title: Text(
//             FFLocalizations.of(context).getText(
//               'ysdtmrd0' /* Account */,
//             ),
//             style: FlutterFlowTheme.of(context).headlineMedium.override(
//                   font: GoogleFonts.interTight(
//                     fontWeight: FontWeight.w500,
//                     fontStyle:
//                         FlutterFlowTheme.of(context).headlineMedium.fontStyle,
//                   ),
//                   color: Colors.white,
//                   fontSize: 18.0,
//                   letterSpacing: 0.0,
//                   fontWeight: FontWeight.w500,
//                   fontStyle:
//                       FlutterFlowTheme.of(context).headlineMedium.fontStyle,
//                 ),
//           ),
//           actions: [],
//           centerTitle: true,
//           elevation: 2.0,
//         ),
//         body: SafeArea(
//           top: true,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 Padding(
//                   padding: EdgeInsetsDirectional.fromSTEB(0.0, 25.0, 0.0, 0.0),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.max,
//                     children: [
//                       Align(
//                         alignment: AlignmentDirectional(-1.0, 0.0),
//                         child: Padding(
//                           padding:
//                               EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 0.0, 0.0),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(30.0),
//                             child: Image.network(
//                               'https://picsum.photos/seed/839/600',
//                               width: 70.0,
//                               height: 70.0,
//                               fit: BoxFit.fill,
//                               alignment: Alignment(-1.0, 0.0),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding:
//                             EdgeInsetsDirectional.fromSTEB(25.0, 1.0, 0.0, 15.0),
//                         child: Text(
//                           FFLocalizations.of(context).getText(
//                             'auf6ztu7' /* Go code Designers */,
//                           ),
//                           style: FlutterFlowTheme.of(context).bodyLarge.override(
//                                 font: GoogleFonts.inter(
//                                   fontWeight: FontWeight.bold,
//                                   fontStyle: FlutterFlowTheme.of(context)
//                                       .bodyLarge
//                                       .fontStyle,
//                                 ),
//                                 letterSpacing: 0.0,
//                                 fontWeight: FontWeight.bold,
//                                 fontStyle: FlutterFlowTheme.of(context)
//                                     .bodyLarge
//                                     .fontStyle,
//                               ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsetsDirectional.fromSTEB(18.0, 35.0, 10.0, 0.0),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.max,
//                     children: [
//                       InkWell(
//                         splashColor: Colors.transparent,
//                         focusColor: Colors.transparent,
//                         hoverColor: Colors.transparent,
//                         highlightColor: Colors.transparent,
//                         onTap: () async {
//                           // context.pushNamed(InboxPageWidget.routeName);
//                         },
//                         child: Container(
//                           width: double.infinity,
//                           height: 50.0,
//                           decoration: BoxDecoration(
//                             color: Color(0xFFF9F9F9),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsetsDirectional.fromSTEB(
//                                 0.0, 16.0, 0.0, 16.0),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.max,
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Row(
//                                   mainAxisSize: MainAxisSize.max,
//                                   children: [
//                                     Icon(
//                                       Icons.edit_document,
//                                       color: Colors.black,
//                                       size: 24.0,
//                                     ),
//                                     Text(
//                                       FFLocalizations.of(context).getText(
//                                         '9bn2wxvo' /* Documents */,
//                                       ),
//                                       style: FlutterFlowTheme.of(context)
//                                           .bodyMedium
//                                           .override(
//                                             font: GoogleFonts.inter(
//                                               fontWeight: FontWeight.w500,
//                                               fontStyle:
//                                                   FlutterFlowTheme.of(context)
//                                                       .bodyMedium
//                                                       .fontStyle,
//                                             ),
//                                             color: Colors.black,
//                                             fontSize: 12.0,
//                                             letterSpacing: 0.0,
//                                             fontWeight: FontWeight.w500,
//                                             fontStyle:
//                                                 FlutterFlowTheme.of(context)
//                                                     .bodyMedium
//                                                     .fontStyle,
//                                           ),
//                                     ),
//                                   ].divide(SizedBox(width: 16.0)),
//                                 ),
//                                 Icon(
//                                   Icons.chevron_right,
//                                   color: Colors.black,
//                                   size: 20.0,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       Divider(
//                         thickness: 2.0,
//                         color: FlutterFlowTheme.of(context).alternate,
//                       ),
//                       InkWell(
//                         splashColor: Colors.transparent,
//                         focusColor: Colors.transparent,
//                         hoverColor: Colors.transparent,
//                         highlightColor: Colors.transparent,
//                         onTap: () async {
//                           // context.pushNamed(InboxPageWidget.routeName);
//                         },
//                         child: Container(
//                           width: double.infinity,
//                           height: 50.0,
//                           decoration: BoxDecoration(
//                             color: Color(0xFFF9F9F9),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsetsDirectional.fromSTEB(
//                                 0.0, 16.0, 0.0, 16.0),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.max,
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Row(
//                                   mainAxisSize: MainAxisSize.max,
//                                   children: [
//                                     Icon(
//                                       Icons.payment_outlined,
//                                       color: Colors.black,
//                                       size: 24.0,
//                                     ),
//                                     Text(
//                                       FFLocalizations.of(context).getText(
//                                         '34o7vjtz' /* Payment */,
//                                       ),
//                                       style: FlutterFlowTheme.of(context)
//                                           .bodyMedium
//                                           .override(
//                                             font: GoogleFonts.inter(
//                                               fontWeight: FontWeight.w500,
//                                               fontStyle:
//                                                   FlutterFlowTheme.of(context)
//                                                       .bodyMedium
//                                                       .fontStyle,
//                                             ),
//                                             color: Colors.black,
//                                             fontSize: 12.0,
//                                             letterSpacing: 0.0,
//                                             fontWeight: FontWeight.w500,
//                                             fontStyle:
//                                                 FlutterFlowTheme.of(context)
//                                                     .bodyMedium
//                                                     .fontStyle,
//                                           ),
//                                     ),
//                                   ].divide(SizedBox(width: 16.0)),
//                                 ),
//                                 Icon(
//                                   Icons.chevron_right,
//                                   color: Colors.black,
//                                   size: 20.0,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       Divider(
//                         thickness: 2.0,
//                         color: FlutterFlowTheme.of(context).alternate,
//                       ),
                     
//                       InkWell(
//                         splashColor: Colors.transparent,
//                         focusColor: Colors.transparent,
//                         hoverColor: Colors.transparent,
//                         highlightColor: Colors.transparent,
//                         onTap: () async {
//                           // context.pushNamed(InboxPageWidget.routeName);
//                         },
//                         child: Container(
//                           width: double.infinity,
//                           height: 50.0,
//                           decoration: BoxDecoration(
//                             color: Color(0xFFF9F9F9),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsetsDirectional.fromSTEB(
//                                 0.0, 16.0, 0.0, 16.0),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.max,
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Row(
//                                   mainAxisSize: MainAxisSize.max,
//                                   children: [
//                                     Icon(
//                                       Icons.edit_calendar,
//                                       color: Colors.black,
//                                       size: 24.0,
//                                     ),
//                                     Text(
//                                       FFLocalizations.of(context).getText(
//                                         'd1egk9by' /* Edit Address */,
//                                       ),
//                                       style: FlutterFlowTheme.of(context)
//                                           .bodyMedium
//                                           .override(
//                                             font: GoogleFonts.inter(
//                                               fontWeight: FontWeight.w500,
//                                               fontStyle:
//                                                   FlutterFlowTheme.of(context)
//                                                       .bodyMedium
//                                                       .fontStyle,
//                                             ),
//                                             color: Colors.black,
//                                             fontSize: 12.0,
//                                             letterSpacing: 0.0,
//                                             fontWeight: FontWeight.w500,
//                                             fontStyle:
//                                                 FlutterFlowTheme.of(context)
//                                                     .bodyMedium
//                                                     .fontStyle,
//                                           ),
//                                     ),
//                                   ].divide(SizedBox(width: 16.0)),
//                                 ),
//                                 Icon(
//                                   Icons.chevron_right,
//                                   color: Colors.black,
//                                   size: 20.0,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       Divider(
//                         thickness: 2.0,
//                         color: FlutterFlowTheme.of(context).alternate,
//                       ),
//                       InkWell(
//                         splashColor: Colors.transparent,
//                         focusColor: Colors.transparent,
//                         hoverColor: Colors.transparent,
//                         highlightColor: Colors.transparent,
//                         onTap: () async {
//                           // context.pushNamed(InboxPageWidget.routeName);
//                         },
//                         child: Container(
//                           width: double.infinity,
//                           height: 50.0,
//                           decoration: BoxDecoration(
//                             color: Color(0xFFF9F9F9),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsetsDirectional.fromSTEB(
//                                 0.0, 16.0, 0.0, 16.0),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.max,
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Row(
//                                   mainAxisSize: MainAxisSize.max,
//                                   children: [
//                                     Icon(
//                                       Icons.draw_outlined,
//                                       color: Colors.black,
//                                       size: 24.0,
//                                     ),
//                                     Text(
//                                       FFLocalizations.of(context).getText(
//                                         'huk3perd' /* About */,
//                                       ),
//                                       style: FlutterFlowTheme.of(context)
//                                           .bodyMedium
//                                           .override(
//                                             font: GoogleFonts.inter(
//                                               fontWeight: FontWeight.w500,
//                                               fontStyle:
//                                                   FlutterFlowTheme.of(context)
//                                                       .bodyMedium
//                                                       .fontStyle,
//                                             ),
//                                             color: Colors.black,
//                                             fontSize: 12.0,
//                                             letterSpacing: 0.0,
//                                             fontWeight: FontWeight.w500,
//                                             fontStyle:
//                                                 FlutterFlowTheme.of(context)
//                                                     .bodyMedium
//                                                     .fontStyle,
//                                           ),
//                                     ),
//                                   ].divide(SizedBox(width: 16.0)),
//                                 ),
//                                 Icon(
//                                   Icons.chevron_right,
//                                   color: Colors.black,
//                                   size: 20.0,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       Divider(
//                         thickness: 2.0,
//                         color: FlutterFlowTheme.of(context).alternate,
//                       ),
                      
//                       InkWell(
//                         splashColor: Colors.transparent,
//                         focusColor: Colors.transparent,
//                         hoverColor: Colors.transparent,
//                         highlightColor: Colors.transparent,
//                         onTap: () async {
//                           // context.pushNamed(InboxPageWidget.routeName);
//                         },
//                         child: Container(
//                           width: double.infinity,
//                           height: 50.0,
//                           decoration: BoxDecoration(
//                             color: Color(0xFFF9F9F9),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsetsDirectional.fromSTEB(
//                                 0.0, 16.0, 0.0, 16.0),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.max,
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Row(
//                                   mainAxisSize: MainAxisSize.max,
//                                   children: [
//                                     FaIcon(
//                                       FontAwesomeIcons.userSecret,
//                                       color: Colors.black,
//                                       size: 24.0,
//                                     ),
//                                     Text(
//                                       FFLocalizations.of(context).getText(
//                                         '1gepgp40' /* Security */,
//                                       ),
//                                       style: FlutterFlowTheme.of(context)
//                                           .bodyMedium
//                                           .override(
//                                             font: GoogleFonts.inter(
//                                               fontWeight: FontWeight.w500,
//                                               fontStyle:
//                                                   FlutterFlowTheme.of(context)
//                                                       .bodyMedium
//                                                       .fontStyle,
//                                             ),
//                                             color: Colors.black,
//                                             fontSize: 12.0,
//                                             letterSpacing: 0.0,
//                                             fontWeight: FontWeight.w500,
//                                             fontStyle:
//                                                 FlutterFlowTheme.of(context)
//                                                     .bodyMedium
//                                                     .fontStyle,
//                                           ),
//                                     ),
//                                   ].divide(SizedBox(width: 16.0)),
//                                 ),
//                                 Icon(
//                                   Icons.chevron_right,
//                                   color: Colors.black,
//                                   size: 20.0,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       Divider(
//                         thickness: 2.0,
//                         color: FlutterFlowTheme.of(context).alternate,
//                       ),
//                       InkWell(
//                         splashColor: Colors.transparent,
//                         focusColor: Colors.transparent,
//                         hoverColor: Colors.transparent,
//                         highlightColor: Colors.transparent,
//                         // onTap: () async {
//                         //   context.pushNamed(AppSettingsWidget.routeName);
//                         // },
//                         onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const AppSettingsWidget(),
//                           ),
//                         );
//                       },

//                         child: Container(
//                           width: double.infinity,
//                           height: 50.0,
//                           decoration: BoxDecoration(
//                             color: Color(0xFFF9F9F9),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsetsDirectional.fromSTEB(
//                                 0.0, 16.0, 0.0, 16.0),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.max,
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Row(
//                                   mainAxisSize: MainAxisSize.max,
//                                   children: [
//                                     Icon(
//                                       Icons.app_settings_alt_outlined,
//                                       color: Colors.black,
//                                       size: 24.0,
//                                     ),
//                                     Text(
//                                       FFLocalizations.of(context).getText(
//                                         'glh63usn' /* App Settings */,
//                                       ),
//                                       style: FlutterFlowTheme.of(context)
//                                           .bodyMedium
//                                           .override(
//                                             font: GoogleFonts.inter(
//                                               fontWeight: FontWeight.w500,
//                                               fontStyle:
//                                                   FlutterFlowTheme.of(context)
//                                                       .bodyMedium
//                                                       .fontStyle,
//                                             ),
//                                             color: Colors.black,
//                                             fontSize: 12.0,
//                                             letterSpacing: 0.0,
//                                             fontWeight: FontWeight.w500,
//                                             fontStyle:
//                                                 FlutterFlowTheme.of(context)
//                                                     .bodyMedium
//                                                     .fontStyle,
//                                           ),
//                                     ),
//                                   ].divide(SizedBox(width: 16.0)),
//                                 ),
//                                 Icon(
//                                   Icons.chevron_right,
//                                   color: Colors.black,
//                                   size: 20.0,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
