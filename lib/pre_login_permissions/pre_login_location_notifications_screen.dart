import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '/constants/app_colors.dart';
import '/index.dart';

/// Before login: Location first, then Notifications permission.
/// UGO TAXI, orange theme.
class PreLoginLocationNotificationsScreen extends StatefulWidget {
  const PreLoginLocationNotificationsScreen({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  @override
  State<PreLoginLocationNotificationsScreen> createState() =>
      _PreLoginLocationNotificationsScreenState();
}

class _PreLoginLocationNotificationsScreenState
    extends State<PreLoginLocationNotificationsScreen> {
  bool _isRequesting = false;
  bool _locationRequested = false;
  bool _notificationRequested = false;

  @override
  void initState() {
    super.initState();
    // Auto-request Location first (proper flow: "first location")
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_locationRequested) _requestLocation();
      });
    });
  }

  Future<void> _requestLocation() async {
    if (_isRequesting || !mounted) return;
    setState(() => _isRequesting = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) {
        setState(() {
          _locationRequested = true;
          _isRequesting = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Android: request background location if "while in use" granted
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

      if (mounted) {
        setState(() {
          _locationRequested = true;
          _isRequesting = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationRequested = true;
          _isRequesting = false;
        });
      }
    }
  }

  Future<void> _requestNotifications() async {
    if (_isRequesting || !mounted) return;
    setState(() => _isRequesting = true);

    try {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }

      if (mounted) {
        setState(() {
          _notificationRequested = true;
          _isRequesting = false;
        });
      }
    } on StateError catch (_) {
      // "Bad state: Future already completed" - treat as handled, allow continue
      if (mounted) {
        setState(() {
          _notificationRequested = true;
          _isRequesting = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _notificationRequested = true;
          _isRequesting = false;
        });
      }
    }
  }

  void _onContinue() {
    widget.onComplete();
    // Do NOT pop - parent's onComplete navigates (goNamedAuth) and replaces stack.
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(false);
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        title: Text(
          'Permissions required',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'UGO TAXI collects your data only for the purposes described below.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // 1. Location (first) – User Data policy: describe what we collect and why before request
              _buildPermissionCard(
                icon: Icons.location_on,
                title: 'Location',
                subtitle:
                    'We collect your location to find nearby rides, show you on the map, and navigate to pickup and drop-off. You can change this anytime in device settings.',
                requested: _locationRequested,
                onTap: _requestLocation,
                isRequesting: _isRequesting && !_locationRequested,
              ),
              const SizedBox(height: 16),
              // 2. Notifications
              _buildPermissionCard(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle:
                    'We use notifications to send you ride requests and important alerts when you are online. You can change this anytime in device settings.',
                requested: _notificationRequested,
                onTap: _requestNotifications,
                isRequesting: _isRequesting && _locationRequested && !_notificationRequested,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isRequesting ? null : _onContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool requested,
    required VoidCallback onTap,
    required bool isRequesting,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isRequesting ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 28, color: AppColors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
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
              if (isRequesting)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              else
                Icon(
                  requested ? Icons.check_circle : Icons.chevron_right,
                  color: requested ? AppColors.primary : Colors.grey[400],
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
