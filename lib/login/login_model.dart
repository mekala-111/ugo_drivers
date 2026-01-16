import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'login_widget.dart' show LoginWidget;
import 'package:flutter/material.dart';

class LoginModel extends FlutterFlowModel<LoginWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for mobileNo widget.
  FocusNode? mobileNoFocusNode;
  TextEditingController? mobileNoTextController;
  String? Function(BuildContext, String?)? mobileNoTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    mobileNoFocusNode?.dispose();
    mobileNoTextController?.dispose();
  }
}
