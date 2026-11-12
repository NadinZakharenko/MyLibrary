import 'dart:convert';

import 'package:my_library/core/isbn.dart';

class RecognizedSpine {
  const RecognizedSpine({
    required this.title,
    required this.author,
    required this.uncertain,
    this.isbn = '',
  });

  final String title;
  final String author;
  final bool uncertain;
  final String isbn;
}

class RecognizedShelf {
  const RecognizedShelf({required this.books});

  final List<RecognizedSpine> books;
}

class ShelfReadingException implements Exception {
  const ShelfReadingException(this.message);

  final String message;

  @override
  String toString() => message;
}

const shelfReadingPrompt = '''
На фото русские корешки книг. Полок на снимке может быть одна, две или три, сверху вниз. Книги на каждой полке идут слева направо.
Верни только JSON такого вида:
{"shelves":[{"books":[{"title":"","author":"","isbn":"","uncertain":false}]}]}
title и author — только текст, который виден на корешке. Пиши кириллицей, как на корешке. Если на корешке латиница, оставь её. Не используй китайские иероглифы. Если текста нет, оставь пустую строку. uncertain поставь true, если чтение сомнительное.
isbn — только цифры ISBN, если они напечатаны на корешке или обложке. Если цифр не видно, оставь пустую строку. Не выдумывай номер, издательство и описание. Не добавляй другие поля.
''';

const _maxShelves = 3;
const _maxBooks = 80;
const _maxField = 120;

List<RecognizedShelf> parseShelfReading(String raw) {
  final extracted = _extractObject(raw);
  if (extracted == null) {
    throw const ShelfReadingException('Kimi вернул непонятный ответ.');
  }
  final Object? decoded;
  try {
    decoded = jsonDecode(extracted);
  } on FormatException {
    throw const ShelfReadingException('Kimi вернул непонятный ответ.');
  }
  if (decoded is! Map) {
    throw const ShelfReadingException('Kimi вернул непонятный ответ.');
  }
  final shelves = decoded['shelves'];
  if (shelves is! List) {
    throw const ShelfReadingException('Kimi вернул непонятный ответ.');
  }
  final parsed = <RecognizedShelf>[];
  for (final shelf in shelves.take(_maxShelves)) {
    if (shelf is! Map) {
      continue;
    }
    final books = shelf['books'];
    if (books is! List) {
      continue;
    }
    final spines = <RecognizedSpine>[];
    for (final book in books.take(_maxBooks)) {
      if (book is! Map) {
        continue;
      }
      final title = _field(book['title']);
      final author = _field(book['author']);
      if (title.isEmpty && author.isEmpty) {
        continue;
      }
      spines.add(
        RecognizedSpine(
          title: title,
          author: author,
          isbn: _isbn(book['isbn']),
          uncertain: book['uncertain'] == true,
        ),
      );
    }
    parsed.add(RecognizedShelf(books: spines));
  }
  return parsed;
}

String? _extractObject(String raw) {
  final start = raw.indexOf('{');
  final end = raw.lastIndexOf('}');
  if (start < 0 || end <= start) {
    return null;
  }
  return raw.substring(start, end + 1);
}

String _isbn(Object? value) {
  if (value is! String) {
    return '';
  }
  return isbnFromText(value) ?? '';
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
  if (!RegExp('[A-Za-zА-Яа-яЁё]').hasMatch(text)) {
    return '';
  }
  if (text.length <= _maxField) {
    return text;
  }
  return text.substring(0, _maxField);
}
