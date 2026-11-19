import 'package:my_library/core/isbn.dart';

enum DuplicateReason { isbn, titleAndAuthors, titleOnly }

class DuplicateCandidate {
  const DuplicateCandidate({
    required this.id,
    required this.title,
    required this.isbn,
    required this.authors,
    required this.locationPath,
  });

  final int? id;
  final String title;
  final String isbn;
  final List<String> authors;
  final String locationPath;
}

class DuplicateMatch {
  const DuplicateMatch({
    required this.id,
    required this.title,
    required this.locationPath,
    required this.reason,
  });

  final int id;
  final String title;
  final String locationPath;
  final DuplicateReason reason;
}

String normalizeBookTitle(String title) {
  return title.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

Set<String> authorIdentity(List<String> authors) {
  return {
    for (final author in authors)
      if (author.trim().isNotEmpty) author.trim().toLowerCase(),
  };
}

/// Checksum-valid ISBN when possible, otherwise the cleaned code.
/// Empty input is not an identity.
String? comparableIsbn(String raw) {
  final normalized = normalizeIsbn(raw);
  if (normalized != null) {
    return normalized;
  }
  final cleaned = raw.toUpperCase().replaceAll(RegExp(r'[^0-9X]'), '');
  if (cleaned.isEmpty) {
    return null;
  }
  return cleaned;
}

List<DuplicateMatch> findDuplicateCopies({
  required DuplicateCandidate candidate,
  required List<DuplicateCandidate> existing,
}) {
  final title = normalizeBookTitle(candidate.title);
  final authors = authorIdentity(candidate.authors);
  final isbn = comparableIsbn(candidate.isbn);
  final matches = <DuplicateMatch>[];
  for (final other in existing) {
    if (candidate.id != null && other.id == candidate.id) {
      continue;
    }
    if (other.id == null) {
      continue;
    }
    final otherIsbn = comparableIsbn(other.isbn);
    if (isbn != null && otherIsbn != null && isbn == otherIsbn) {
      matches.add(
        DuplicateMatch(
          id: other.id!,
          title: other.title,
          locationPath: other.locationPath,
          reason: DuplicateReason.isbn,
        ),
      );
      continue;
    }
    if (title.isEmpty) {
      continue;
    }
    if (title != normalizeBookTitle(other.title)) {
      continue;
    }
    final otherAuthors = authorIdentity(other.authors);
    final DuplicateReason reason;
    if (_sameAuthors(authors, otherAuthors)) {
      reason = DuplicateReason.titleAndAuthors;
    } else if (authors.isEmpty || otherAuthors.isEmpty) {
      reason = DuplicateReason.titleOnly;
    } else {
      continue;
    }
    matches.add(
      DuplicateMatch(
        id: other.id!,
        title: other.title,
        locationPath: other.locationPath,
        reason: reason,
      ),
    );
  }
  return matches;
}

bool _sameAuthors(Set<String> left, Set<String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (final author in left) {
    if (!right.contains(author)) {
      return false;
    }
  }
  return true;
}

String duplicateReasonLabel(DuplicateReason reason) {
  return switch (reason) {
    DuplicateReason.isbn => 'тот же ISBN',
    DuplicateReason.titleAndAuthors => 'то же название и те же авторы',
    DuplicateReason.titleOnly => 'то же название (автор не указан)',
  };
}
