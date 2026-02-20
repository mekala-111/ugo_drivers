import '/flutter_flow/flutter_flow_util.dart';
import 'insurance_image_widget.dart' show UploadRcWidget;
import 'package:flutter/material.dart';

class UploadRcModel extends FlutterFlowModel<UploadRcWidget> {
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
