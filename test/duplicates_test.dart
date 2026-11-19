import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/core/search/duplicates.dart';

DuplicateCandidate _book({
  int? id,
  String title = 'Мастер и Маргарита',
  String isbn = '',
  List<String> authors = const [],
}) {
  return DuplicateCandidate(
    id: id,
    title: title,
    isbn: isbn,
    authors: authors,
    locationPath: id == null ? '' : 'Гостиная → Шкаф → Полка 1',
  );
}

List<DuplicateMatch> _check(
  DuplicateCandidate candidate,
  DuplicateCandidate existing,
) {
  return findDuplicateCopies(candidate: candidate, existing: [existing]);
}

void main() {
  test('same ISBN is a duplicate even with another title', () {
    final matches = _check(
      _book(title: 'Другое', isbn: '978-0-306-40615-7', authors: ['Кто-то']),
      _book(id: 1, isbn: '9780306406157', authors: ['Булгаков']),
    );
    expect(matches.single.reason, DuplicateReason.isbn);
    expect(matches.single.id, 1);
    expect(matches.single.locationPath, contains('Гостиная'));
  });

  test('same title and same authors is a duplicate', () {
    final matches = _check(
      _book(title: '  мастер   и маргарита ', authors: ['булгаков']),
      _book(id: 1, authors: ['Булгаков']),
    );
    expect(matches.single.reason, DuplicateReason.titleAndAuthors);
  });

  test('same title without authors on both sides keeps titleAndAuthors', () {
    final matches = _check(_book(), _book(id: 1));
    expect(matches.single.reason, DuplicateReason.titleAndAuthors);
  });

  test('same title with author missing on the new book is titleOnly', () {
    final matches = _check(_book(), _book(id: 1, authors: ['Булгаков']));
    expect(matches.single.reason, DuplicateReason.titleOnly);
  });

  test('same title with author missing on the stored book is titleOnly', () {
    final matches = _check(
      _book(authors: ['Булгаков']),
      _book(id: 1, authors: const ['  ']),
    );
    expect(matches.single.reason, DuplicateReason.titleOnly);
  });

  test('same title with different authors is not a duplicate', () {
    expect(
      _check(
        _book(authors: ['Булгаков', 'Иванов']),
        _book(id: 1, authors: ['Булгаков']),
      ),
      isEmpty,
    );
    expect(
      _check(_book(authors: ['Иванов']), _book(id: 1, authors: ['Булгаков'])),
      isEmpty,
    );
  });

  test('different title without authors is not a duplicate', () {
    expect(_check(_book(title: 'Белая гвардия'), _book(id: 1)), isEmpty);
  });

  test('every reason has a Russian label', () {
    expect(duplicateReasonLabel(DuplicateReason.isbn), 'тот же ISBN');
    expect(
      duplicateReasonLabel(DuplicateReason.titleAndAuthors),
      'то же название и те же авторы',
    );
    expect(
      duplicateReasonLabel(DuplicateReason.titleOnly),
      'то же название (автор не указан)',
    );
  });
}
