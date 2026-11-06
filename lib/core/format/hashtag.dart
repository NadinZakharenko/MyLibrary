/// Strips leading #, trims, and lowercases. Empty input becomes null.
///
/// Uniqueness is case-insensitive: «#Фантастика» and «фантастика» share a key.
String? normalizeHashtag(String raw) {
  var value = raw.trim();
  while (value.startsWith('#')) {
    value = value.substring(1).trim();
  }
  if (value.isEmpty) {
    return null;
  }
  return value.toLowerCase();
}

/// User-facing label: leading # removed, original case kept.
String? hashtagDisplayName(String raw) {
  var value = raw.trim();
  while (value.startsWith('#')) {
    value = value.substring(1).trim();
  }
  if (value.isEmpty) {
    return null;
  }
  return value;
}
