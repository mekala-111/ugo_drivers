import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/api_requests/api_calls.dart' show DriverRideHistoryCall;
import '/repositories/driver_repository.dart';
import 'history_model.dart';
import '../models/ride_history_item.dart';
export 'history_model.dart';

/// Past Booking History List
class HistoryWidget extends StatefulWidget {
  const HistoryWidget({super.key});

  static String routeName = 'History';
  static String routePath = '/history';

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  late HistoryModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  String? _error;
  List<dynamic> _rides = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HistoryModel());
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await DriverRepository.instance.getRideHistory(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
      );
      if (res.succeeded) {
        final data = DriverRideHistoryCall.rides(res.jsonBody);
        // convert to strongly-typed model objects
        final parsed = data
            .whereType<Map<String, dynamic>>()
            .map((m) => RideHistoryItem.fromJson(m))
            .toList();
        setState(() {
          _rides = parsed;
        });
      } else {
        setState(() {
          _error = 'Failed to load history';
        });
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              FlutterFlowIconButton(
                borderRadius: 20.0,
                buttonSize: 40.0,
                icon: Icon(
                  Icons.arrow_back,
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  size: 24.0,
                ),
                onPressed: () async {
                  context.safePop();
                },
              ),
              Expanded(
                child: Text(
                  FFLocalizations.of(context).getText(
                    'b5u7cma8' /* History */,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w500,
                          fontStyle:
                              FlutterFlowTheme.of(context).titleLarge.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleLarge.fontStyle,
                      ),
                ),
              ),
            ].divide(const SizedBox(width: 12.0)),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                FFLocalizations.of(context).getText('c0vu40lh'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.normal,
                                      ),
                                      color: FlutterFlowTheme.of(context).accent1,
                                      fontSize: 20.0,
                                    ),
                              ),
                            ),
                            FlutterFlowIconButton(
                              borderRadius: 20.0,
                              buttonSize: 40.0,
                              icon: Icon(
                                Icons.refresh,
                                color: FlutterFlowTheme.of(context).accent1,
                                size: 24.0,
                              ),
                              onPressed: _loadHistory,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _rides.isEmpty
                              ? Center(child: Text(FFLocalizations.of(context).getText('hist0001')))
                              : ListView.builder(
                                  itemCount: _rides.length,
                                  itemBuilder: (context, index) {
                                    final ride =
                                        _rides[index] as RideHistoryItem;
                                    return _HistoryRideCard(ride: ride);
                                  },
                                ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _HistoryRideCard extends StatelessWidget {
  const _HistoryRideCard({required this.ride});

  final RideHistoryItem ride;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, h:mm a').format(ride.date);
    final pickup = ride.pickupAddress.isNotEmpty
        ? ride.pickupAddress
        : 'Pickup';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).accent1,
            width: 2.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: AppColors.containerGrey,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/Screenshot_2025-07-01_144141.png',
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pickup,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FlutterFlowTheme.of(context).titleMedium.override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.normal,
                              ),
                              color: FlutterFlowTheme.of(context).accent1,
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateStr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.normal,
                              ),
                              color: AppColors.textMuted,
                              fontSize: 10.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹ ${ride.fare.toStringAsFixed(2)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.normal,
                              ),
                              color: AppColors.textMuted,
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              FFButtonWidget(
                onPressed: () {},
                text: FFLocalizations.of(context).getText('8rlnckeh'),
                options: FFButtonOptions(
                  width: 80.0,
                  height: 30.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    16.0, 8.0, 16.0, 8.0,
                  ),
                  iconPadding: EdgeInsetsDirectional.zero,
                  color: AppColors.greyBorderLight,
                  textStyle: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.normal,
                    ),
                    color: FlutterFlowTheme.of(context).accent1,
                    fontSize: 10.0,
                  ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
