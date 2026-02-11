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
  final String? referalcode; // String type is correct

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

    // Debug Logs
    print(
        "Initializing ChooseVehicle for: ${widget.firstname} ${widget.lastname}");
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
          backgroundColor: const Color(0xFFFF7B10), // Matched theme orange
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            FFLocalizations.of(context).getText('7bszawn6' /* U G O */),
            style: FlutterFlowTheme.of(context).headlineLarge.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Colors.white,
                  letterSpacing: 0.0,
                ),
          ),
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
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16, 16, 16, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              FFLocalizations.of(context).getText(
                                  'n5wkquh8' /* Choose How You Want to Earn... */),
                              style: FlutterFlowTheme.of(context)
                                  .headlineMedium
                                  .override(
                                    font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w600),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 24,
                                  ),
                            ),
                            if (FFAppState().selectvehicle.isEmpty)
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 8, 0, 0),
                                child: Text(
                                  'Select a vehicle type to continue',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                        child: FutureBuilder<ApiCallResponse>(
                          future: ChoosevehicleCall.call(),
                          builder: (context, snapshot) {
                            // Loading state
                            if (!snapshot.hasData) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 50, 0, 0),
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        const Color(0xFFFF7B10),
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
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16, 50, 16, 0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 60,
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Failed to load vehicles',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge,
                                      ),
                                      const SizedBox(height: 8),
                                      FFButtonWidget(
                                        onPressed: () {
                                          setState(() {}); // Retry
                                        },
                                        text: 'Retry',
                                        options: FFButtonOptions(
                                          height: 40,
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(24, 0, 24, 0),
                                          color: const Color(0xFFFF7B10),
                                          textStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: Colors.white,
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

                            final response = snapshot.data!;
                            return Builder(
                              builder: (context) {
                                // Safe list parsing
                                final rawList =
                                    ChoosevehicleCall.data(response.jsonBody);
                                final vechiclename =
                                    (rawList is List) ? rawList : [];

                                if (vechiclename.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              16, 50, 16, 0),
                                      child: Text(
                                        'No vehicles available',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge,
                                      ),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16, 0, 16, 0),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: vechiclename.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = vechiclename[index];

                                    // Robust Parsing: Works for both Map and FlutterFlow JSON format
                                    String vehicleName = '';
                                    if (item is Map) {
                                      vehicleName =
                                          item['name']?.toString() ?? '';
                                    } else {
                                      vehicleName =
                                          getJsonField(item, r'$["name"]')
                                                  ?.toString() ??
                                              '';
                                    }

                                    // Fallback if name is missing
                                    if (vehicleName.isEmpty)
                                      vehicleName = "Unknown Vehicle";

                                    final isSelected =
                                        FFAppState().selectvehicle ==
                                            vehicleName;

                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        setState(() {
                                          FFAppState().selectvehicle =
                                              vehicleName;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFFFF6B35)
                                                  .withOpacity(0.1)
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFFFF6B35)
                                                : FlutterFlowTheme.of(context)
                                                    .alternate,
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(16, 16, 16, 16),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 70,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? const Color(0xFFFF6B35)
                                                          .withOpacity(0.2)
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .alternate,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  _getVehicleIcon(vehicleName),
                                                  size: 40,
                                                  color: isSelected
                                                      ? const Color(0xFFFF6B35)
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryText,
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          16, 0, 0, 0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        vehicleName
                                                            .toUpperCase(),
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyLarge
                                                            .override(
                                                              font: GoogleFonts
                                                                  .inter(
                                                                fontWeight: isSelected
                                                                    ? FontWeight
                                                                        .w600
                                                                    : FontWeight
                                                                        .w500,
                                                              ),
                                                              color: isSelected
                                                                  ? const Color(
                                                                      0xFFFF6B35)
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                              fontSize: 18,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                const Icon(
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

              // Bottom Action Bar
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  boxShadow: const [
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
                      : () {
                          // Double check state
                          if (FFAppState().selectvehicle.isEmpty) return;

                          context.pushNamed(
                            OnBoardingWidget.routeName,
                            queryParameters: {
                              'mobile':
                                  serializeParam(widget.mobile, ParamType.int),
                              'firstname': serializeParam(
                                  widget.firstname, ParamType.String),
                              'lastname': serializeParam(
                                  widget.lastname, ParamType.String),
                              'email': serializeParam(
                                  widget.email, ParamType.String),
                              'referalcode': serializeParam(
                                  widget.referalcode, ParamType.String),
                              'vehicletype': serializeParam(
                                  FFAppState().selectvehicle, ParamType.String),
                            }.withoutNulls,
                          );
                        },
                  text: FFLocalizations.of(context)
                      .getText('uhrogttt' /* Continue */),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 55,
                    color: FFAppState().selectvehicle.isEmpty
                        ? FlutterFlowTheme.of(context).alternate
                        : const Color(0xFFFF6B35),
                    textStyle:
                        FlutterFlowTheme.of(context).titleMedium.override(
                              font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w600),
                              color: Colors.white,
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

  IconData _getVehicleIcon(String vehicleName) {
    final name = vehicleName.toLowerCase();
    if (name.contains('auto')) return Icons.local_taxi;
    if (name.contains('bike') || name.contains('motorcycle'))
      return Icons.two_wheeler;
    if (name.contains('car') || name.contains('sedan') || name.contains('suv'))
      return Icons.directions_car;
    if (name.contains('truck')) return Icons.local_shipping;
    return Icons.directions_car_rounded;
  }
}
