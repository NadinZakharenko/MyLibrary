import 'package:my_library/core/isbn.dart';
import 'package:my_library/core/models/metadata_candidate.dart';

/// Public search. The path segment is the query.
/// `/find/books?q=…` ignores `q` and searches for the word "books".
Uri liveLibSearchUri(String query) {
  return Uri(
    scheme: 'https',
    host: 'www.livelib.ru',
    pathSegments: ['find', query.trim()],
  );
}

/// Title, author and book page from a public LiveLib search page.
/// Edition counters ("127 изданий") and review links are ignored.
List<MetadataCandidate> candidatesFromLiveLib(
  String html, {
  required String isbn,
}) {
  final editions = _cards(html, kind: 'book', isbn: isbn);
  if (editions.isNotEmpty) {
    return editions;
  }
  return _cards(html, kind: 'work', isbn: isbn);
}

List<MetadataCandidate> _cards(
  String html, {
  required String kind,
  required String isbn,
}) {
  final pattern = RegExp(
    '''href=["'](?:https://www\\.livelib\\.ru)?(/$kind/(\\d+)-[^"']*)["'][^>]*>(.*?)</a>''',
    caseSensitive: false,
    dotAll: true,
  );
  final found = <MetadataCandidate>[];
  final seen = <String>{};
  for (final match in pattern.allMatches(html)) {
    if (found.length == 8) {
      break;
    }
    final id = match.group(2) ?? '';
    final title = _plain(match.group(3) ?? '');
    if (id.isEmpty ||
        title.length < 2 ||
        title.toLowerCase() == 'livelib' ||
        _isEditionCount(title)) {
      continue;
    }
    if (!seen.add(id)) {
      continue;
    }
    final tail = html.substring(
      match.end,
      (match.end + 800).clamp(0, html.length),
    );
    final authorMatch = RegExp(
      '''href=["'][^"']*?/author/[^"']*["'][^>]*>(.*?)</a>''',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(tail);
    final author = _plain(authorMatch?.group(1) ?? '');
    found.add(
      MetadataCandidate(
        source: MetadataSource.liveLib,
        title: title,
        authors: author.isEmpty ? const [] : [author],
        genres: _genres(tail),
        year: _yearNear(html, match.end, kind),
        isbn: isbn.trim().isNotEmpty ? isbn.trim() : _labeledIsbn(tail),
        coverUrl: _coverBefore(html, match.start),
        sourceUrl: 'https://www.livelib.ru${match.group(1)}',
      ),
    );
  }
  return found;
}

String _yearNear(String html, int end, String kind) {
  final tail = html.substring(end, (end + 800).clamp(0, html.length));
  final next = RegExp(
    '''href=["'](?:https://www\\.livelib\\.ru)?/$kind/\\d+-''',
    caseSensitive: false,
  ).firstMatch(tail);
  final card = next == null ? tail : tail.substring(0, next.start);
  return RegExp(r'(?<!\d)(\d{4})(?!\d)').firstMatch(_plain(card))?.group(1) ??
      '';
}

String liveLibPageIsbn(String html) {
  final plain = _plain(html);
  final match = RegExp(
    r'ISBN(?:-1[03])?\s*:?\s*([0-9][0-9X\-\s]{8,22})',
    caseSensitive: false,
  ).firstMatch(plain);
  if (match == null) {
    return '';
  }
  return isbnFromText(match.group(1) ?? '') ?? '';
}

String _labeledIsbn(String html) {
  return liveLibPageIsbn(html);
}

bool _isEditionCount(String title) {
  return RegExp(r'^\d+\s+издани', caseSensitive: false).hasMatch(title);
}

String? _coverBefore(String html, int index) {
  final start = index < 1500 ? 0 : index - 1500;
  final head = html.substring(start, index);
  final covers = RegExp(r'https://s\d+\.livelib\.ru/boocover/\d+/[^"\s)]+')
      .allMatches(head);
  if (covers.isEmpty) {
    return null;
  }
  return covers.last.group(0);
}

List<String> _genres(String tail) {
  final pattern = RegExp(
    '''<a[^>]*class=["']label-genre["'][^>]*>(.*?)</a>''',
    caseSensitive: false,
    dotAll: true,
  );
  final genres = <String>[];
  for (final match in pattern.allMatches(tail)) {
    final genre = _plain(match.group(1) ?? '');
    if (genre.isEmpty || genres.contains(genre)) {
      continue;
    }
    genres.add(genre);
    if (genres.length == 4) {
      break;
    }
  }
  return genres;
}

String _plain(String value) {
  return value
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#34;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
