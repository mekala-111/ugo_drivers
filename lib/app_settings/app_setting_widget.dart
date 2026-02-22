import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ugo_driver/app_settings/emergencycontactscreen.dart';
import 'package:ugo_driver/app_state.dart';
import 'package:ugo_driver/services/floating_bubble_service.dart';
import 'package:ugo_driver/constants/app_colors.dart';

class AppSettingsWidget extends StatefulWidget {
  const AppSettingsWidget({super.key});

  static String routeName = 'AppSettings';
  static String routePath = '/appSettings';

  @override
  State<AppSettingsWidget> createState() => _AppSettingsWidgetState();
}

class _AppSettingsWidgetState extends State<AppSettingsWidget> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<FFAppState>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('App Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            _settingsTile(Icons.volume_up_outlined, 'Sounds and Voice'),
            _settingsTile(Icons.navigation_outlined, 'Navigation'),
            _settingsTile(Icons.accessibility_new_outlined, 'Accessibility'),
            _settingsTile(Icons.people_outline, 'Communication'),
            // _settingsTile(Icons.language_outlined, 'App Language'),
            _settingsTile(Icons.display_settings_outlined, 'Display'),
            _overlayBubbleTile(
              value: appState.overlayBubbleEnabled,
              onChanged: (value) => _handleOverlayToggle(context, value),
            ),
            _settingsTile(Icons.location_on_outlined, 'Follow My Ride'),
            _settingsTile(Icons.emergency_outlined, 'Emergency Contacts',
            onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmergencyContactsScreen()),
    );
  }),
            _settingsTile(Icons.speed_outlined, 'Speed limit'),
            // _settingsTile(Icons.share_outlined, 'Emergency Data Sharing'),
            _settingsTile(Icons.check_circle_outline, 'RideCheck'),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, {VoidCallback? onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 22, color: Colors.black),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _overlayBubbleTile({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        SwitchListTile(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          title: const Text(
            'Floating bubble',
            style: TextStyle(fontSize: 16),
          ),
          subtitle: const Text(
            'Show a small bubble for quick ride actions when the app is in the background.',
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Future<void> _handleOverlayToggle(BuildContext context, bool value) async {
    if (value) {
      final allow = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Enable floating bubble?'),
          content: const Text(
            'This lets you respond to ride requests faster when the app is in the background. '
            'You can turn it off anytime.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Enable'),
            ),
          ],
        ),
      );
      if (allow != true) return;
      final hasPermission = await FloatingBubbleService.checkOverlayPermission();
      if (!hasPermission) {
        await FloatingBubbleService.requestOverlayPermission();
      }
    }
    context.read<FFAppState>().overlayBubbleEnabled = value;
  }
}
