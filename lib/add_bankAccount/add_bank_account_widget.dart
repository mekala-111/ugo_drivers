import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/api_requests/api_calls.dart';
import 'dart:ui';
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
          _model.validatedBankName = bankName ?? 'Unknown Bank';
          _model.isValidating = false;
        });

        // Show success dialog with bank details
        if (mounted) {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Bank Verified ✓'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bank: ${_model.validatedBankName}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (branchName != null && branchName != '')
                    Text('Branch: $branchName'),
                  if (city != null && city != '') Text('City: $city'),
                  const SizedBox(height: 8),
                  Text('IFSC: $ifscCode'),
                  const SizedBox(height: 8),
                  Text(
                      'Account: ****${accountNumber.substring(accountNumber.length - 4)}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    // Proceed with bank account submission
                    _submitBankAccount();
                  },
                  child: const Text('Confirm'),
                ),
              ],
            ),
          );
        }
      } else {
        // Get error details from response
        String errorMessage = 'Invalid IFSC code';

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
              content: Text('IFSC Validation Error: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _model.validationError = 'Error: ${e.toString()}';
        _model.isValidating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${_model.validationError}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submitBankAccount() {
    // TODO: Add your logic here to submit the bank account details
    // This could be saving to database or calling another API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bank account added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isTablet = size.width >= 600;
    final scale = isTablet
        ? 1.1
        : isSmallScreen
            ? 0.9
            : 1.0;
    final horizontalPadding = isTablet
        ? 32.0
        : isSmallScreen
            ? 16.0
            : 20.0;
    final fieldHorizontalPadding = isTablet
        ? 48.0
        : isSmallScreen
            ? 20.0
            : 32.0;
    final contentMaxWidth = isTablet ? 640.0 : double.infinity;
    final buttonHeight = 50.0 * scale;
    final cancelButtonWidth = isSmallScreen ? double.infinity : 120.0;
    final submitButtonWidth = isSmallScreen ? double.infinity : 200.0;

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
          actions: [],
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
                                            height: 50.0 * scale,
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
                                                  return 'Full name is required.';
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
                                                fillColor:
                                                    const Color(0xFFF5F5F5),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
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
                                    SizedBox(height: 16.0 * scale),
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
                                            height: 50.0 * scale,
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
                                                  return 'Account number is required.';
                                                }
                                                if (trimmed.length < 9 ||
                                                    trimmed.length > 18) {
                                                  return 'Account number must be 9 to 18 digits.';
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
                                                fillColor:
                                                    const Color(0xFFF5F5F5),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
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
                                    SizedBox(height: 16.0 * scale),
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
                                            height: 50.0 * scale,
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
                                                  return 'Please confirm account number.';
                                                }
                                                if (trimmed != original) {
                                                  return 'Account numbers do not match.';
                                                }
                                                return null;
                                              },
                                              onFieldSubmitted: (_) {
                                                _model.bankIfscCodeFocusNode
                                                    ?.requestFocus();
                                              },
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    const Color(0xFFF5F5F5),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
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
                                    SizedBox(height: 16.0 * scale),
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
                                            height: 50.0 * scale,
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
                                                  return 'IFSC code is required.';
                                                }
                                                final regex = RegExp(
                                                    r'^[A-Z]{4}0[A-Z0-9]{6}$');
                                                if (!regex.hasMatch(
                                                    trimmed.toUpperCase())) {
                                                  return 'Enter a valid IFSC code.';
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    const Color(0xFFF5F5F5),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
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
                                    SizedBox(height: 16.0 * scale),
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
                                                FFButtonWidget(
                                                  onPressed: () {
                                                    context.pop();
                                                  },
                                                  text: FFLocalizations.of(
                                                          context)
                                                      .getText(
                                                    'wv7qy5fs' /* Cancel */,
                                                  ),
                                                  options: FFButtonOptions(
                                                    width: cancelButtonWidth,
                                                    height: buttonHeight,
                                                    padding: EdgeInsets.all(8),
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 0, 0, 0),
                                                    color: FlutterFlowTheme.of(
                                                            context)
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
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryText,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
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
                                                SizedBox(height: 12.0 * scale),
                                                FFButtonWidget(
                                                  onPressed: _model.isValidating
                                                      ? null
                                                      : () {
                                                          _validateBankAccount();
                                                        },
                                                  text: _model.isValidating
                                                      ? 'Validating...'
                                                      : FFLocalizations.of(
                                                              context)
                                                          .getText(
                                                          '67uqdtth' /* Submit */,
                                                        ),
                                                  options: FFButtonOptions(
                                                    width: submitButtonWidth,
                                                    height: buttonHeight,
                                                    padding: EdgeInsets.all(8),
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 0, 0, 0),
                                                    color: _model.isValidating
                                                        ? Colors.grey
                                                        : const Color(
                                                            0xFFFF7F27),
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .interTight(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                          ),
                                                          color: Colors.white,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
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
                                              ],
                                            )
                                          : Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                FFButtonWidget(
                                                  onPressed: () {
                                                    context.pop();
                                                  },
                                                  text: FFLocalizations.of(
                                                          context)
                                                      .getText(
                                                    'wv7qy5fs' /* Cancel */,
                                                  ),
                                                  options: FFButtonOptions(
                                                    width: cancelButtonWidth,
                                                    height: buttonHeight,
                                                    padding: EdgeInsets.all(8),
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 0, 0, 0),
                                                    color: FlutterFlowTheme.of(
                                                            context)
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
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryText,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
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
                                                FFButtonWidget(
                                                  onPressed: _model.isValidating
                                                      ? null
                                                      : () {
                                                          _validateBankAccount();
                                                        },
                                                  text: _model.isValidating
                                                      ? 'Validating...'
                                                      : FFLocalizations.of(
                                                              context)
                                                          .getText(
                                                          '67uqdtth' /* Submit */,
                                                        ),
                                                  options: FFButtonOptions(
                                                    width: submitButtonWidth,
                                                    height: buttonHeight,
                                                    padding: EdgeInsets.all(8),
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 0, 0, 0),
                                                    color: _model.isValidating
                                                        ? Colors.grey
                                                        : const Color(
                                                            0xFFFF7F27),
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .interTight(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                          ),
                                                          color: Colors.white,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
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
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.0 * scale),
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
