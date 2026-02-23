// ignore_for_file: non_constant_identifier_names
import '/flutter_flow/flutter_flow_util.dart';
import 'face_verify_widget.dart' show FaceVerifyWidget;
import 'package:flutter/material.dart';

class FaceVerifyModel extends FlutterFlowModel<FaceVerifyWidget> {
  ///  Local state fields for this page.

  FFUploadedFile? profilephoto;

  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadDataFvd = false;
  FFUploadedFile uploadedLocalFile_uploadDataFvd =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
