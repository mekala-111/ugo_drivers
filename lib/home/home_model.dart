import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'home_widget.dart' show HomeWidget;
import 'package:flutter/material.dart';

class HomeModel extends FlutterFlowModel<HomeWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (driverIdfetch)] action in home widget.
  ApiCallResponse? userDetails;
  // Stores action output result for [Backend Call - API (postQRcode)] action in home widget.
  ApiCallResponse? postQR;
  // State field(s) for Switch widget.
  bool? switchValue;
  // Stores action output result for [Backend Call - API (updateDriver)] action in Switch widget.
  ApiCallResponse? updatedriver;
  // Stores action output result for [Backend Call - API (updateDriver)] action in Switch widget.
  ApiCallResponse? apiResultrv8;
  // State field(s) for GoogleMap widget.
  LatLng? googleMapsCenter;
  final googleMapsController = Completer<GoogleMapController>();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
