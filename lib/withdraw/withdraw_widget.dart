import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_requests/api_calls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'withdraw_model.dart';
export 'withdraw_model.dart';

class WithdrawWidget extends StatefulWidget {
  const WithdrawWidget({
    super.key,
    this.bankAccountNumber,
    this.ifscCode,
    this.accountHolderName,
    this.fundAccountId,
    this.walletAmount,
  });

  final String? bankAccountNumber;
  final String? ifscCode;
  final String? accountHolderName;
  final String? fundAccountId;
  final String? walletAmount;

  static String routeName = 'Withdraw';
  static String routePath = '/withdraw';

  @override
  State<WithdrawWidget> createState() => _WithdrawWidgetState();
}

class _WithdrawWidgetState extends State<WithdrawWidget> {
  late WithdrawModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const double _cardRadius = 20;
  static const double _fieldRadius = 14;

  String? bankAccountNumber;
  String? ifscCode;
  String? bankHolderName;
  String? fundAccountId;
  bool _isSubmitting = false;
  double _availableBalance = 0;
  double _minWithdrawal = 1;
  double _maxWithdrawable = 0;
  String _withdrawalMethod = 'bank';
  final TextEditingController _upiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WithdrawModel());

    if (kDebugMode) {
      debugPrint(
          '💰 WithdrawWidget received walletAmount: "${widget.walletAmount}"');
    }

    _availableBalance = double.tryParse(widget.walletAmount ?? '') ?? 0;

    _model.textController1 ??= TextEditingController(
      text: widget.walletAmount ?? '',
    );
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();
    _fetchAvailableBalance();

    if (widget.bankAccountNumber != null &&
        widget.bankAccountNumber!.isNotEmpty) {
      bankAccountNumber = widget.bankAccountNumber;
      ifscCode = widget.ifscCode;
      bankHolderName = widget.accountHolderName;
      fundAccountId = widget.fundAccountId;

      final maskedAccount = _maskAccountNumber(bankAccountNumber);
      _model.textController2?.text = maskedAccount ?? '';
      _model.textController3?.text = ifscCode ?? '';
    } else {
      _fetchBankAccount();
    }
  }

  @override
  void dispose() {
    _upiController.dispose();
    _model.dispose();

    super.dispose();
  }

  Widget _sectionLabel(String text) {
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

  InputDecoration _amountDecoration() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      hintText: '₹0',
      hintStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.greyLight,
      ),
      prefixIcon: Icon(
        Icons.currency_rupee_rounded,
        color: AppColors.primary.withValues(alpha: 0.9),
        size: 26,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
    );
  }

  InputDecoration _upiDecoration() {
    return InputDecoration(
      isDense: true,
      hintText: 'example@upi',
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(
        Icons.qr_code_2_rounded,
        color: AppColors.primary.withValues(alpha: 0.9),
        size: 22,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
          const Icon(Icons.verified_user_outlined,
              color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure payout',
                  style: GoogleFonts.interTight(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Money is sent only to your verified bank or UPI. Razorpay-powered transfers.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.35,
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

  Widget _buildBalanceHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_cardRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGradientStart,
            AppColors.primary,
            AppColors.accentCoral,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available balance',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${_availableBalance.toStringAsFixed(2)}',
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodChips() {
    Widget chip({
      required String label,
      required IconData icon,
      required bool selected,
      required String method,
    }) {
      return ChoiceChip(
        avatar: Icon(
          icon,
          size: 18,
          color: selected ? AppColors.primary : AppColors.greySlate,
        ),
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppColors.primary.withValues(alpha: 0.18),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.greyBorder,
          width: selected ? 1.5 : 1,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.primary : AppColors.textDark,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onSelected: (v) {
          if (!v) return;
          setState(() => _withdrawalMethod = method);
        },
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        chip(
          label: 'Bank account',
          icon: Icons.account_balance_outlined,
          selected: _withdrawalMethod == 'bank',
          method: 'bank',
        ),
        chip(
          label: 'UPI',
          icon: Icons.flash_on_rounded,
          selected: _withdrawalMethod == 'upi',
          method: 'upi',
        ),
      ],
    );
  }

  Widget _buildQuickAmounts() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final amt in <double>[100, 200, 500, _availableBalance])
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _availableBalance > 0 ? () => _setQuickAmount(amt) : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.sectionOrangeTint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _availableBalance > 0
                        ? AppColors.primary.withValues(alpha: 0.45)
                        : AppColors.greyBorder,
                  ),
                ),
                child: Text(
                  amt == _availableBalance
                      ? 'Full amount'
                      : '₹${amt.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _availableBalance > 0
                        ? AppColors.primary
                        : AppColors.greyLight,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBankDestinationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: AppColors.greyBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.savings_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Payout bank account',
                style: GoogleFonts.interTight(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            bankHolderName?.isNotEmpty == true
                ? bankHolderName!
                : 'Account holder not set',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_maskAccountNumber(bankAccountNumber) ?? 'No bank account'}  •  ${ifscCode ?? '-'}',
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.4,
              color: AppColors.greySlate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpiDestinationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: AppColors.greyBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentIndigo.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: AppColors.accentIndigo,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'UPI ID',
                style: GoogleFonts.interTight(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _upiController,
            decoration: _upiDecoration(),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 10),
          Text(
            'UPI withdrawals are free. Use the ID linked to your bank.',
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.35,
              color: AppColors.greySlate,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchBankAccount() async {
    try {
      final driverId = FFAppState().driverid.toString();
      if (driverId.isEmpty || driverId == '0') {
        return;
      }

      final response = await BankAccountCall.call(
        driverId: driverId,
        token: FFAppState().accessToken,
      );

      if (!response.succeeded) {
        if (kDebugMode) {
          debugPrint('❌ Failed to fetch bank account for withdraw');
          debugPrint('   Status: ${response.statusCode}');
        }
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        bankAccountNumber =
            BankAccountCall.bankAccountNumber(response.jsonBody);
        ifscCode = BankAccountCall.ifscCode(response.jsonBody);
        bankHolderName = BankAccountCall.accountHolderName(response.jsonBody);
        fundAccountId = BankAccountCall.fundAccountId(response.jsonBody);
        final savedUpi = BankAccountCall.upiId(response.jsonBody);
        if (savedUpi != null && savedUpi.isNotEmpty) {
          _upiController.text = savedUpi;
        }

        final maskedAccount = _maskAccountNumber(bankAccountNumber);
        _model.textController2?.text = maskedAccount ?? '';
        _model.textController3?.text = ifscCode ?? '';
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching bank account: $e');
      }
    }
  }

  Future<void> _fetchAvailableBalance() async {
    try {
      final driverId = int.tryParse(FFAppState().driverid.toString());
      final token = FFAppState().accessToken;
      if (driverId == null || token.isEmpty) return;

      final response =
          await GetWalletCall.call(driverId: driverId, token: token);
      if (!response.succeeded || !mounted) return;

      final raw = GetWalletCall.walletBalance(response.jsonBody);
      final parsed = double.tryParse(raw?.toString() ?? '');
      if (parsed == null) return;

      setState(() {
        _availableBalance = parsed;
        final minRaw =
            getJsonField(response.jsonBody, r'$.data.limits.min_withdrawal');
        final maxRaw =
            getJsonField(response.jsonBody, r'$.data.limits.max_withdrawable');
        _minWithdrawal =
            double.tryParse(minRaw?.toString() ?? '') ?? _minWithdrawal;
        _maxWithdrawable = double.tryParse(maxRaw?.toString() ?? '') ?? parsed;
        if ((_model.textController1?.text.trim().isEmpty ?? true)) {
          _model.textController1?.text = _maxWithdrawable.toStringAsFixed(0);
        }
      });
    } catch (_) {}
  }

  String? _maskAccountNumber(String? accountNumber) {
    if (accountNumber == null || accountNumber.isEmpty) {
      return null;
    }
    if (accountNumber.length <= 4) {
      return accountNumber;
    }
    final last4 = accountNumber.substring(accountNumber.length - 4);
    return '************$last4';
  }

  String _normalizeAmount(String input) {
    final cleaned = input.replaceAll(',', '.');
    final digitsOnly = cleaned.replaceAll(RegExp(r'[^0-9.]'), '');
    if (!digitsOnly.contains('.')) {
      return digitsOnly;
    }
    final parts = digitsOnly.split('.');
    return '${parts.first}.${parts.skip(1).join()}';
  }

  void _setQuickAmount(double value) {
    final safe = value <= _availableBalance ? value : _availableBalance;
    _model.textController1?.text = safe.toStringAsFixed(0);
    _model.textController1?.selection = TextSelection.fromPosition(
      TextPosition(offset: _model.textController1?.text.length ?? 0),
    );
    setState(() {});
  }

  Future<void> _submitWithdraw() async {
    if (_isSubmitting) {
      return;
    }

    final rawAmountText = _model.textController1?.text.trim() ?? '';
    final normalizedAmountText = _normalizeAmount(rawAmountText);
    final amountValue = num.tryParse(normalizedAmountText);
    debugPrint(
        '💰 Withdraw amount input: "$rawAmountText" → normalized: "$normalizedAmountText" → parsed: $amountValue');
    if (amountValue == null || amountValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid amount to withdraw.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final allowedMax =
        _maxWithdrawable > 0 ? _maxWithdrawable : _availableBalance;
    if (amountValue > allowedMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Amount exceeds max withdrawable (₹${allowedMax.toStringAsFixed(2)}).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (amountValue < _minWithdrawal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Minimum withdrawal amount is ₹${_minWithdrawal.toStringAsFixed(0)}.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (bankAccountNumber == null || bankAccountNumber!.isEmpty) {
      if (_withdrawalMethod == 'bank') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add a bank account before bank withdrawal.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final upiId = _upiController.text.trim();
    if (_withdrawalMethod == 'upi') {
      final upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');
      if (!upiRegex.hasMatch(upiId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter a valid UPI ID (example@upi).'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final driverId = FFAppState().driverid;
    if (driverId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver ID missing. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await RazorpayPayoutCall.call(
        driverId: driverId,
        amount: amountValue,
        fundAccountId: fundAccountId,
        withdrawalMethod: _withdrawalMethod,
        upiId: _withdrawalMethod == 'upi' ? upiId : null,
        token: FFAppState().accessToken,
      );

      if (response.succeeded) {
        final message = RazorpayPayoutCall.message(response.jsonBody) ??
            'Withdraw request submitted.';
        final newBalanceRaw =
            getJsonField(response.jsonBody, r'$.data.wallet_balance');
        final newBalance = double.tryParse(newBalanceRaw?.toString() ?? '');
        if (mounted) {
          if (newBalance != null) {
            setState(() {
              _availableBalance = newBalance;
              _maxWithdrawable = newBalance;
              _model.textController1?.clear();
            });
          } else {
            _fetchAvailableBalance();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } else {
        final message = RazorpayPayoutCall.message(response.jsonBody) ??
            'Withdraw request failed.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
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

    final scale = isLargeTablet
        ? 1.2
        : isTablet
            ? 1.1
            : isMediumScreen
                ? 1.0
                : 0.9;

    final horizontalPadding = isLargeTablet
        ? 48.0
        : isTablet
            ? 32.0
            : isMediumScreen
                ? 20.0
                : 16.0;

    final verticalSpacing = isLandscape ? 12.0 * scale : 16.0 * scale;
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
            crossAxisAlignment: isSmallScreen
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                FFLocalizations.of(context).getText(
                  'u0xnthuk' /* Withdraw */,
                ),
                style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Fast payout · Bank or UPI',
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
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentMaxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTrustBanner(),
                          SizedBox(height: verticalSpacing),
                          _buildBalanceHero(),
                          SizedBox(height: verticalSpacing),
                          _sectionLabel('Withdraw to'),
                          _buildMethodChips(),
                          SizedBox(height: verticalSpacing),
                          _sectionLabel('Amount'),
                          TextFormField(
                            controller: _model.textController1,
                            focusNode: _model.textFieldFocusNode1,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d\.,₹ ]')),
                            ],
                            decoration: _amountDecoration(),
                            style: GoogleFonts.interTight(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                            onChanged: (_) => setState(() {}),
                            validator: _model.textController1Validator
                                .asValidator(context),
                          ),
                          const SizedBox(height: 12),
                          _buildQuickAmounts(),
                          const SizedBox(height: 10),
                          Text(
                            'Min ₹${_minWithdrawal.toStringAsFixed(0)} · Max ₹${(_maxWithdrawable > 0 ? _maxWithdrawable : _availableBalance).toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greySlate,
                            ),
                          ),
                          SizedBox(height: verticalSpacing),
                          if (_withdrawalMethod == 'bank')
                            _buildBankDestinationCard()
                          else
                            _buildUpiDestinationCard(),
                          SizedBox(height: verticalSpacing + 8),
                          SizedBox(
                            height: buttonHeight,
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _isSubmitting ? null : _submitWithdraw,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    AppColors.primary.withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(_fieldRadius),
                                ),
                                elevation: 0,
                              ),
                              child: _isSubmitting
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white
                                            .withValues(alpha: 0.95),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.payments_rounded,
                                            size: 22),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Withdraw',
                                          style: GoogleFonts.interTight(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
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
