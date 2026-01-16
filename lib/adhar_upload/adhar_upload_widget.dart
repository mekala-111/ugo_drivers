import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'adhar_upload_model.dart';
export 'adhar_upload_model.dart';

/// Create a page "Aadhaar Card Upload":
/// - AppBar: orange background, back arrow, centered "UGQ TAXI".
///
/// - Large title at top ("Take a photo of your Aadhaar card").
/// - Centered image widget: load "Aadhar-card.jpg" (rounded corners, fixed
/// height).
/// - Below image, gray disclosure text (as shown in the PNG).
/// - Bottom: orange rounded "Take photo" button, full width.
/// - Use padding and spacing for a clean, professional look.
class AdharUploadWidget extends StatefulWidget {
  const AdharUploadWidget({super.key});

  static String routeName = 'Adhar_Upload';
  static String routePath = '/adharUpload';

  @override
  State<AdharUploadWidget> createState() => _AdharUploadWidgetState();
}

class _AdharUploadWidgetState extends State<AdharUploadWidget> {
  late AdharUploadModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdharUploadModel());
    if (FFAppState().aadharImage?.bytes != null &&
      FFAppState().aadharImage!.bytes!.isNotEmpty) {
    _model.uploadedLocalFile_uploadData092= FFAppState().aadharImage!;
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
          backgroundColor: Color(0xFFFF8C00),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 20.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 24.0,
            ),
            onPressed: () {
              context.pop();
              print('IconButton pressed ...');
            },
          ),
          title: Text(
            FFLocalizations.of(context).getText(
              '932jflc2' /* UGQ TAXI */,
            ),
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleLarge.fontStyle,
                  ),
                  color: Colors.white,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  FFLocalizations.of(context).getText(
                    'gevrq6og' /* Take a photo of your Aadhaar c... */,
                  ),
                  textAlign: TextAlign.start,
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w600,
                          fontStyle: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .fontStyle,
                      ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 200.0,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: 
                        // ClipRRect(
                        //   borderRadius: BorderRadius.circular(12.0),
                        //   child: Image.memory(
                        //     _model.uploadedLocalFile_uploadData092.bytes ??
                        //         Uint8List.fromList([]),
                        //     width: double.infinity,
                        //     height: double.infinity,
                        //     fit: BoxFit.contain,
                        //   ),
                        // ),
                        ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: _model.uploadedLocalFile_uploadData092.bytes != null &&
                                      _model.uploadedLocalFile_uploadData092.bytes!.isNotEmpty
                                  ? Image.memory(
                                      _model.uploadedLocalFile_uploadData092.bytes!,
                                      width: 200.0,
                                      height: 168.0,
                                      fit: BoxFit.contain,
                                    )
                                  : Container(
                                      width: 200.0,
                                      height: 168.0,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        size: 48.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),

                      ),
                      Text(
                        FFLocalizations.of(context).getText(
                          'v9g63czf' /* • Make sure all four corners o... */,
                        ),
                        textAlign: TextAlign.start,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                              lineHeight: 1.5,
                            ),
                      ),
                    ].divide(SizedBox(height: 20.0)),
                  ),
                ),
                FFButtonWidget(
                  onPressed: () async {
                    final selectedMedia =
                        await selectMediaWithSourceBottomSheet(
                      context: context,
                      allowPhoto: true,
                    );
                    if (selectedMedia != null &&
                        selectedMedia.every((m) =>
                            validateFileFormat(m.storagePath, context))) {
                      safeSetState(
                          () => _model.isDataUploading_uploadData092 = true);
                      var selectedUploadedFiles = <FFUploadedFile>[];

                      try {
                        selectedUploadedFiles = selectedMedia
                            .map((m) => FFUploadedFile(
                                  name: m.storagePath.split('/').last,
                                  bytes: m.bytes,
                                  height: m.dimensions?.height,
                                  width: m.dimensions?.width,
                                  blurHash: m.blurHash,
                                  originalFilename: m.originalFilename,
                                ))
                            .toList();
                      } finally {
                        _model.isDataUploading_uploadData092 = false;
                      }
                      if (selectedUploadedFiles.length ==
                          selectedMedia.length) {
                        safeSetState(() {
                          _model.uploadedLocalFile_uploadData092 =
                              selectedUploadedFiles.first;
                        });
                      } else {
                        safeSetState(() {});
                        return;
                      }
                    }

                    FFAppState().aadharImage = _model
                        .uploadedLocalFile_uploadData092;
                    safeSetState(() {});
                  },
                  text: FFLocalizations.of(context).getText(
                    'ugnycsbu' /* Take photo */,
                  ),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 56.0,
                    padding: EdgeInsets.all(8.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: Color(0xFFFF8C00),
                    textStyle:
                        FlutterFlowTheme.of(context).titleMedium.override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontStyle,
                              ),
                              color: Colors.white,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .fontStyle,
                            ),
                    elevation: 0.0,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ].divide(SizedBox(height: 24.0)),
            ),
          ),
        ),
      ),
    );
  }
}
