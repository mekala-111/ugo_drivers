import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'IncentivePageModel.dart';
export 'IncentivePageModel.dart';

class IncentivePageWidget extends StatefulWidget {
  const IncentivePageWidget({super.key});

  static String routeName = 'incentivePage';
  static String routePath = '/incentivePage';

  @override
  State<IncentivePageWidget> createState() => _IncentivePageWidgetState();
}

class _IncentivePageWidgetState extends State<IncentivePageWidget> {
  late IncentivePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _incentiveItems = [
    {
      'ridesKey': 'zg0xawte',
      'rewardKey': 'u3ymy4pr',
      'isLocked': false,
    },
    {
      'ridesKey': 'bt7kot3y',
      'rewardKey': '7r9r8l37',
      'isLocked': true,
    },
    {
      'ridesKey': 'dvk5wszx',
      'rewardKey': 'v8r4nr1u',
      'isLocked': true,
    },
    {
      'ridesKey': 'ky05gank',
      'rewardKey': 'bczspme7',
      'isLocked': true,
    },
    {
      'ridesKey': 'lof014xm',
      'rewardKey': '2zgf027h',
      'isLocked': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IncentivePageModel());
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30,
            borderWidth: 1,
            buttonSize: 60,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            FFLocalizations.of(context).getText(
              'o4ik6hfp' /* incentives */,
            ),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Container(
            decoration: BoxDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        FFLocalizations.of(context).getText(
                          'r35w09da' /* Complete 80 more rides to earn... */,
                        ),
                        style: FlutterFlowTheme.of(context)
                            .titleMedium
                            .override(
                              font: GoogleFonts.interTight(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .fontStyle,
                            ),
                      ),
                    ].divide(SizedBox(height: 24)),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _incentiveItems.length,
                    itemBuilder: (context, index) {
                      final item = _incentiveItems[index];
                      final isProgressItem = index == 0;

                      return Padding(
                        padding:
                            EdgeInsets.only(bottom: isProgressItem ? 24 : 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  FFLocalizations.of(context)
                                      .getText(item['ridesKey']),
                                  style: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleLarge
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleLarge
                                                  .fontStyle,
                                        ),
                                        color: isProgressItem
                                            ? FlutterFlowTheme.of(context)
                                                .primaryText
                                            : FlutterFlowTheme.of(context)
                                                .secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleLarge
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleLarge
                                            .fontStyle,
                                      ),
                                ),
                                Text(
                                  FFLocalizations.of(context)
                                      .getText(item['rewardKey']),
                                  style: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleLarge
                                                  .fontStyle,
                                        ),
                                        color: Color(0xFFFF6B35),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleLarge
                                            .fontStyle,
                                      ),
                                ),
                              ],
                            ),
                            if (isProgressItem) SizedBox(height: 16),
                            if (isProgressItem)
                              Container(
                                width: double.infinity,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            if (!isProgressItem) ...[
                              SizedBox(height: 8),
                              if (item['isLocked'] as bool)
                                Icon(
                                  Icons.lock_outline,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  size: 20,
                                ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ].divide(SizedBox(height: 0)),
            ),
          ),
        ),
      ),
    );
  }
}
