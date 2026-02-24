import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Parses DD/MM/YYYY or YYYY-MM-DD to DateTime.
DateTime? parseDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final trimmed = value.trim();
  final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
  var m = iso.firstMatch(trimmed);
  if (m != null) {
    final y = int.tryParse(m.group(1)!);
    final mo = int.tryParse(m.group(2)!);
    final d = int.tryParse(m.group(3)!);
    if (y != null && mo != null && d != null) {
      return DateTime(y, mo, d);
    }
  }
  final dmy = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
  m = dmy.firstMatch(trimmed);
  if (m != null) {
    final d = int.tryParse(m.group(1)!);
    final mo = int.tryParse(m.group(2)!);
    final y = int.tryParse(m.group(3)!);
    if (d != null && mo != null && y != null) {
      return DateTime(y, mo, d);
    }
  }
  return null;
}

/// Returns YYYY-MM-DD for API.
String dateToApiFormat(String? value) {
  if (value == null || value.isEmpty) return '';
  final d = parseDate(value);
  return d != null ? DateFormat('yyyy-MM-dd').format(d) : value;
}

/// Shows date picker and returns formatted DD/MM/YYYY string or null.
Future<String?> showDatePickerForField(
  BuildContext context, {
  required String? currentValue,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? initialDate,
}) async {
  final now = DateTime.now();
  final initial = currentValue != null && currentValue.isNotEmpty
      ? (parseDate(currentValue) ?? now)
      : (initialDate ?? now);

  final picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: firstDate,
    lastDate: lastDate,
  );
  return picked != null ? DateFormat('dd/MM/yyyy').format(picked) : null;
}
