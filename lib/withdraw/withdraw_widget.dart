import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
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

    // Initialize amount text controller with wallet amount if provided
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

      final response = await GetWalletCall.call(driverId: driverId, token: token);
      if (!response.succeeded || !mounted) return;

      final raw = GetWalletCall.walletBalance(response.jsonBody);
      final parsed = double.tryParse(raw?.toString() ?? '');
      if (parsed == null) return;

      setState(() {
        _availableBalance = parsed;
        final minRaw = getJsonField(response.jsonBody, r'$.data.limits.min_withdrawal');
        final maxRaw = getJsonField(response.jsonBody, r'$.data.limits.max_withdrawable');
        _minWithdrawal = double.tryParse(minRaw?.toString() ?? '') ?? _minWithdrawal;
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

    final allowedMax = _maxWithdrawable > 0 ? _maxWithdrawable : _availableBalance;
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
        final newBalanceRaw = getJsonField(response.jsonBody, r'$.data.wallet_balance');
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
              'u0xnthuk' /* Withdraw */,
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
          centerTitle: true,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${_availableBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Withdraw To',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyDark,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: [
                    ChoiceChip(
                      label: const Text('Bank Account'),
                      selected: _withdrawalMethod == 'bank',
                      onSelected: (v) {
                        if (!v) return;
                        setState(() => _withdrawalMethod = 'bank');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('UPI'),
                      selected: _withdrawalMethod == 'upi',
                      onSelected: (v) {
                        if (!v) return;
                        setState(() => _withdrawalMethod = 'upi');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Enter amount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.greyMid,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextFormField(
                      controller: _model.textController1,
                      focusNode: _model.textFieldFocusNode1,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d\.,₹ ]')),
                      ],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '₹0',
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greyDark,
                      ),
                      onChanged: (_) => setState(() {}),
                      validator:
                          _model.textController1Validator.asValidator(context),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final amt in <double>[100, 200, 500, _availableBalance])
                      ActionChip(
                        label: Text(
                          amt == _availableBalance
                              ? 'Full Amount'
                              : '₹${amt.toStringAsFixed(0)}',
                        ),
                        onPressed: _availableBalance > 0
                            ? () => _setQuickAmount(amt)
                            : null,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Min ₹${_minWithdrawal.toStringAsFixed(0)} • Max ₹${(_maxWithdrawable > 0 ? _maxWithdrawable : _availableBalance).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                if (_withdrawalMethod == 'bank')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.greyMid),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payout bank account',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greyDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bankHolderName?.isNotEmpty == true
                              ? bankHolderName!
                              : 'Account holder not set',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_maskAccountNumber(bankAccountNumber) ?? 'No bank account'}  •  ${ifscCode ?? '-'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.greyMid),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'UPI ID',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greyDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _upiController,
                          decoration: const InputDecoration(
                            hintText: 'example@upi',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'UPI withdrawals are free.',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                FFButtonWidget(
                  onPressed: _isSubmitting ? null : _submitWithdraw,
                  text: _isSubmitting ? 'Processing...' : 'Withdraw',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 52,
                    color: AppColors.primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.w700,
                          ),
                          color: Colors.white,
                          letterSpacing: 0,
                        ),
                    elevation: 0,
                    borderRadius: BorderRadius.circular(10),
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
