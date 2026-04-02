import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
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

  static const double _cardRadius = 20;
  static const double _fieldRadius = 14;

  InputDecoration _fieldDecoration(BuildContext context, {IconData? icon}) {
    return InputDecoration(
      isDense: true,
      prefixIcon: icon != null
          ? Icon(icon,
              color: AppColors.primary.withValues(alpha: 0.9), size: 22)
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: const BorderSide(color: AppColors.greyBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: const BorderSide(color: AppColors.greyBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }

  Widget _fieldLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _dialogDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.greySlate),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.35,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_fieldRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safe & verified',
                  style: GoogleFonts.interTight(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We validate your IFSC with Razorpay before saving. Your payout goes only to this account.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.greySlate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, double verticalSpacing) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: AppColors.greyBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.sectionOrangeTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bank account',
                      style: GoogleFonts.interTight(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Match your passbook exactly',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.greySlate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: verticalSpacing + 6),
          _fieldLabel(context, FFLocalizations.of(context).getText('z3yviii2')),
          TextFormField(
            controller: _model.bankHolderNameController,
            focusNode: _model.bankHolderNameFocusNode,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return FFLocalizations.of(context).getText('bank0013');
              }
              return null;
            },
            onFieldSubmitted: (_) {
              _model.bankAccountNumberFocusNode?.requestFocus();
            },
            decoration:
                _fieldDecoration(context, icon: Icons.person_outline_rounded)
                    .copyWith(
              hintText: FFLocalizations.of(context).getText('z3yviii2'),
            ),
            style: GoogleFonts.inter(fontSize: 15),
          ),
          SizedBox(height: verticalSpacing),
          _fieldLabel(context, FFLocalizations.of(context).getText('vwehe0jg')),
          TextFormField(
            controller: _model.bankAccountNumberController,
            focusNode: _model.bankAccountNumberFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) {
                return FFLocalizations.of(context).getText('bank0014');
              }
              if (trimmed.length < 9 || trimmed.length > 18) {
                return FFLocalizations.of(context).getText('bank0015');
              }
              return null;
            },
            onFieldSubmitted: (_) {
              _model.confirmBankAccountNumberFocusNode?.requestFocus();
            },
            decoration: _fieldDecoration(context, icon: Icons.tag_rounded)
                .copyWith(hintText: '9–18 digits'),
            style: GoogleFonts.inter(fontSize: 15, letterSpacing: 0.6),
          ),
          SizedBox(height: verticalSpacing),
          _fieldLabel(context, FFLocalizations.of(context).getText('6kj7r3jn')),
          TextFormField(
            controller: _model.confirmBankAccountNumberController,
            focusNode: _model.confirmBankAccountNumberFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              final original = _model.bankAccountNumberController.text.trim();
              if (trimmed.isEmpty) {
                return FFLocalizations.of(context).getText('bank0016');
              }
              if (trimmed != original) {
                return FFLocalizations.of(context).getText('bank0017');
              }
              return null;
            },
            onFieldSubmitted: (_) {
              _model.bankIfscCodeFocusNode?.requestFocus();
            },
            decoration: _fieldDecoration(context, icon: Icons.repeat_rounded)
                .copyWith(hintText: 'Same as above'),
            style: GoogleFonts.inter(fontSize: 15, letterSpacing: 0.6),
          ),
          SizedBox(height: verticalSpacing),
          _fieldLabel(context, FFLocalizations.of(context).getText('l1eb56jt')),
          TextFormField(
            controller: _model.bankIfscCodeController,
            focusNode: _model.bankIfscCodeFocusNode,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) {
                return FFLocalizations.of(context).getText('bank0018');
              }
              final regex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
              if (!regex.hasMatch(trimmed.toUpperCase())) {
                return FFLocalizations.of(context).getText('bank0019');
              }
              return null;
            },
            decoration: _fieldDecoration(context, icon: Icons.qr_code_2_rounded)
                .copyWith(
              hintText: 'e.g. HDFC0001234',
              helperText: '11 characters · printed on cheque',
              helperStyle: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.greySlate,
              ),
            ),
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, double buttonHeight) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: buttonHeight,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textDark,
                side: const BorderSide(color: AppColors.greyBorder, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_fieldRadius),
                ),
              ),
              child: Text(
                FFLocalizations.of(context).getText('wv7qy5fs'),
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: buttonHeight,
            child: FilledButton.icon(
              onPressed:
                  _model.isValidating ? null : () => _validateBankAccount(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.grey,
                elevation: 2,
                shadowColor: AppColors.primary.withValues(alpha: 0.45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_fieldRadius),
                ),
              ),
              icon: _model.isValidating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.verified_rounded, size: 22),
              label: Text(
                _model.isValidating
                    ? FFLocalizations.of(context).getText('bank0020')
                    : FFLocalizations.of(context).getText('67uqdtth'),
                style: GoogleFonts.interTight(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionColumn(BuildContext context, double buttonHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: buttonHeight,
          child: FilledButton.icon(
            onPressed:
                _model.isValidating ? null : () => _validateBankAccount(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.grey,
              elevation: 2,
              shadowColor: AppColors.primary.withValues(alpha: 0.45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_fieldRadius),
              ),
            ),
            icon: _model.isValidating
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.verified_rounded, size: 22),
            label: Text(
              _model.isValidating
                  ? FFLocalizations.of(context).getText('bank0020')
                  : FFLocalizations.of(context).getText('67uqdtth'),
              style: GoogleFonts.interTight(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: buttonHeight,
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textDark,
              side: const BorderSide(color: AppColors.greyBorder, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_fieldRadius),
              ),
            ),
            child: Text(
              FFLocalizations.of(context).getText('wv7qy5fs'),
              style: GoogleFonts.interTight(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
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

        if (mounted) {
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_cardRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: AppColors.sectionGreenTint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: AppColors.success,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      FFLocalizations.of(context).getText('bank0002'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.interTight(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      FFLocalizations.of(context)
                          .getText('bank0003')
                          .replaceAll('%1', _model.validatedBankName ?? ''),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(_fieldRadius),
                        border: Border.all(color: AppColors.greyBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (branchName != null && branchName != '')
                            _dialogDetailRow(
                              Icons.store_mall_directory_outlined,
                              FFLocalizations.of(context)
                                  .getText('bank0004')
                                  .replaceAll('%1', branchName),
                            ),
                          if (city != null && city != '') ...[
                            if (branchName != null && branchName != '')
                              const SizedBox(height: 10),
                            _dialogDetailRow(
                              Icons.location_city_outlined,
                              FFLocalizations.of(context)
                                  .getText('bank0005')
                                  .replaceAll('%1', city),
                            ),
                          ],
                          const SizedBox(height: 10),
                          _dialogDetailRow(
                            Icons.tag_rounded,
                            FFLocalizations.of(context)
                                .getText('bank0006')
                                .replaceAll('%1', ifscCode),
                          ),
                          const SizedBox(height: 10),
                          _dialogDetailRow(
                            Icons.pin_rounded,
                            FFLocalizations.of(context)
                                .getText('bank0007')
                                .replaceAll(
                                  '%1',
                                  accountNumber
                                      .substring(accountNumber.length - 4),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await _submitBankAccount();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_fieldRadius),
                          ),
                        ),
                        child: Text(
                          FFLocalizations.of(context).getText('bank0008'),
                          style: GoogleFonts.interTight(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
    final verticalSpacing = isLandscape ? 12.0 * scale : 16.0 * scale;

    // Responsive content width
    final contentMaxWidth = isLargeTablet
        ? 800.0
        : isTablet
            ? 640.0
            : double.infinity;

    final buttonHeight = isLandscape ? 48.0 * scale : 52.0 * scale;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryGradientStart,
                  AppColors.primary,
                  AppColors.accentCoral,
                ],
              ),
            ),
          ),
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30,
            borderWidth: 1,
            buttonSize: 52,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () => context.pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                FFLocalizations.of(context).getText('wlxvqket'),
                style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Secure verification · Encrypted details',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          centerTitle: false,
          titleSpacing: 0,
        ),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF7ED),
                AppColors.backgroundLight,
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    28,
                  ),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight - 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTrustBanner(),
                              SizedBox(height: verticalSpacing),
                              _buildFormCard(context, verticalSpacing),
                              SizedBox(height: verticalSpacing + 10),
                              if (isSmallScreen)
                                _buildActionColumn(context, buttonHeight)
                              else
                                _buildActionRow(context, buttonHeight),
                              const SizedBox(height: 16),
                            ],
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
      ),
    );
  }
}
