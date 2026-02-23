import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/api_requests/api_calls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_bank_account_model.dart';
export 'add_bank_account_model.dart';

class AddBankAccountWidget extends StatefulWidget {
  const AddBankAccountWidget({super.key});

  static String routeName = 'addBankAccount';
  static String routePath = '/addBankAccount';

  @override
  State<AddBankAccountWidget> createState() => _AddBankAccountWidgetState();
}

class _AddBankAccountWidgetState extends State<AddBankAccountWidget> {
  late AddBankAccountModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddBankAccountModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _validateBankAccount() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() {
      _model.isValidating = true;
      _model.validationError = null;
      _model.validatedBankName = null;
    });

    try {
      final ifscCode = _model.bankIfscCodeController.text.trim();
      final accountNumber = _model.bankAccountNumberController.text.trim();

      // Validate IFSC code through Razorpay API
      final response = await RazorpayBankValidationCall.call(
        ifscCode: ifscCode,
        accountNumber: accountNumber,
      );

      if (response.succeeded) {
        final bankName = RazorpayBankValidationCall.bankName(response.jsonBody);
        final branchName =
            RazorpayBankValidationCall.branchName(response.jsonBody);
        final city = RazorpayBankValidationCall.city(response.jsonBody);

        setState(() {
          _model.validatedBankName =
              bankName ?? FFLocalizations.of(context).getText('bank0001');
          _model.isValidating = false;
        });

        // Show success dialog with bank details
        if (mounted) {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(
                FFLocalizations.of(context).getText('bank0002'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FFLocalizations.of(context)
                        .getText('bank0003')
                        .replaceAll('%1', _model.validatedBankName ?? ''),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (branchName != null && branchName != '')
                    Text(FFLocalizations.of(context)
                        .getText('bank0004')
                        .replaceAll('%1', branchName)),
                  if (city != null && city != '')
                    Text(FFLocalizations.of(context)
                        .getText('bank0005')
                        .replaceAll('%1', city)),
                  const SizedBox(height: 8),
                  Text(FFLocalizations.of(context)
                      .getText('bank0006')
                      .replaceAll('%1', ifscCode)),
                  const SizedBox(height: 8),
                  Text(FFLocalizations.of(context)
                      .getText('bank0007')
                      .replaceAll('%1',
                          accountNumber.substring(accountNumber.length - 4))),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await _submitBankAccount();
                  },
                  child: Text(
                    FFLocalizations.of(context).getText('bank0008'),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        // Get error details from response
        if (!context.mounted) return;
        String errorMessage = FFLocalizations.of(context).getText('bank0009');

        // Try to extract error from response
        final errorDetail = response.jsonBody;
        if (errorDetail is Map) {
          if (errorDetail.containsKey('error')) {
            errorMessage = errorDetail['error'].toString();
          } else if (errorDetail.containsKey('message')) {
            errorMessage = errorDetail['message'].toString();
          }
        }

        setState(() {
          _model.validationError = errorMessage;
          _model.isValidating = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(FFLocalizations.of(context)
                  .getText('bank0010')
                  .replaceAll('%1', errorMessage)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _model.validationError = e.toString();
        _model.isValidating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(FFLocalizations.of(context)
                .getText('bank0011')
                .replaceAll('%1', _model.validationError ?? '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitBankAccount() async {
    final driverId = FFAppState().driverid;
    final token = FFAppState().accessToken;
    final holderName = _model.bankHolderNameController.text.trim();
    final accountNumber = _model.bankAccountNumberController.text.trim();
    final ifscCode = _model.bankIfscCodeController.text.trim();

    if (driverId == 0 || token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login first'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    if (holderName.isEmpty || accountNumber.isEmpty || ifscCode.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(FFLocalizations.of(context).getText('bank0013')),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _model.isValidating = true);
    try {
      final response = await AddBankAccountCall.call(
        driverId: driverId,
        bankAccountNumber: accountNumber,
        bankIfscCode: ifscCode,
        bankHolderName: holderName,
        token: token,
      );
      if (!mounted) return;
      setState(() => _model.isValidating = false);
      if (AddBankAccountCall.success(response.jsonBody) == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AddBankAccountCall.message(response.jsonBody) ??
                  FFLocalizations.of(context).getText('bank0012'),
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AddBankAccountCall.message(response.jsonBody) ??
                  'Failed to add bank account',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _model.isValidating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isMediumScreen = size.width >= 360 && size.width < 600;
    final isTablet = size.width >= 600;
    final isLargeTablet = size.width >= 900;
    final isLandscape = size.height < size.width;

    // Enhanced scale calculation
    final scale = isLargeTablet
        ? 1.2
        : isTablet
            ? 1.1
            : isMediumScreen
                ? 1.0
                : 0.9;

    // Responsive spacing
    final horizontalPadding = isLargeTablet
        ? 48.0
        : isTablet
            ? 32.0
            : isMediumScreen
                ? 20.0
                : 16.0;
    final fieldHorizontalPadding = isLargeTablet
        ? 64.0
        : isTablet
            ? 48.0
            : isMediumScreen
                ? 32.0
                : 20.0;
    final verticalSpacing = isLandscape ? 12.0 * scale : 16.0 * scale;

    // Responsive content width
    final contentMaxWidth = isLargeTablet
        ? 800.0
        : isTablet
            ? 640.0
            : double.infinity;

    // Responsive button dimensions
    final buttonHeight = isLandscape ? 45.0 * scale : 50.0 * scale;
    final fieldHeight = isLandscape ? 45.0 * scale : 50.0 * scale;

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
            icon: const Icon(
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
              'wlxvqket' /* Add Bank Account */,
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
          actions: const [],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentMaxWidth),
                      child: Form(
                        key: _formKey,
                        child: Container(
                          decoration: const BoxDecoration(),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  horizontalPadding,
                                  0,
                                  horizontalPadding,
                                  0,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        fieldHorizontalPadding,
                                        0,
                                        fieldHorizontalPadding,
                                        0,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              'z3yviii2' /* Full Name */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          SizedBox(
                                            height: fieldHeight,
                                            child: TextFormField(
                                              controller: _model
                                                  .bankHolderNameController,
                                              focusNode: _model
                                                  .bankHolderNameFocusNode,
                                              textInputAction:
                                                  TextInputAction.next,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return FFLocalizations.of(
                                                          context)
                                                      .getText('bank0013');
                                                }
                                                return null;
                                              },
                                              onFieldSubmitted: (_) {
                                                _model
                                                    .bankAccountNumberFocusNode
                                                    ?.requestFocus();
                                              },
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: AppColors.background,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 12,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                    color: Colors.transparent,
                                                    width: 1,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: verticalSpacing),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        fieldHorizontalPadding,
                                        0,
                                        fieldHorizontalPadding,
                                        0,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              'vwehe0jg' /* Bank Account Number */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          SizedBox(
                                            height: fieldHeight,
                                            child: TextFormField(
                                              controller: _model
                                                  .bankAccountNumberController,
                                              focusNode: _model
                                                  .bankAccountNumberFocusNode,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              textInputAction:
                                                  TextInputAction.next,
                                              validator: (value) {
                                                final trimmed =
                                                    value?.trim() ?? '';
                                                if (trimmed.isEmpty) {
                                                  return FFLocalizations.of(
                                                          context)
                                                      .getText('bank0014');
                                                }
                                                if (trimmed.length < 9 ||
                                                    trimmed.length > 18) {
                                                  return FFLocalizations.of(
                                                          context)
                                                      .getText('bank0015');
                                                }
                                                return null;
                                              },
                                              onFieldSubmitted: (_) {
                                                _model
                                                    .confirmBankAccountNumberFocusNode
                                                    ?.requestFocus();
                                              },
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: AppColors.background,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 12,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                    color: Colors.transparent,
                                                    width: 1,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: verticalSpacing),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        fieldHorizontalPadding,
                                        0,
                                        fieldHorizontalPadding,
                                        0,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              '6kj7r3jn' /* Confirm Bank Account Number */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          SizedBox(
                                            height: fieldHeight,
                                            child: TextFormField(
                                              controller: _model
                                                  .confirmBankAccountNumberController,
                                              focusNode: _model
                                                  .confirmBankAccountNumberFocusNode,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              textInputAction:
                                                  TextInputAction.next,
                                              validator: (value) {
                                                final trimmed =
                                                    value?.trim() ?? '';
                                                final original = _model
                                                    .bankAccountNumberController
                                                    .text
                                                    .trim();
                                                if (trimmed.isEmpty) {
                                                  return FFLocalizations.of(
                                                          context)
                                                      .getText('bank0016');
                                                }
                                                if (trimmed != original) {
                                                  return FFLocalizations.of(
                                                          context)
                                                      .getText('bank0017');
                                                }
                                                return null;
                                              },
                                              onFieldSubmitted: (_) {
                                                _model.bankIfscCodeFocusNode
                                                    ?.requestFocus();
                                              },
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: AppColors.background,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 12,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                    color: Colors.transparent,
                                                    width: 1,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: verticalSpacing),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        fieldHorizontalPadding,
                                        0,
                                        fieldHorizontalPadding,
                                        0,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              'l1eb56jt' /* Bank IFSC Code */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          SizedBox(
                                            height: fieldHeight,
                                            child: TextFormField(
                                              controller:
                                                  _model.bankIfscCodeController,
                                              focusNode:
                                                  _model.bankIfscCodeFocusNode,
                                              textCapitalization:
                                                  TextCapitalization.characters,
                                              textInputAction:
                                                  TextInputAction.done,
                                              validator: (value) {
                                                final trimmed =
                                                    value?.trim() ?? '';
                                                if (trimmed.isEmpty) {
                                                  return FFLocalizations.of(
                                                          context)
                                                      .getText('bank0018');
                                                }
                                                final regex = RegExp(
                                                    r'^[A-Z]{4}0[A-Z0-9]{6}$');
                                                if (!regex.hasMatch(
                                                    trimmed.toUpperCase())) {
                                                  return FFLocalizations.of(
                                                          context)
                                                      .getText('bank0019');
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: AppColors.background,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 12,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                    color: Colors.transparent,
                                                    width: 1,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: verticalSpacing),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        fieldHorizontalPadding,
                                        0,
                                        fieldHorizontalPadding,
                                        0,
                                      ),
                                      child: isSmallScreen
                                          ? Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: FFButtonWidget(
                                                        onPressed: () {
                                                          context.pop();
                                                        },
                                                        text: FFLocalizations
                                                                .of(context)
                                                            .getText(
                                                                'wv7qy5fs' /* Cancel */),
                                                        options:
                                                            FFButtonOptions(
                                                          height: buttonHeight,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          iconPadding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  0, 0, 0, 0),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          textStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .interTight(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .fontStyle,
                                                                    ),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontStyle,
                                                                  ),
                                                          elevation: 0,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: FFButtonWidget(
                                                        onPressed:
                                                            _model.isValidating
                                                                ? null
                                                                : () {
                                                                    _validateBankAccount();
                                                                  },
                                                        text: _model
                                                                .isValidating
                                                            ? FFLocalizations
                                                                    .of(context)
                                                                .getText(
                                                                    'bank0020')
                                                            : FFLocalizations
                                                                    .of(context)
                                                                .getText(
                                                                    '67uqdtth' /* Submit */),
                                                        options:
                                                            FFButtonOptions(
                                                          height: buttonHeight,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          iconPadding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  0, 0, 0, 0),
                                                          color: _model
                                                                  .isValidating
                                                              ? Colors.grey
                                                              : const Color(
                                                                  0xFFFF7F27),
                                                          textStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .interTight(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .fontStyle,
                                                                    ),
                                                                    color: Colors
                                                                        .white,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontStyle,
                                                                  ),
                                                          elevation: 0,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    height:
                                                        verticalSpacing * 0.75),
                                              ],
                                            )
                                          : Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Expanded(
                                                  child: FFButtonWidget(
                                                    onPressed: () {
                                                      context.pop();
                                                    },
                                                    text: FFLocalizations.of(
                                                            context)
                                                        .getText(
                                                            'wv7qy5fs' /* Cancel */),
                                                    options: FFButtonOptions(
                                                      height: buttonHeight,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      iconPadding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                              0, 0, 0, 0),
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .override(
                                                                font: GoogleFonts
                                                                    .interTight(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                              ),
                                                      elevation: 0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: FFButtonWidget(
                                                    onPressed:
                                                        _model.isValidating
                                                            ? null
                                                            : () {
                                                                _validateBankAccount();
                                                              },
                                                    text: _model.isValidating
                                                        ? FFLocalizations.of(
                                                                context)
                                                            .getText('bank0020')
                                                        : FFLocalizations.of(
                                                                context)
                                                            .getText(
                                                                '67uqdtth' /* Submit */),
                                                    options: FFButtonOptions(
                                                      height: buttonHeight,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      iconPadding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                              0, 0, 0, 0),
                                                      color: _model.isValidating
                                                          ? Colors.grey
                                                          : const Color(
                                                              0xFFFF7F27),
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .override(
                                                                font: GoogleFonts
                                                                    .interTight(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                                ),
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                              ),
                                                      elevation: 0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: verticalSpacing * 0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
