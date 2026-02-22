import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'background_location_notice_model.dart';
export 'background_location_notice_model.dart';

class BackgroundLocationNoticeWidget extends StatefulWidget {
  const BackgroundLocationNoticeWidget({super.key});

  static String routeName = 'background_location_notice';
  static String routePath = '/background-location-notice';

  @override
  State<BackgroundLocationNoticeWidget> createState() =>
      _BackgroundLocationNoticeWidgetState();
}

class _BackgroundLocationNoticeWidgetState
    extends State<BackgroundLocationNoticeWidget> {
  late BackgroundLocationNoticeModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BackgroundLocationNoticeModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          'Location access',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Allow background location',
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.w600,
                        fontStyle: FlutterFlowTheme.of(context)
                            .headlineSmall
                            .fontStyle,
                      ),
                      color: Colors.black,
                      fontSize: 22,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'UGO Driver uses background location to keep you online, show '
                'accurate pickup ETAs, and match nearby ride requests even when '
                'the app is not on screen. This improves ride reliability and '
                'safety during active trips.',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: Colors.black87,
                      fontSize: 15,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      lineHeight: 1.4,
                    ),
              ),
              const SizedBox(height: 20),
              _buildBullet(
                context,
                'Stay online and receive rides reliably',
              ),
              _buildBullet(
                context,
                'Track trips accurately during active rides',
              ),
              _buildBullet(
                context,
                'Improve pickup accuracy and rider safety',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'You can change this anytime in Settings. We access background '
                  'location only while you are online or on an active ride. When '
                  'you go offline, background tracking stops.',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontStyle: FlutterFlowTheme.of(context)
                              .bodySmall
                              .fontStyle,
                        ),
                        color: Colors.black87,
                        fontSize: 12,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FlutterFlowTheme.of(context)
                            .bodySmall
                            .fontStyle,
                        lineHeight: 1.4,
                      ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        FFLocalizations.of(context).getText('drv_not_now'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text(
                        FFLocalizations.of(context).getText('drv_allow'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: Colors.black87,
                    fontSize: 14,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
