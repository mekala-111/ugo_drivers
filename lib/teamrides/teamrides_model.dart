import '/components/teamride_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'teamrides_widget.dart' show TeamridesWidget;
import 'package:flutter/material.dart';

class TeamridesModel extends FlutterFlowModel<TeamridesWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for teamride component.
  late TeamrideModel teamrideModel;

  @override
  void initState(BuildContext context) {
    teamrideModel = createModel(context, () => TeamrideModel());
  }

  @override
  void dispose() {
    teamrideModel.dispose();
  }
}
