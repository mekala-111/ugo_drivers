import '/flutter_flow/flutter_flow_util.dart';
import 'add_bank_account_widget.dart' show AddBankAccountWidget;
import 'package:flutter/material.dart';

class AddBankAccountModel extends FlutterFlowModel<AddBankAccountWidget> {
  late TextEditingController bankHolderNameController;
  late TextEditingController bankAccountNumberController;
  late TextEditingController confirmBankAccountNumberController;
  late TextEditingController bankIfscCodeController;

  FocusNode? bankHolderNameFocusNode;
  FocusNode? bankAccountNumberFocusNode;
  FocusNode? confirmBankAccountNumberFocusNode;
  FocusNode? bankIfscCodeFocusNode;

  // Razorpay validation states
  bool isValidating = false;
  String? validatedBankName;
  String? validationError;

  @override
  void initState(BuildContext context) {
    bankHolderNameController = TextEditingController();
    bankAccountNumberController = TextEditingController();
    confirmBankAccountNumberController = TextEditingController();
    bankIfscCodeController = TextEditingController();

    bankHolderNameFocusNode = FocusNode();
    bankAccountNumberFocusNode = FocusNode();
    confirmBankAccountNumberFocusNode = FocusNode();
    bankIfscCodeFocusNode = FocusNode();
  }

  @override
  void dispose() {
    bankHolderNameController.dispose();
    bankAccountNumberController.dispose();
    confirmBankAccountNumberController.dispose();
    bankIfscCodeController.dispose();

    bankHolderNameFocusNode?.dispose();
    bankAccountNumberFocusNode?.dispose();
    confirmBankAccountNumberFocusNode?.dispose();
    bankIfscCodeFocusNode?.dispose();
  }
}
