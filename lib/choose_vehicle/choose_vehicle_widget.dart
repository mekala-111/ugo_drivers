import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'choose_vehicle_model.dart';
export 'choose_vehicle_model.dart';

class ChooseVehicleWidget extends StatefulWidget {
  const ChooseVehicleWidget({
    super.key,
    this.mobile,
    this.firstname,
    this.lastname,
    this.email,
    this.referalcode,
  });

  final int? mobile;
  final String? firstname;
  final String? lastname;
  final String? email;
  final int? referalcode;

  static String routeName = 'Choose_vehicle';
  static String routePath = '/chooseVehicle';

  @override
  State<ChooseVehicleWidget> createState() => _ChooseVehicleWidgetState();
}

class _ChooseVehicleWidgetState extends State<ChooseVehicleWidget> {
  late ChooseVehicleModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChooseVehicleModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: FlutterFlowTheme.of(context).secondary,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            FFLocalizations.of(context).getText(
              '7bszawn6' /* U G O */,
            ),
            style: FlutterFlowTheme.of(context).headlineLarge.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).secondary,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              FFLocalizations.of(context).getText(
                                'n5wkquh8' /* Choose How You Want to Earn wi... */,
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .headlineMedium
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 24,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            if (FFAppState().selectvehicle.isEmpty)
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                                child: Text(
                                  'Select a vehicle type to continue',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                        child: FutureBuilder<ApiCallResponse>(
                          future: ChoosevehicleCall.call(),
                          builder: (context, snapshot) {
                            // Loading state
                            if (!snapshot.hasData) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 50, 0, 0),
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            // Error state
                            if (snapshot.hasError ||
                                snapshot.data?.statusCode != 200) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16, 50, 16, 0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 60,
                                        color: FlutterFlowTheme.of(context)
                                            .error,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Failed to load vehicles',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              font: GoogleFonts.inter(),
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      SizedBox(height: 8),
                                      FFButtonWidget(
                                        onPressed: () {
                                          setState(() {});
                                        },
                                        text: 'Retry',
                                        options: FFButtonOptions(
                                          height: 40,
                                          padding: EdgeInsetsDirectional
                                              .fromSTEB(24, 0, 24, 0),
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          textStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: Colors.white,
                                                    letterSpacing: 0.0,
                                                  ),
                                          elevation: 0,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final vehiclenamesChoosevehicleResponse =
                                snapshot.data!;

                            return Builder(
                              builder: (context) {
                                final vechiclename = ChoosevehicleCall.data(
                                      vehiclenamesChoosevehicleResponse
                                          .jsonBody,
                                    )?.toList() ??
                                    [];

                                // Empty state
                                if (vechiclename.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16, 50, 16, 0),
                                      child: Text(
                                        'No vehicles available',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              font: GoogleFonts.inter(),
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16, 0, 16, 0),
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: vechiclename.length,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: 12),
                                  itemBuilder: (context, vechiclenameIndex) {
                                    final vechiclenameItem =
                                        vechiclename[vechiclenameIndex];
                                    
                                    // Extract vehicle type string
                                    final vehicleType = getJsonField(
                                      vechiclenameItem,
                                      r'''$.vehicle_type''',
                                    ).toString();
                                    
                                    // Check if this vehicle is selected by comparing vehicle type
                                    final isSelected =
                                        FFAppState().selectvehicle == vehicleType;

                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        setState(() {
                                          // Store ONLY the vehicle type string in app state
                                          FFAppState().selectvehicle = vehicleType;
                                        });
                                        
                                        // Debug: Print what's being stored
                                        print('Selected vehicle type: $vehicleType');
                                        print('App state value: ${FFAppState().selectvehicle}');
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Color(0xFFFF6B35)
                                                  .withOpacity(0.1)
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? Color(0xFFFF6B35)
                                                : FlutterFlowTheme.of(context)
                                                    .alternate,
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16, 16, 16, 16),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  'https://ugotaxi.icacorp.org/${getJsonField(
                                                    vechiclenameItem,
                                                    r'''$.vehicle_image''',
                                                  ).toString()}',
                                                  width: 70,
                                                  height: 70,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      width: 70,
                                                      height: 70,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .directions_car_rounded,
                                                        size: 40,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(16, 0, 0, 0),
                                                  child: Text(
                                                    vehicleType,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyLarge
                                                        .override(
                                                          font: GoogleFonts
                                                              .inter(
                                                            fontWeight: isSelected
                                                                ? FontWeight
                                                                    .w600
                                                                : FontWeight
                                                                    .normal,
                                                          ),
                                                          color: isSelected
                                                              ? Color(
                                                                  0xFFFF6B35)
                                                              : FlutterFlowTheme
                                                                      .of(
                                                                          context)
                                                                  .primaryText,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Color(0xFFFF6B35),
                                                  size: 24,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Fixed bottom button
              Container(
                padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: Color(0x1A000000),
                      offset: Offset(0, -2),
                    )
                  ],
                ),
                child: FFButtonWidget(
                  onPressed: FFAppState().selectvehicle.isEmpty
                      ? null
                      : () async {
                          if (FFAppState().selectvehicle.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please select a vehicle type',
                                  style: TextStyle(
                                    color: FlutterFlowTheme.of(context).info,
                                  ),
                                ),
                                duration: Duration(milliseconds: 3000),
                                backgroundColor:
                                    FlutterFlowTheme.of(context).error,
                              ),
                            );
                            return;
                          }

                          // Debug: Print before navigation
                          print('Navigating with vehicle type: ${FFAppState().selectvehicle}');

                          context.pushNamed(
                            OnBoardingWidget.routeName,
                            queryParameters: {
                              'mobile': serializeParam(
                                widget.mobile,
                                ParamType.int,
                              ),
                              'firstname': serializeParam(
                                widget.firstname,
                                ParamType.String,
                              ),
                              'lastname': serializeParam(
                                widget.lastname,
                                ParamType.String,
                              ),
                              'email': serializeParam(
                                widget.email,
                                ParamType.String,
                              ),
                              'referalcode': serializeParam(
                                widget.referalcode,
                                ParamType.int,
                              ),
                              'vehicletype': serializeParam(
                                FFAppState().selectvehicle,
                                ParamType.String,
                              ),
                            }.withoutNulls,
                          );
                        },
                  text: FFLocalizations.of(context).getText(
                    'uhrogttt' /* Continue */,
                  ),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 55,
                    padding: EdgeInsets.all(8),
                    iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: FFAppState().selectvehicle.isEmpty
                        ? FlutterFlowTheme.of(context).alternate
                        : Color(0xFFFF6B35),
                    textStyle:
                        FlutterFlowTheme.of(context).titleMedium.override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.w600,
                              ),
                              color: Colors.white,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                    elevation: 0,
                    borderRadius: BorderRadius.circular(12),
                    disabledColor: FlutterFlowTheme.of(context).alternate,
                    disabledTextColor:
                        FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}