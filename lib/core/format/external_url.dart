/// True only for absolute http and https URLs with a host.
bool isAllowedExternalUrl(String raw) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return false;
  }
  return switch (uri.scheme.toLowerCase()) {
    'http' || 'https' => true,
    _ => false,
  };
}
