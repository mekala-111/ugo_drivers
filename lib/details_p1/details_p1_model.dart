import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'details_p1_widget.dart' show DetailsP1Widget;
import 'package:flutter/material.dart';

class DetailsP1Model extends FlutterFlowModel<DetailsP1Widget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
