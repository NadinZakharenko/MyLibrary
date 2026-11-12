import 'package:my_library/core/isbn.dart';
import 'package:my_library/core/models/metadata_candidate.dart';

const rslGateway = 'lbc.rsl.ru';

Uri rslSearchUri({String? isbn, String title = '', String author = ''}) {
  final parts = <String>[
    if (isbn != null && isbn.trim().isNotEmpty)
      'isbn:${rslIsbn(isbn) ?? isbn.trim()}',
    if (title.trim().isNotEmpty) 'title:${rslTextQuery(title)}',
    if (author.trim().isNotEmpty) 'author:${rslTextQuery(author)}',
  ];
  return Uri.https('search.rsl.ru', '/ru/search', {'query': parts.join(' ')});
}

/// Hyphenated ISBN-13 for the RSL index. Russian 978-5 is split by the
/// publisher ranges; other prefixes stay as digits.
String? rslIsbn(String raw) {
  final isbn = _isbn13(raw);
  if (isbn == null) {
    return null;
  }
  if (!isbn.startsWith('9785')) {
    return isbn;
  }
  final body = isbn.substring(4, 12);
  final length = _registrantLength(int.parse(body.substring(0, 7)));
  final registrant = body.substring(0, length);
  final publication = body.substring(length);
  return '978-5-$registrant-$publication-${isbn.substring(12)}';
}

/// RSL rejects the word "end" in a title and limits a free query to 200 characters.
String rslTextQuery(String value) {
  final cleaned = value
      .replaceAll(RegExp(r'\bend\b', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (cleaned.length <= 200) {
    return cleaned;
  }
  return cleaned.substring(0, 200).trimRight();
}

List<MetadataCandidate> candidatesFromRsl(String xml) {
  final records = RegExp(
    r'<record\b[^>]*>(.*?)</record>',
    dotAll: true,
  ).allMatches(xml);
  final found = <MetadataCandidate>[];
  for (final record in records) {
    if (found.length == 8) {
      break;
    }
    final body = record.group(1) ?? '';
    final fields = _fields(body);
    final titleField = fields['245'];
    var title = _sub(titleField, 'a');
    final subtitle = _sub(titleField, 'b');
    final parent = fields['773'];
    if (_volumeOnly(title)) {
      final parentTitle = _parentTitle(_sub(parent, 't'));
      if (parentTitle.isNotEmpty) {
        title = parentTitle;
      }
    }
    if (title.length < 2) {
      continue;
    }
    final authors = <String>[
      for (final code in ['100', '700'])
        if (_sub(fields[code], 'a').isNotEmpty) _sub(fields[code], 'a'),
    ];
    if (authors.isEmpty) {
      final parentAuthor = _sub(parent, 'a');
      if (parentAuthor.isNotEmpty) {
        authors.add(parentAuthor);
      }
    }
    final imprint = fields['264'] ?? fields['260'];
    final year = _year(_sub(imprint, 'c'));
    final publisher = _imprint(
      _sub(imprint, 'b'),
      year,
      fallback: _sub(parent, 'd'),
    );
    final series = fields['490'];
    final id = _control(body, '001');
    found.add(
      MetadataCandidate(
        source: MetadataSource.rsl,
        title: title,
        subtitle: subtitle,
        authors: authors,
        publisher: publisher,
        year: year,
        isbn: _isbn(_sub(fields['020'], 'a')),
        seriesName: _sub(series, 'a'),
        seriesVolume: _volume(_sub(series, 'v')),
        sourceUrl: id.isEmpty ? null : 'https://search.rsl.ru/ru/record/$id',
      ),
    );
  }
  return found;
}

int _registrantLength(int probe) {
  if (probe <= 1999999) {
    return 2;
  }
  if (probe <= 6999999) {
    return 3;
  }
  if (probe <= 8499999) {
    return 4;
  }
  if (probe <= 8999999) {
    return 5;
  }
  if (probe <= 9499999) {
    return 6;
  }
  return 7;
}

String? _isbn13(String raw) {
  final normalized = normalizeIsbn(raw);
  if (normalized == null) {
    return null;
  }
  if (normalized.length == 13) {
    return normalized;
  }
  final core = '978${normalized.substring(0, 9)}';
  var sum = 0;
  for (var index = 0; index < 12; index++) {
    sum += (core.codeUnitAt(index) - 0x30) * (index.isEven ? 1 : 3);
  }
  final check = (10 - (sum % 10)) % 10;
  return '$core$check';
}

Map<String, Map<String, String>> _fields(String record) {
  final fields = <String, Map<String, String>>{};
  final pattern = RegExp(
    r'<datafield\b[^>]*\btag="(\d+)"[^>]*>(.*?)</datafield>',
    dotAll: true,
  );
  for (final match in pattern.allMatches(record)) {
    final tag = match.group(1) ?? '';
    if (tag == '852' || tag == '952' || tag == '956') {
      continue;
    }
    final subs = fields.putIfAbsent(tag, () => {});
    final nested = RegExp(
      r'<subfield\b[^>]*\bcode="([^"]+)"[^>]*>(.*?)</subfield>',
      dotAll: true,
    );
    for (final sub in nested.allMatches(match.group(2) ?? '')) {
      final code = sub.group(1) ?? '';
      final text = _marc(sub.group(2) ?? '');
      if (code.isEmpty || text.isEmpty || subs.containsKey(code)) {
        continue;
      }
      subs[code] = text;
    }
  }
  return fields;
}

String _control(String record, String tag) {
  final match = RegExp(
    '<controlfield\\b[^>]*\\btag="$tag"[^>]*>(.*?)</controlfield>',
    dotAll: true,
  ).firstMatch(record);
  return (match?.group(1) ?? '').replaceAll(RegExp(r'\D'), '');
}

String _sub(Map<String, String>? field, String code) => field?[code] ?? '';

String _marc(String raw) {
  final text = raw
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#34;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll(RegExp(r'\[Текст\]', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return text.replaceAll(RegExp(r'\s*[:;/]+\s*$'), '').trim();
}

bool _volumeOnly(String title) {
  return RegExp(
    r'^(Кн|Книга|Том|Ч)\.?\s*\d+$',
    caseSensitive: false,
  ).hasMatch(title);
}

String _parentTitle(String value) {
  if (value.isEmpty) {
    return '';
  }
  return value.split(RegExp(r'\s[/:]')).first.trim();
}

String _year(String value) {
  return RegExp(r'\d{4}').firstMatch(value)?.group(0) ?? '';
}

String _imprint(String publisher, String year, {required String fallback}) {
  final base = publisher.isNotEmpty ? publisher : _marc(fallback);
  if (base.isEmpty) {
    return year;
  }
  if (year.isEmpty || base.contains(year)) {
    return base;
  }
  return '$base, $year';
}

String _isbn(String raw) {
  return isbnFromText(raw) ?? '';
}

int? _volume(String raw) {
  final match = RegExp(r'\d+').firstMatch(raw);
  if (match == null) {
    return null;
  }
  final value = int.tryParse(match.group(0)!);
  if (value == null || value < 1) {
    return null;
  }
  return value;
}
