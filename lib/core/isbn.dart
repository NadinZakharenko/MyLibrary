/// Finds an ISBN inside a barcode or a line of recognized text.
String? isbnFromText(String raw) {
  final direct = normalizeIsbn(raw);
  if (direct != null) {
    return direct;
  }
  final compact = raw.toUpperCase().replaceAll(RegExp(r'[^0-9X]'), '');
  for (var start = 0; start + 13 <= compact.length; start++) {
    final candidate = normalizeIsbn(compact.substring(start, start + 13));
    if (candidate != null) {
      return candidate;
    }
  }
  for (var start = 0; start + 10 <= compact.length; start++) {
    final slice = compact.substring(start, start + 10);
    if (slice.contains('X') && !slice.endsWith('X')) {
      continue;
    }
    final candidate = normalizeIsbn(slice);
    if (candidate != null) {
      return candidate;
    }
  }
  return null;
}

/// Returns a canonical ISBN-10 or ISBN-13, or null when the checksum fails.
String? normalizeIsbn(String raw) {
  final cleaned = raw.toUpperCase().replaceAll(RegExp(r'[^0-9X]'), '');
  if (cleaned.length == 13 && _isbn13Valid(cleaned)) {
    return cleaned;
  }
  if (cleaned.length == 10 && _isbn10Valid(cleaned)) {
    return cleaned;
  }
  return null;
}

bool _isbn10Valid(String isbn) {
  var sum = 0;
  for (var i = 0; i < 9; i++) {
    final digit = isbn.codeUnitAt(i) - 0x30;
    if (digit < 0 || digit > 9) {
      return false;
    }
    sum += digit * (10 - i);
  }
  final checkChar = isbn[9];
  final check = checkChar == 'X' ? 10 : checkChar.codeUnitAt(0) - 0x30;
  if (check < 0 || check > 10) {
    return false;
  }
  sum += check;
  return sum % 11 == 0;
}

bool _isbn13Valid(String isbn) {
  var sum = 0;
  for (var i = 0; i < 13; i++) {
    final digit = isbn.codeUnitAt(i) - 0x30;
    if (digit < 0 || digit > 9) {
      return false;
    }
    sum += digit * (i.isEven ? 1 : 3);
  }
  return sum % 10 == 0;
}
