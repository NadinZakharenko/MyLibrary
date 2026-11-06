import 'dart:convert';

import 'package:my_library/core/logging/redact.dart';

/// Short refusal text from a model response. Drops the photo and saved secrets.
String modelErrorDetail(String body, {required Iterable<String> secrets}) {
  var text = _message(body);
  text = text.replaceAll(
    RegExp(r'data:image/[^,\s]+;base64,[A-Za-z0-9+/=\s]+'),
    '',
  );
  text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');
  text = redactSecrets(text, secrets);
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (text.length <= 240) {
    return text;
  }
  return '${text.substring(0, 240)}…';
}

String _message(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      final error = decoded['error'];
      if (error is Map && error['message'] is String) {
        return error['message'] as String;
      }
      if (error is String) {
        return error;
      }
    }
  } on FormatException {
    return body;
  }
  return body;
}
