import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:share_plus/share_plus.dart';

class ReferFriendWidget extends StatefulWidget {
  const ReferFriendWidget({super.key});

  static String routeName = 'ReferFriend';
  static String routePath = '/referFriend';

  @override
  State<ReferFriendWidget> createState() => _ReferFriendWidgetState();
}

class _ReferFriendWidgetState extends State<ReferFriendWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  String _referralCode = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchReferralCode();
  }

  /// Fetch referral code from backend
  Future<void> _fetchReferralCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final driverId = FFAppState().driverid;
      final token = FFAppState().accessToken;

      // Validate authentication
      if (driverId == 0 || token.isEmpty) {
        setState(() {
          _errorMessage = FFLocalizations.of(context).getVariableText(
            enText: 'Please login first',
            hiText: 'कृपया पहले लॉगिन करें',
            teText: 'దయచేసి ముందుగా లాగిన్ అవండి',
          );
          _isLoading = false;
        });
        return;
      }

      print('🔄 Fetching referral code...');
      print('   Driver ID: $driverId');
      print('   Token: ${token.substring(0, 20)}...');

      // Call the DriverIdfetchCall API
      final response = await DriverIdfetchCall.call(
        id: driverId,
        token: token,
      );

      print('📥 API Response:');
      print('   Status: ${response.statusCode}');
      print('   Success: ${response.succeeded}');
      print('   Body: ${response.jsonBody}');

      // Check if response is successful
      bool isSuccess = false;
      
      if (response.succeeded == true) {
        isSuccess = true;
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        isSuccess = true;
      } else {
        try {
          final successField = getJsonField(
            (response.jsonBody ?? ''),
            r'''$.success''',
          );
          if (successField == true) {
            isSuccess = true;
          }
        } catch (e) {
          print('Error checking success field: $e');
        }
      }

      if (isSuccess) {
        // Extract referral code from response using helper method
        final referralCode = DriverIdfetchCall.referralCode(response.jsonBody);
        
        print('✅ Referral code fetched: $referralCode');

        if (referralCode != null && referralCode.isNotEmpty) {
          setState(() {
            _referralCode = referralCode;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = FFLocalizations.of(context).getVariableText(
              enText: 'No referral code found',
              hiText: 'कोई रेफरल कोड नहीं मिला',
              teText: 'రిఫరల్ కోడ్ కనుగొనబడలేదు',
            );
            _isLoading = false;
          });
        }
      } else {
        // Extract error message from response
        String errorMessage = FFLocalizations.of(context).getVariableText(
          enText: 'Failed to fetch referral code',
          hiText: 'रेफरल कोड प्राप्त करने में विफल',
          teText: 'రిఫరల్ కోడ్‌ను పొందడం విఫలమైంది',
        );

        try {
          final message = getJsonField(
            (response.jsonBody ?? ''),
            r'''$.message''',
          );
          if (message != null && message.toString().isNotEmpty) {
            errorMessage = message.toString();
          }
        } catch (e) {
          print('Error parsing error message: $e');
        }

        setState(() {
          _errorMessage = errorMessage;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching referral code: $e');
      setState(() {
        _errorMessage = FFLocalizations.of(context).getVariableText(
          enText: 'An error occurred. Please try again.',
          hiText: 'एक त्रुटि हुई। कृपया पुन: प्रयास करें।',
          teText: 'ఒక లోపం సంభవించింది. దయచేసి మళ్లీ ప్రయత్నించండి.',
        );
        _isLoading = false;
      });
    }
  }

  /// Copy referral code to clipboard
  Future<void> _copyToClipboard() async {
    if (_referralCode.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: _referralCode));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FFLocalizations.of(context).getVariableText(
              enText: 'Referral code copied to clipboard!',
              hiText: 'रेफरल कोड क्लिपबोर्ड पर कॉपी किया गया!',
              teText: 'రిఫరల్ కోడ్ క్లిప్‌బోర్డ్‌కు కాపీ చేయబడింది!',
            ),
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Share referral code
  Future<void> _shareReferralCode() async {
    if (_referralCode.isEmpty) return;

    final String message = FFLocalizations.of(context).getVariableText(
      enText: 'Join UGO Taxi using my referral code: $_referralCode\nDownload the app and start earning!',
      hiText: 'मेरे रेफरल कोड का उपयोग करके UGO टैक्सी में शामिल हों: $_referralCode\nऐप डाउनलोड करें और कमाई शुरू करें!',
      teText: 'నా రిఫరల్ కోడ్‌ని ఉపయోగించి UGO టాక్సీలో చేరండి: $_referralCode\nయాప్‌ను డౌన్‌లోడ్ చేయండి మరియు సంపాదించడం ప్రారంభించండి!',
    );

    // await Share.share(message);
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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            FFLocalizations.of(context).getVariableText(
              enText: 'Refer a Friend',
              hiText: 'दोस्त को रेफर करें',
              teText: 'స్నేహితుడిని రిఫర్ చేయండి',
            ),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.w500,
                  ),
                  color: Colors.white,
                  fontSize: 20.0,
                  letterSpacing: 0.0,
                ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                )
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60.0,
                            color: FlutterFlowTheme.of(context).error,
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            _errorMessage,
                            style: FlutterFlowTheme.of(context)
                                .bodyLarge
                                .override(
                                  font: GoogleFonts.inter(),
                                  color: FlutterFlowTheme.of(context).error,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          SizedBox(height: 24.0),
                          FFButtonWidget(
                            onPressed: _fetchReferralCode,
                            text: FFLocalizations.of(context).getVariableText(
                              enText: 'Retry',
                              hiText: 'पुनः प्रयास करें',
                              teText: 'మళ్లీ ప్రయత్నించండి',
                            ),
                            options: FFButtonOptions(
                              width: 120.0,
                              height: 44.0,
                              padding: EdgeInsets.all(0.0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.interTight(),
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 2.0,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            24.0, 24.0, 24.0, 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Header Icon
                            Container(
                              width: 120.0,
                              height: 120.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .primary
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.card_giftcard,
                                size: 60.0,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                            SizedBox(height: 24.0),

                            // Title
                            Text(
                              FFLocalizations.of(context).getVariableText(
                                enText: 'Share & Earn',
                                hiText: 'साझा करें और कमाएं',
                                teText: 'భాగస్వామ్యం చేయండి & సంపాదించండి',
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .headlineLarge
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 28.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            SizedBox(height: 12.0),

                            // Description
                            Text(
                              FFLocalizations.of(context).getVariableText(
                                enText:
                                    'Invite your friends to join UGO and earn rewards when they complete their first ride!',
                                hiText:
                                    'अपने दोस्तों को UGO में शामिल होने के लिए आमंत्रित करें और जब वे अपनी पहली यात्रा पूरी करें तो पुरस्कार अर्जित करें!',
                                teText:
                                    'మీ స్నేహితులను UGOలో చేరమని ఆహ్వానించండి మరియు వారు తమ మొదటి ప్రయాణాన్ని పూర్తి చేసినప్పుడు బహుమతులు పొందండి!',
                              ),
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            SizedBox(height: 32.0),

                            // Referral Code Card
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 2.0,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 24.0, 20.0, 24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      FFLocalizations.of(context)
                                          .getVariableText(
                                        enText: 'Your Referral Code',
                                        hiText: 'आपका रेफरल कोड',
                                        teText: 'మీ రిఫరల్ కోడ్',
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(),
                                            color:
                                                FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    SizedBox(height: 12.0),
                                    // Referral Code Display
                                    Container(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 12.0, 16.0, 12.0),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primary
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Text(
                                        _referralCode,
                                        style: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .override(
                                              font: GoogleFonts.robotoMono(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              color: FlutterFlowTheme.of(
                                                      context)
                                                  .primary,
                                              fontSize: 24.0,
                                              letterSpacing: 2.0,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 24.0),

                            // Copy Button
                            FFButtonWidget(
                              onPressed: _copyToClipboard,
                              text: FFLocalizations.of(context).getVariableText(
                                enText: 'Copy Code',
                                hiText: 'कोड कॉपी करें',
                                teText: 'కోడ్‌ను కాపీ చేయండి',
                              ),
                              icon: Icon(
                                Icons.copy,
                                size: 20.0,
                              ),
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 56.0,
                                padding: EdgeInsets.all(0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      letterSpacing: 0.0,
                                    ),
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            SizedBox(height: 12.0),

                            // Share Button
                            FFButtonWidget(
                              onPressed: _shareReferralCode,
                              text: FFLocalizations.of(context).getVariableText(
                                enText: 'Share with Friends',
                                hiText: 'दोस्तों के साथ साझा करें',
                                teText: 'స్నేహితులతో భాగస్వామ్యం చేయండి',
                              ),
                              icon: Icon(
                                Icons.share,
                                size: 20.0,
                              ),
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 56.0,
                                padding: EdgeInsets.all(0.0),
                                color: Colors.white,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      fontSize: 18.0,
                                      letterSpacing: 0.0,
                                    ),
                                elevation: 0.0,
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            SizedBox(height: 32.0),

                            // How it Works Section
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 20.0, 16.0, 20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      FFLocalizations.of(context)
                                          .getVariableText(
                                        enText: 'How it Works',
                                        hiText: 'यह कैसे काम करता है',
                                        teText: 'ఇది ఎలా పనిచేస్తుంది',
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            color:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            fontSize: 18.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    SizedBox(height: 16.0),
                                    _buildStep(
                                      context: context,
                                      number: '1',
                                      title:
                                          FFLocalizations.of(context).getVariableText(
                                        enText: 'Share your code',
                                        hiText: 'अपना कोड साझा करें',
                                        teText: 'మీ కోడ్‌ను భాగస్వామ్యం చేయండి',
                                      ),
                                      description:
                                          FFLocalizations.of(context).getVariableText(
                                        enText: 'Send your referral code to friends',
                                        hiText: 'दोस्तों को अपना रेफरल कोड भेजें',
                                        teText: 'స్నేహితులకు మీ రిఫరల్ కోడ్‌ను పంపండి',
                                      ),
                                    ),
                                    SizedBox(height: 12.0),
                                    _buildStep(
                                      context: context,
                                      number: '2',
                                      title:
                                          FFLocalizations.of(context).getVariableText(
                                        enText: 'They sign up',
                                        hiText: 'वे साइन अप करें',
                                        teText: 'వారు సైన్ అప్ చేస్తారు',
                                      ),
                                      description:
                                          FFLocalizations.of(context).getVariableText(
                                        enText: 'Your friend joins using your code',
                                        hiText: 'आपका दोस्त आपके कोड का उपयोग करके शामिल होता है',
                                        teText: 'మీ స్నేహితుడు మీ కోడ్‌ను ఉపయోగించి చేరతారు',
                                      ),
                                    ),
                                    SizedBox(height: 12.0),
                                    _buildStep(
                                      context: context,
                                      number: '3',
                                      title:
                                          FFLocalizations.of(context).getVariableText(
                                        enText: 'You both earn',
                                        hiText: 'आप दोनों कमाते हैं',
                                        teText: 'మీరిద్దరూ సంపాదిస్తారు',
                                      ),
                                      description:
                                          FFLocalizations.of(context).getVariableText(
                                        enText: 'Get rewards when they complete first ride',
                                        hiText: 'जब वे पहली यात्रा पूरी करें तो पुरस्कार प्राप्त करें',
                                        teText: 'వారు మొదటి ప్రయాణాన్ని పూర్తి చేసినప్పుడు బహుమతులు పొందండి',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  /// Build step widget for "How it Works" section
  Widget _buildStep({
    required BuildContext context,
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.0,
          height: 32.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.bold,
                    ),
                    color: Colors.white,
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        ),
        SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                    ),
              ),
              SizedBox(height: 4.0),
              Text(
                description,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 13.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}