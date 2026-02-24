import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '/constants/app_colors.dart';
import '/index.dart';

/// "Give all permissions to proceed" - Battery Usage, Background Location.
/// Display over apps removed (not used). UGO TAXI, orange theme.
class PreLoginPermissionsScreen extends StatefulWidget {
  const PreLoginPermissionsScreen({
    super.key,
    required this.onComplete,
    this.onBack,
  });

  final VoidCallback onComplete;
  final VoidCallback? onBack;

  @override
  State<PreLoginPermissionsScreen> createState() =>
      _PreLoginPermissionsScreenState();
}

class _PreLoginPermissionsScreenState extends State<PreLoginPermissionsScreen> {
  bool _batteryGranted = false;
  bool _locationGranted = false;

  @override
  void initState() {
    super.initState();
    _refreshStatuses();
  }

  Future<void> _refreshStatuses() async {
    if (!mounted) return;
    setState(() {});

    final battery = await Permission.ignoreBatteryOptimizations.isGranted;
    final locAlways =
        await Permission.locationWhenInUse.isGranted &&
            (await Permission.locationAlways.isGranted);
    final locWhenInUse = await Permission.locationWhenInUse.isGranted;

    if (mounted) {
      setState(() {
        _batteryGranted = battery;
        _locationGranted = Platform.isAndroid ? locAlways : locWhenInUse;
      });
    }
  }

  Future<void> _requestBattery() async {
    await Permission.ignoreBatteryOptimizations.request();
    await _refreshStatuses();
  }

  Future<void> _requestLocation() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
    }
    if (status.isGranted && Platform.isAndroid) {
      // Request background location
      final bgStatus = await Permission.locationAlways.status;
      if (!bgStatus.isGranted) {
        final agreed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => const BackgroundLocationNoticeWidget(),
          ),
        );
        if (agreed == true) {
          await Permission.locationAlways.request();
        }
      }
    }
    await _refreshStatuses();
  }

  void _onSubmit() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = _batteryGranted && _locationGranted;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        widget.onBack?.call();
      },
      child: Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => widget.onBack?.call(),
        ),
        title: Text(
          'Give all permissions to proceed',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              // Help - could open support
            },
            icon: const Icon(Icons.headset_mic, color: Colors.white, size: 20),
            label: Text(
              'Help',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildPermissionCard(
              icon: Icons.battery_charging_full,
              title: 'Battery Usage',
              subtitle: 'Helps app run in background',
              granted: _batteryGranted,
              onTap: _requestBattery,
            ),
            const SizedBox(height: 12),
            _buildPermissionCard(
              icon: Icons.location_on,
              title: 'Background Location',
              subtitle: 'Helps find rides based on location',
              granted: _locationGranted,
              onTap: _requestLocation,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: allGranted
                      ? AppColors.primary
                      : Colors.grey[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Submit',
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
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool granted,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
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
              Icon(
                granted ? Icons.check_circle : Icons.chevron_right,
                color: granted ? AppColors.primary : Colors.grey[400],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
