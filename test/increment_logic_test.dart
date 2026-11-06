import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/core/format/external_url.dart';
import 'package:my_library/core/format/row_capacity.dart';
import 'package:my_library/core/search/book_search.dart';
import 'package:my_library/core/search/duplicates.dart';
import 'package:my_library/core/theme/theme_choice.dart';

void main() {
  test('series name is part of the search text', () {
    final books = [
      BookSearchRecord(
        id: 1,
        title: 'Ученик',
        seriesName: 'Тёмный лес',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
      BookSearchRecord(
        id: 2,
        title: 'Другая',
        createdAt: DateTime.utc(2026, 1, 2),
      ),
    ];

    expect(
      filterBooks(books, const SearchFilter(query: 'тёмный')).single.id,
      1,
    );
  });

  test('duplicate detection uses ISBN before title and authors', () {
    const existing = [
      DuplicateCandidate(
        id: 4,
        title: 'Мастер и Маргарита',
        isbn: '9780306406157',
        authors: ['Булгаков'],
        locationPath: 'Гостиная → Шкаф → Полка 1 → Ряд 1 → 1-я слева',
      ),
    ];

    final byIsbn = findDuplicateCopies(
      candidate: const DuplicateCandidate(
        id: null,
        title: 'Другое имя',
        isbn: '978-0-306-40615-7',
        authors: ['Кто-то'],
        locationPath: '',
      ),
      existing: existing,
    );
    expect(byIsbn.single.reason, DuplicateReason.isbn);
    expect(byIsbn.single.locationPath, contains('Гостиная'));

    final byTitle = findDuplicateCopies(
      candidate: const DuplicateCandidate(
        id: null,
        title: '  мастер   и маргарита ',
        isbn: '',
        authors: ['булгаков'],
        locationPath: '',
      ),
      existing: existing,
    );
    expect(byTitle.single.reason, DuplicateReason.titleAndAuthors);

    final sameCopy = findDuplicateCopies(
      candidate: const DuplicateCandidate(
        id: 4,
        title: 'Мастер и Маргарита',
        isbn: '9780306406157',
        authors: ['Булгаков'],
        locationPath: '',
      ),
      existing: existing,
    );
    expect(sameCopy, isEmpty);

    final differentAuthors = findDuplicateCopies(
      candidate: const DuplicateCandidate(
        id: null,
        title: 'Мастер и Маргарита',
        isbn: '',
        authors: ['Булгаков', 'Иванов'],
        locationPath: '',
      ),
      existing: existing,
    );
    expect(differentAuthors, isEmpty);
  });

  test('row capacity is unlimited until the count exceeds it', () {
    expect(rowIsOverfull(bookCount: 9, capacity: null), isFalse);
    expect(rowIsOverfull(bookCount: 3, capacity: 3), isFalse);
    expect(rowIsOverfull(bookCount: 4, capacity: 3), isTrue);
  });

  test('theme choice round-trips and unknown values follow the system', () {
    expect(themeChoiceFromStorage(themeChoiceStorage(AppThemeChoice.dark)), AppThemeChoice.dark);
    expect(themeChoiceFromStorage(themeChoiceStorage(AppThemeChoice.light)), AppThemeChoice.light);
    expect(themeChoiceFromStorage(null), AppThemeChoice.system);
    expect(themeChoiceFromStorage('sepia'), AppThemeChoice.system);
    expect(themeChoiceLabel(AppThemeChoice.system), 'Как в системе');
  });

  test('only http and https URLs can be opened', () {
    expect(isAllowedExternalUrl('https://www.livelib.ru/book/1'), isTrue);
    expect(isAllowedExternalUrl('http://shop.example/book'), isTrue);
    expect(isAllowedExternalUrl('javascript:alert(1)'), isFalse);
    expect(isAllowedExternalUrl('file:///tmp/book'), isFalse);
    expect(isAllowedExternalUrl('https://'), isFalse);
    expect(isAllowedExternalUrl('не ссылка'), isFalse);
  });
}
