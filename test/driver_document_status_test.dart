import 'package:flutter_test/flutter_test.dart';
import 'package:ugo_driver/backend/api_requests/api_calls.dart';
import 'package:ugo_driver/services/driver_signup_submit_service.dart';

void main() {
  // Shape of GET /api/drivers/documents/status (backend driverDocumentsController).
  final body = {
    'success': true,
    'data': {
      'can_go_online_documents': false,
      'documents': [
        {'type': 'rc', 'required': true, 'uploaded': true, 'status': 'EXPIRED', 'submitted_expiry_date': '2026-11-09'},
        {'type': 'permit', 'required': false, 'uploaded': false, 'status': 'NOT_REQUIRED'},
      ],
    },
  };

  test('DriverDocumentStatusCall.document picks one document by type', () {
    expect(DriverDocumentStatusCall.document(body, 'rc')?['status'], 'EXPIRED');
    expect(DriverDocumentStatusCall.document(body, 'permit')?['required'], false);
    expect(DriverDocumentStatusCall.document(body, 'insurance'), isNull);
    expect(DriverDocumentStatusCall.document({'data': {}}, 'rc'), isNull);
  });

  test('picker dates (dd/MM/yyyy) are sent to the API as YYYY-MM-DD', () {
    expect(DriverSignupSubmitService.formatDateForApi('09/11/2026'), '2026-11-09');
    expect(DriverSignupSubmitService.formatDateForApi('2026-11-09'), '2026-11-09');
  });
}
