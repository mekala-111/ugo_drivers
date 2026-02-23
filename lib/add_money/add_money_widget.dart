import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/constants/app_colors.dart';
import '/config.dart' as app_config;
import '/backend/api_requests/api_calls.dart';

class AddMoneyWidget extends StatefulWidget {
  const AddMoneyWidget({super.key});

  static String routeName = 'AddMoney';
  static String routePath = '/addMoney';

  @override
  State<AddMoneyWidget> createState() => _AddMoneyWidgetState();
}

class _AddMoneyWidgetState extends State<AddMoneyWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Razorpay instance
  late Razorpay _razorpay;
  bool _isProcessing = false;

  // Quick amount buttons
  final List<int> quickAmounts = [100, 200, 500, 1000, 2000, 5000];
  int? selectedAmount;

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    super.dispose();
  }

  // Handle successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (kDebugMode) {
      print('✅ Payment Success: ${response.paymentId}');
    }

    setState(() => _isProcessing = true);

    try {
      // Call backend API to update wallet balance
      final driverIdValue = FFAppState().driverid;
      final driverId = int.tryParse(driverIdValue.toString());
      final amount = double.tryParse(_amountController.text) ?? 0.0;

      if (driverId != null && amount > 0) {
        // Call API to add money to wallet
        final apiResponse = await AddMoneyToWalletCall.call(
          driverId: driverId,
          amount: amount,
          currency: 'INR',
          token: FFAppState().accessToken,
        );

        if (mounted) {
          if (apiResponse.succeeded &&
              AddMoneyToWalletCall.success(apiResponse.jsonBody) == true) {
            // Success - wallet credited
            final newBalance =
                AddMoneyToWalletCall.newBalance(apiResponse.jsonBody);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '₹${amount.toStringAsFixed(0)} added successfully!\\nNew Balance: ₹${newBalance?.toStringAsFixed(0) ?? "0"}'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 3),
              ),
            );

            // Go back to wallet screen (it will refresh automatically)
            await Future.delayed(const Duration(milliseconds: 1500));
            if (mounted) context.pop();
          } else {
            // API call succeeded but wallet update failed
            final errorMessage =
                AddMoneyToWalletCall.message(apiResponse.jsonBody) ??
                    'Failed to update wallet';

            if (kDebugMode) print('❌ Wallet update failed: $errorMessage');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Payment successful but failed to update wallet: $errorMessage\\nPlease contact support with Payment ID: ${response.paymentId}'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid user or amount'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error updating wallet: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Payment successful but failed to update wallet: $e\\nPlease contact support with Payment ID: ${response.paymentId}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // Handle payment error/failure
  void _handlePaymentError(PaymentFailureResponse response) {
    if (kDebugMode) {
      print('❌ Payment Error: ${response.code} - ${response.message}');
    }

    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Payment failed: ${response.message ?? "Unknown error"}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Handle external wallet selection
  void _handleExternalWallet(ExternalWalletResponse response) {
    if (kDebugMode) {
      print('🔗 External Wallet: ${response.walletName}');
    }

    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External wallet selected: ${response.walletName}'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  // Open Razorpay checkout
  void _openRazorpayCheckout() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Get Razorpay key from Config (Firebase Remote Config)
    final razorpayKey = app_config.Config.razorpayKeyId;
    if (razorpayKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment gateway not configured. Contact support.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    var options = {
      'key': razorpayKey,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Ugo Driver',
      'description': 'Add Money to Wallet',
      'prefill': {
        'contact': FFAppState().mobileNo.toString(),
        'email': FFAppState().email,
      },
      'theme': {
        'color': '#${AppColors.primary.value.toRadixString(16).substring(2)}',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      if (kDebugMode) print('❌ Error opening Razorpay: $e');
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to open payment gateway'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final scale = isSmallScreen ? 0.9 : 1.0;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.backgroundAlt,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Add Money',
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 20.0 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: _isProcessing
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text('Processing payment...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(20.0 * scale),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.0 * scale),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.primary,
                              size: 24.0 * scale,
                            ),
                            SizedBox(width: 12.0 * scale),
                            Expanded(
                              child: Text(
                                'Add money securely to your wallet using Razorpay',
                                style: GoogleFonts.inter(
                                  fontSize: 13.0 * scale,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.0 * scale),

                      // Amount input
                      Text(
                        'Enter Amount',
                        style: GoogleFonts.inter(
                          fontSize: 16.0 * scale,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.0 * scale),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(
                          fontSize: 18.0 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.currency_rupee,
                            color: AppColors.primary,
                            size: 24.0 * scale,
                          ),
                          hintText: '0',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount < 1) {
                            return 'Please enter valid amount (min ₹1)';
                          }
                          if (amount > 50000) {
                            return 'Maximum amount is ₹50,000';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedAmount = null;
                          });
                        },
                      ),
                      SizedBox(height: 24.0 * scale),

                      // Quick amount buttons
                      Text(
                        'Quick Select',
                        style: GoogleFonts.inter(
                          fontSize: 16.0 * scale,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.0 * scale),
                      Wrap(
                        spacing: 8.0 * scale,
                        runSpacing: 8.0 * scale,
                        children: quickAmounts.map((amount) {
                          final isSelected = selectedAmount == amount;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedAmount = amount;
                                _amountController.text = amount.toString();
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.0 * scale,
                                vertical: 12.0 * scale,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                '₹$amount',
                                style: GoogleFonts.inter(
                                  fontSize: 14.0 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 32.0 * scale),

                      // Add money button
                      SizedBox(
                        width: double.infinity,
                        height: 50.0 * scale,
                        child: ElevatedButton(
                          onPressed: _openRazorpayCheckout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Add Money',
                            style: GoogleFonts.inter(
                              fontSize: 16.0 * scale,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0 * scale),

                      // Secure payment info
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 16.0 * scale,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 6.0 * scale),
                            Text(
                              'Secured by Razorpay',
                              style: GoogleFonts.inter(
                                fontSize: 12.0 * scale,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
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
