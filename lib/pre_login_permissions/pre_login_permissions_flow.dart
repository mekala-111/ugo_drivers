import 'package:flutter/material.dart';

import 'pre_login_location_notifications_screen.dart';

/// Before login: Location first, then Notifications permission.
/// UGO TAXI branding, orange theme.
class PreLoginPermissionsFlow extends StatefulWidget {
  const PreLoginPermissionsFlow({
    super.key,
    this.onComplete,
  });

  final VoidCallback? onComplete;

  @override
  State<PreLoginPermissionsFlow> createState() =>
      _PreLoginPermissionsFlowState();
}

class _PreLoginPermissionsFlowState extends State<PreLoginPermissionsFlow> {
  void _onComplete() {
    widget.onComplete?.call();
    // Do NOT pop here - onComplete should navigate (e.g. goNamedAuth) which
    // replaces the stack. Popping + external navigation causes double-pop and
    // "You have popped the last page" / "Future already completed" errors.
  }

  @override
  Widget build(BuildContext context) {
    return PreLoginLocationNotificationsScreen(
      onComplete: _onComplete,
    );
  }
}
