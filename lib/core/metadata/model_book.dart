import 'dart:convert';

import 'package:my_library/core/models/metadata_candidate.dart';

String modelBookPrompt({String? isbn, String title = '', String author = ''}) {
  final lines = <String>[
    if (isbn != null && isbn.trim().isNotEmpty) 'ISBN ${isbn.trim()}',
    if (title.trim().isNotEmpty) 'Название: ${title.trim()}',
    if (author.trim().isNotEmpty) 'Автор: ${author.trim()}',
  ];
  return '''
Найди книгу по запросу. Верни только JSON:
{"title":"","author":"","publisher":"","year":"","series":""}
Если книгу не знаешь, оставь строки пустыми. Не выдумывай ISBN и не добавляй других полей. Для русской книги пиши кириллицей.
${lines.join('\n')}
''';
}

List<MetadataCandidate> candidatesFromModel(String raw) {
  final extracted = _object(raw);
  if (extracted == null) {
    return const [];
  }
  final Object? decoded;
  try {
    decoded = jsonDecode(extracted);
  } on FormatException {
    return const [];
  }
  if (decoded is! Map) {
    return const [];
  }
  final title = _field(decoded['title']);
  if (title.isEmpty || !RegExp('[A-Za-zА-Яа-яЁё]').hasMatch(title)) {
    return const [];
  }
  final author = _letters(_field(decoded['author']));
  final year =
      RegExp(r'\d{4}').firstMatch(_field(decoded['year']))?.group(0) ?? '';
  final publisherName = _field(decoded['publisher']);
  final publisher = publisherName.isEmpty
      ? year
      : (year.isEmpty || publisherName.contains(year)
            ? publisherName
            : '$publisherName, $year');
  return [
    MetadataCandidate(
      source: MetadataSource.model,
      title: title,
      authors: author.isEmpty ? const [] : [author],
      publisher: publisher,
      year: year,
      seriesName: _field(decoded['series']),
    ),
  ];
}

String? _object(String raw) {
  final start = raw.indexOf('{');
  final end = raw.lastIndexOf('}');
  if (start < 0 || end <= start) {
    return null;
  }
  return raw.substring(start, end + 1);
}

String _letters(String text) {
  if (!RegExp('[A-Za-zА-Яа-яЁё]').hasMatch(text)) {
    return '';
  }
  return text;
}

String _field(Object? value) {
  if (value is! String) {
    return '';
  }
  final text = value
      .replaceAll(RegExp(r'https?://\S+', caseSensitive: false), '')
      .replaceAll(RegExp(r'[\u0000-\u001F]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (text.length <= 120) {
    return text;
  }
  return text.substring(0, 120);
}
