/// Removes saved secrets and `key=` query parameters from text that may be logged.
String redactSecrets(String value, Iterable<String> secrets) {
  var text = value;
  for (final secret in secrets) {
    final trimmed = secret.trim();
    if (trimmed.length < 6) {
      continue;
    }
    text = text.replaceAll(trimmed, '•••');
  }
  return text.replaceAllMapped(
    RegExp(r'([?&])key=[^&\s]+', caseSensitive: false),
    (match) => '${match[1]}key=•••',
  );
}
