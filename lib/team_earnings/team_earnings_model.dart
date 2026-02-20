import '/components/team_earnings_tab_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'team_earnings_widget.dart' show TeamEarningsWidget;
import 'package:flutter/material.dart';

class TeamEarningsModel extends FlutterFlowModel<TeamEarningsWidget> {
  ///  State fields for stateful widgets in this page.

  late TeamEarningsTabModel teamEarningsTabModel;

  @override
  void initState(BuildContext context) {
    teamEarningsTabModel = createModel(context, () => TeamEarningsTabModel());
  }

  @override
  void dispose() {
    teamEarningsTabModel.dispose();
  }
}
