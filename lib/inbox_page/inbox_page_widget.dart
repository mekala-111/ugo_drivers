import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_requests/api_calls.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'inbox_page_model.dart';
export 'inbox_page_model.dart';

class InboxPageWidget extends StatefulWidget {
  const InboxPageWidget({super.key});

  static String routeName = 'inboxPage';
  static String routePath = '/inboxPage';

  @override
  State<InboxPageWidget> createState() => _InboxPageWidgetState();
}

class _InboxPageWidgetState extends State<InboxPageWidget> {
  late InboxPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InboxPageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNotifications());
  }

  Future<void> _loadNotifications() async {
    final response = await NotificationHistoryCall.call(
      token: FFAppState().accessToken,
    );

    // Do not log full response body - may contain PII

    if (response.succeeded) {
      setState(() {
        _model.notificationData = response.jsonBody;
      });
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(
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
              'yk1kpsjg' /* inbox */,
            ),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: _model.notificationData != null &&
                  NotificationHistoryCall.notifications(
                          _model.notificationData) !=
                      null &&
                  NotificationHistoryCall.notifications(
                          _model.notificationData)!
                      .isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                  itemCount: NotificationHistoryCall.notifications(
                          _model.notificationData)!
                      .length,
                  itemBuilder: (context, index) {
                    final notification = NotificationHistoryCall.notifications(
                        _model.notificationData)![index];
                    final isRead = getJsonField(
                          notification,
                          r'$.is_read',
                        ) ==
                        true;
                    final title = getJsonField(
                          notification,
                          r'$.notification_title',
                        )?.toString() ??
                        getJsonField(
                          notification,
                          r'$.title',
                        )?.toString() ??
                        'Notification';
                    final message = getJsonField(
                          notification,
                          r'$.notification_body',
                        )?.toString() ??
                        getJsonField(
                          notification,
                          r'$.message',
                        )?.toString() ??
                        '';
                    final createdAt = getJsonField(
                          notification,
                          r'$.created_at',
                        )?.toString() ??
                        '';

                    return Container(
                      margin:
                          const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: isRead
                              ? FlutterFlowTheme.of(context).alternate
                              : FlutterFlowTheme.of(context).primary,
                          width: isRead ? 1.0 : 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.05),
                            blurRadius: 4.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48.0,
                              height: 48.0,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isRead
                                      ? [
                                          FlutterFlowTheme.of(context)
                                              .alternate,
                                          FlutterFlowTheme.of(context)
                                              .alternate,
                                        ]
                                      : [
                                          FlutterFlowTheme.of(context).primary,
                                          FlutterFlowTheme.of(context)
                                              .secondary,
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_active,
                                color: Colors.white,
                                size: 24.0,
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: GoogleFonts.inter(
                                            fontSize: 16.0,
                                            fontWeight: isRead
                                                ? FontWeight.w500
                                                : FontWeight.w700,
                                            color: AppColors.textNearBlack,
                                          ),
                                        ),
                                      ),
                                      if (!isRead)
                                        Container(
                                          width: 10.0,
                                          height: 10.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6.0),
                                  Text(
                                    message,
                                    style: GoogleFonts.inter(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.greyDark,
                                      height: 1.5,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (createdAt.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 14.0,
                                            color: AppColors.grey,
                                          ),
                                          const SizedBox(width: 4.0),
                                          Text(
                                            createdAt,
                                            style: GoogleFonts.inter(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).accent1,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_none,
                          size: 50.0,
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Text(
                        'No notifications yet',
                        style: GoogleFonts.inter(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textNearBlack,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'You\'re all caught up!',
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
