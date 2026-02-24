import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

/// Rapido-style: Location permission request shown immediately before completing
/// login (after OTP verification). User must see this before proceeding to Home
/// or registration. Matches Play Console User Data policy disclosure.
class PreLoginLocationPermissionWidget extends StatefulWidget {
  const PreLoginLocationPermissionWidget({
    super.key,
    this.onComplete,
  });

  /// Called when user finishes (Continue or Not now). Proceed with navigation.
  final VoidCallback? onComplete;

  static String routeName = 'pre_login_location_permission';
  static String routePath = '/pre-login-location';

  @override
  State<PreLoginLocationPermissionWidget> createState() =>
      _PreLoginLocationPermissionWidgetState();
}

class _PreLoginLocationPermissionWidgetState
    extends State<PreLoginLocationPermissionWidget> {
  bool _isRequesting = false;

  Future<void> _requestPermissionAndComplete() async {
    if (_isRequesting || !mounted) return;
    setState(() => _isRequesting = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) {
        // Location services off - user can enable in settings later
        _complete();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Android: if "while in use" granted, request background for ride matching
      if (Platform.isAndroid &&
          permission == LocationPermission.whileInUse &&
          mounted) {
        final agreed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => const BackgroundLocationNoticeWidget(),
          ),
        );
        if (agreed == true) {
          await Geolocator.requestPermission();
        }
      }

      if (mounted) _complete();
    } catch (_) {
      if (mounted) _complete();
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  void _complete() {
    widget.onComplete?.call();
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _complete();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => _complete(),
          ),
          title: Text(
            'Data sharing and location',
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Info: Developer-provided disclosure (Play Console)
                _buildInfoCard(
                  icon: Icons.info_outline,
                  text:
                      'The developer provided info to Google Play about how this app uses data. The developer may update this info over time.',
                ),
                const SizedBox(height: 20),
                // Purpose of location
                _buildSectionTitle('This app uses location data for:'),
                const SizedBox(height: 12),
                _buildPurposeItem('App functionality',
                    'Ride matching, navigation, driver tracking during trips'),
                _buildPurposeItem(
                    'Ride requests', 'Show you on the map and match nearby rides'),
                _buildPurposeItem('Navigation',
                    'Guide you to pickup and drop-off points'),
                const SizedBox(height: 16),
                _buildInfoCard(
                  icon: Icons.description_outlined,
                  text:
                      'Data practices may vary based on your app version, use, region, and age. You can change location access anytime in your device privacy settings.',
                ),
                const SizedBox(height: 24),
                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isRequesting ? null : _requestPermissionAndComplete,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isRequesting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Continue',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _isRequesting ? null : _complete,
                    child: Text(
                      FFLocalizations.of(context).getText('drv_not_now'),
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 14,
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

  Widget _buildInfoCard({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black87,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPurposeItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
