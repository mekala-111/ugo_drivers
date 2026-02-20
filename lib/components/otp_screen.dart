import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';

// --- The OTP Card Widget ---
class OtpVerificationSheet extends StatefulWidget {
  final List<TextEditingController> otpControllers;
  final VoidCallback onVerify;
  /// Dynamic OTP from ride (shown to driver if passenger shares it - Rapido style)
  final String? displayOtp;

  const OtpVerificationSheet({
    super.key,
    required this.otpControllers,
    required this.onVerify,
    this.displayOtp,
  });

  @override
  State<OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<OtpVerificationSheet> {
  // Colors from screenshot
  static const Color ugoGreen = AppColors.success;

  // Focus nodes for Rapido-style navigation
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    // Initialize 4 focus nodes
    _focusNodes = List.generate(4, (index) => FocusNode());
  }

  @override
  void dispose() {
    // Dispose focus nodes to prevent memory leaks
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This Padding adjusts the view when the keyboard is open, pushing the sheet up.
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Material(
            type: MaterialType.transparency,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Green Header Bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: const BoxDecoration(
                      color: ugoGreen,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      FFLocalizations.of(context).getText('drv_otp_title'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // "Enter OTP" Title
                        Text(
                          FFLocalizations.of(context).getText('drv_enter_otp'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        // Dynamic OTP display (Rapido-style - show if backend provides it)
                        if (widget.displayOtp != null && widget.displayOtp!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: ugoGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ugoGreen, width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.pin, color: ugoGreen, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "${FFLocalizations.of(context).getText('drv_ride_otp')}: ${widget.displayOtp}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // 4 OTP Boxes with Enhanced Logic
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(4, (index) {
                            return _buildOtpBox(index);
                          }),
                        ),

                        const SizedBox(height: 32),

                        // Verify Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: widget.onVerify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ugoGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.zero,
                              elevation: 0,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    FFLocalizations.of(context).getText('drv_verify'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Built with Rapido-like Focus Logic
  Widget _buildOtpBox(int index) {
    return KeyboardListener(
      focusNode: FocusNode(), // Consumes hardware events
      onKeyEvent: (event) {
        // Detect Backspace on Empty Field -> Move Previous
        if (event is KeyDownEvent) { // Updated from RawKeyDownEvent
          if (event.logicalKey == LogicalKeyboardKey.backspace) {
            if (widget.otpControllers[index].text.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        }
      },
      child: SizedBox(
        width: 50,
        height: 50,
        child: TextField(
          controller: widget.otpControllers[index],
          focusNode: _focusNodes[index],
          autofocus: index == 0,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ugoGreen, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ugoGreen, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ugoGreen, width: 1.5),
            ),
          ),
          onChanged: (value) {
            if (value.length == 1) {
              // Standard Typing: Move Next
              if (index < 3) {
                _focusNodes[index + 1].requestFocus();
              } else {
                // Last digit entered: Unfocus
                _focusNodes[index].unfocus();
                // widget.onVerify();
              }
            } else if (value.length > 1) {
              // Paste Logic
              if (value.length == 4 && index == 0) {
                for (int i = 0; i < 4; i++) {
                  widget.otpControllers[i].text = value[i];
                }
                _focusNodes[3].unfocus();
                widget.onVerify();
              } else {
                widget.otpControllers[index].text =
                    value.substring(value.length - 1);
                if (index < 3) _focusNodes[index + 1].requestFocus();
              }
            } else if (value.isEmpty && index > 0) {
              // Backspace cleared the field: Move Previous
              _focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }
}
