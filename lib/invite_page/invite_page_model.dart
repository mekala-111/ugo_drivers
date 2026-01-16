import '/components/invite_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'invite_page_widget.dart' show InvitePageWidget;
import 'package:flutter/material.dart';

class InvitePageModel extends FlutterFlowModel<InvitePageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for invite component.
  late InviteModel inviteModel;

  @override
  void initState(BuildContext context) {
    inviteModel = createModel(context, () => InviteModel());
  }

  @override
  void dispose() {
    inviteModel.dispose();
  }
}
