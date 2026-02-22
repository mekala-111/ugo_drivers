import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

import 'insurance_image_model.dart';
export 'insurance_image_model.dart';

class UploadRcWidget extends StatefulWidget {
  const UploadRcWidget({super.key});

  static String routeName = 'Upload_rc';
  static String routePath = '/uploadRc';

  @override
  State<UploadRcWidget> createState() => _UploadRcWidgetState();
}

class _UploadRcWidgetState extends State<UploadRcWidget> {
  late UploadRcModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  FFUploadedFile? _insurancePdf;
  bool _isValid = false;
  String _fileName = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UploadRcModel());
    _loadSavedFile();
  }

  void _loadSavedFile() {
    if (FFAppState().insurancePdf != null &&
        FFAppState().insurancePdf!.bytes != null) {
      setState(() {
        _insurancePdf = FFAppState().insurancePdf;
        _fileName = _insurancePdf?.name ?? 'insurance.pdf';
        _isValid = true;
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  Future<void> _pickPdf() async {
    final selected = await selectFile(allowedExtensions: ['pdf']);
    if (selected == null) return;

    final file = FFUploadedFile(
      name: selected.storagePath.split('/').last,
      bytes: selected.bytes,
    );

    setState(() {
      _insurancePdf = file;
      _fileName = file.name ?? 'insurance.pdf';
      _isValid = true;
    });

    FFAppState().insurancePdf = file;
    FFAppState().insuranceImage = file;
    FFAppState().insuranceBase64 =
        file.bytes != null ? base64Encode(file.bytes!) : '';
    FFAppState().update(() {});
    _showSnackBar('Insurance PDF uploaded');
  }

  void _removeFile() {
    setState(() {
      _insurancePdf = null;
      _fileName = '';
      _isValid = false;
    });
    FFAppState().insurancePdf = null;
    FFAppState().insuranceImage = null;
    FFAppState().insuranceBase64 = '';
    FFAppState().update(() {});
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
        backgroundColor: AppColors.backgroundAlt,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Insurance PDF',
            style: GoogleFonts.interTight(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload your insurance document',
                  style: GoogleFonts.interTight(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PDF files only. Make sure all details are readable.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.greySlate,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickPdf,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            _isValid ? AppColors.primary : AppColors.greyBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.sectionOrangeLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _isValid ? _fileName : 'Tap to upload PDF',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (_isValid)
                          IconButton(
                            onPressed: _removeFile,
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.error,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isValid
                        ? () {
                            context.pushNamed(
                              RCUploadWidget.routeName,
                              extra: const TransitionInfo(
                                hasTransition: true,
                                transitionType: PageTransitionType.rightToLeft,
                                duration: Duration(milliseconds: 300),
                              ),
                            );
                          }
                        : () {
                            _showSnackBar('Please upload insurance PDF',
                                isError: true);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: GoogleFonts.interTight(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
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
