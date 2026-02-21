import 'package:ugo_driver/index.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_requests/api_calls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wallet_model.dart';
export 'wallet_model.dart';

class WalletWidget extends StatefulWidget {
  const WalletWidget({super.key});

  static String routeName = 'Wallet';
  static String routePath = '/wallet';

  @override
  State<WalletWidget> createState() => _WalletWidgetState();
}

class _WalletWidgetState extends State<WalletWidget> {
  late WalletModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // 🎨 UGO BRAND COLORS
  final Color ugoOrange = AppColors.primary;
  final Color ugoOrangeLight = AppColors.primaryLight;
  final Color ugoGreen = AppColors.success;
  final Color ugoRed = AppColors.error;

  // Bank Account Data
  String? bankAccountNumber;
  String? ifscCode;
  String? bankName;
  String? accountHolderName;
  String? fundAccountId;
  String? walletBalance;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WalletModel());
    _fetchBankAccount();
    _fetchWallet();
  }

  // 🏦 Fetch bank account details from API
  Future<void> _fetchBankAccount() async {
    try {
      // Get driver ID from app state - handle both int and String types
      final driverIdValue = FFAppState().driverid;

      // Convert to String (handles both int and String types)
      final driverId = driverIdValue.toString();

      if (driverId.isEmpty) {
        if (kDebugMode) print('Driver ID is empty');
        return;
      }

      final response = await BankAccountCall.call(
          driverId: driverId, token: FFAppState().accessToken);

      if (response.succeeded) {
        setState(() {
          bankAccountNumber =
              BankAccountCall.bankAccountNumber(response.jsonBody);
          ifscCode = BankAccountCall.ifscCode(response.jsonBody);
          bankName = BankAccountCall.bankName(response.jsonBody);
          accountHolderName =
              BankAccountCall.accountHolderName(response.jsonBody);
          fundAccountId = BankAccountCall.fundAccountId(response.jsonBody);
        });

        // Do not log bank details
      } else {
        if (kDebugMode) {
          debugPrint(
              'Bank account fetch failed: status ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching bank account: $e');
    }
  }

  // 💳 Fetch wallet details from API
  Future<void> _fetchWallet() async {
    try {
      final driverIdValue = FFAppState().driverid;
      final driverId = int.tryParse(driverIdValue.toString());

      if (driverId == null) {
        if (kDebugMode) print('Driver ID is invalid for wallet');
        return;
      }

      final response = await GetWalletCall.call(
        driverId: driverId,
        token: FFAppState().accessToken,
      );

      if (response.succeeded) {
        setState(() {
          walletBalance =
              GetWalletCall.walletBalance(response.jsonBody)?.toString();
        });

        // Wallet loaded
      } else {
        if (kDebugMode) {
          debugPrint('Wallet fetch failed: status ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching wallet: $e');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
    final contentMaxWidth = isTablet ? 720.0 : double.infinity;
    final headerActions = [
      _buildHeaderAction(
          Icons.add, FFLocalizations.of(context).getText('wallet0014'), () {}),
      _buildHeaderAction(Icons.qr_code_scanner,
          FFLocalizations.of(context).getText('wallet0015'), () {}),
      _buildHeaderAction(Icons.history,
          FFLocalizations.of(context).getText('wallet0016'), () {}),
    ];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.backgroundAlt,
        appBar: AppBar(
          backgroundColor: ugoOrange,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 50.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 24.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            FFLocalizations.of(context).getText('8bs46fqf' /* My Wallet */),
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: Column(
                children: [
                  // ==========================================
                  // 1️⃣ BALANCE HEADER (Vibrant Gradient)
                  // ==========================================
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [ugoOrange, ugoOrangeLight],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ugoOrange.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(
                      20.0 * scale,
                      10.0 * scale,
                      20.0 * scale,
                      30.0 * scale,
                    ),
                    child: Column(
                      children: [
                        Text(
                          FFLocalizations.of(context).getText('wallet0001'),
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14.0 * scale,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.0 * scale),
                        // 💰 Dynamic Balance Amount
                        Text(
                          '₹${walletBalance ?? '0.00'}',
                          style: GoogleFonts.interTight(
                            color: Colors.white,
                            fontSize: 36.0 * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 24.0 * scale),

                        // ⚡ Quick Actions Row
                        if (isSmallScreen)
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12.0 * scale,
                            runSpacing: 12.0 * scale,
                            children: headerActions,
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: headerActions,
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.0 * scale),

                  // ==========================================
                  // 2️⃣ RECENT TRANSACTIONS (Driver Friendly)
                  // ==========================================
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FFLocalizations.of(context).getText('wallet0002'),
                          style: GoogleFonts.inter(
                            fontSize: 18.0 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12.0 * scale),

                        // 🟢 Credit Example (Earnings)
                        _buildTransactionTile(
                          title:
                              FFLocalizations.of(context).getText('wallet0003'),
                          date:
                              FFLocalizations.of(context).getText('wallet0017'),
                          amount: '+ ₹120.00',
                          isCredit: true,
                        ),
                        // 🔴 Debit Example (Commission)
                        _buildTransactionTile(
                          title:
                              FFLocalizations.of(context).getText('wallet0004'),
                          date:
                              FFLocalizations.of(context).getText('wallet0018'),
                          amount: '- ₹35.00',
                          isCredit: false,
                        ),
                        // 🟢 Credit Example (Incentive)
                        _buildTransactionTile(
                          title:
                              FFLocalizations.of(context).getText('wallet0005'),
                          date:
                              FFLocalizations.of(context).getText('wallet0019'),
                          amount: '+ ₹50.00',
                          isCredit: true,
                        ),

                        SizedBox(height: 8.0 * scale),
                        Center(
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              FFLocalizations.of(context).getText('wallet0006'),
                              style: TextStyle(
                                color: ugoOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.0 * scale),

                  // ==========================================
                  // 3️⃣ MANAGE OPTIONS (Clean Cards)
                  // ==========================================
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FFLocalizations.of(context).getText('wallet0007'),
                          style: GoogleFonts.inter(
                            fontSize: 18.0 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12.0 * scale),
                        _buildMenuCard(
                          icon: Icons.account_balance,
                          title:
                              FFLocalizations.of(context).getText('wallet0008'),
                          subtitle:
                              FFLocalizations.of(context).getText('wallet0009'),
                          onTap: () {
                            if (kDebugMode) {
                              // Bank card tapped - do not log details
                            }

                            final hasAccount = bankAccountNumber != null &&
                                bankAccountNumber!.isNotEmpty;

                            if (!mounted) return;

                            if (hasAccount) {
                              // Bank account exists - navigate to withdraw page
                              if (kDebugMode) {
                                print('💳 Navigating to withdraw with wallet balance: "$walletBalance"');
                              }
                              context.pushNamedAuth(
                                WithdrawWidget.routeName,
                                mounted,
                                extra: {
                                  'bankAccountNumber': bankAccountNumber,
                                  'ifscCode': ifscCode,
                                  'accountHolderName': accountHolderName,
                                  'fundAccountId': fundAccountId,
                                  'walletAmount': walletBalance,
                                },
                                ignoreRedirect: true,
                              );
                            } else {
                              // No bank account - navigate to add bank account page
                              context.pushNamedAuth(
                                AddBankAccountWidget.routeName,
                                mounted,
                                ignoreRedirect: true,
                              );
                            }
                          },
                        ),
                        SizedBox(height: 12.0 * scale),
                        _buildMenuCard(
                          icon: Icons.card_giftcard,
                          title:
                              FFLocalizations.of(context).getText('wallet0010'),
                          subtitle:
                              FFLocalizations.of(context).getText('wallet0011'),
                          onTap: () {},
                        ),
                        SizedBox(height: 12.0 * scale),
                        _buildMenuCard(
                          icon: Icons.group_add,
                          title:
                              FFLocalizations.of(context).getText('wallet0012'),
                          subtitle:
                              FFLocalizations.of(context).getText('wallet0013'),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.0 * scale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 WIDGET: Header Action Button
  Widget _buildHeaderAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 WIDGET: Transaction Tile
  Widget _buildTransactionTile({
    required String title,
    required String date,
    required String amount,
    required bool isCredit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCredit
                  ? ugoGreen.withValues(alpha: 0.1)
                  : ugoRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? ugoGreen : ugoRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            amount,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isCredit ? ugoGreen : ugoRed,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 WIDGET: Menu Card
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: ugoOrange, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
