import '/components/teamearnings_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'teamearning_widget.dart' show TeamearningWidget;
import 'package:flutter/material.dart';

class TeamearningModel extends FlutterFlowModel<TeamearningWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for teamearnings component.
  late TeamearningsModel teamearningsModel;

  @override
  void initState(BuildContext context) {
    teamearningsModel = createModel(context, () => TeamearningsModel());
  }

  @override
  void dispose() {
    teamearningsModel.dispose();
  }
}
