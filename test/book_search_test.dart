import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/core/search/book_search.dart';

void main() {
  final now = DateTime.utc(2026, 11, 5);
  final books = [
    BookSearchRecord(
      id: 1,
      title: 'Мастер и Маргарита',
      description: 'Роман. Действие: Москва.',
      authors: const ['Михаил Булгаков'],
      genres: const ['Роман'],
      publishers: const ['Художественная литература'],
      hashtags: const ['классика'],
      roomId: 1,
      cabinetId: 10,
      locationPath: 'Гостиная → Шкаф → Полка 1 → Ряд 1 → 1-я слева',
      createdAt: now,
    ),
    BookSearchRecord(
      id: 2,
      title: 'Собачье сердце',
      subtitle: 'Повесть',
      isbn: '9785170123456',
      authors: const ['Михаил Булгаков'],
      genres: const ['Фантастика'],
      hashtags: const ['фантастика'],
      roomId: 2,
      cabinetId: 20,
      locationPath: 'Кабинет → Шкаф → Полка 2 → Ряд 1 → 1-я слева',
      createdAt: now,
    ),
    BookSearchRecord(
      id: 3,
      title: 'Без полки',
      description: 'Черновик',
      createdAt: now,
    ),
  ];

  test('every query token must match somewhere in the record', () {
    final found = filterBooks(
      books,
      const SearchFilter(query: 'булгаков москва'),
    );

    expect(found.map((book) => book.id), [1]);
  });

  test('matching is case-insensitive across author, genre, and isbn', () {
    expect(
      filterBooks(books, const SearchFilter(query: 'ФАНТАСТИКА')).map(
        (book) => book.id,
      ),
      [2],
    );
    expect(
      filterBooks(books, const SearchFilter(query: '9785170123456')).single.id,
      2,
    );
  });

  test('room, cabinet, and hashtag filters are exact', () {
    expect(
      filterBooks(books, const SearchFilter(roomId: 1)).single.id,
      1,
    );
    expect(
      filterBooks(books, const SearchFilter(cabinetId: 20)).single.id,
      2,
    );
    expect(
      filterBooks(books, const SearchFilter(hashtag: '#Классика')).single.id,
      1,
    );
    expect(
      filterBooks(
        books,
        const SearchFilter(query: 'булгаков', cabinetId: 10),
      ).single.id,
      1,
    );
  });

  test('an empty query keeps every book that passes the filters', () {
    expect(filterBooks(books, const SearchFilter()), hasLength(3));
    expect(
      filterBooks(books, const SearchFilter(roomId: 9)),
      isEmpty,
    );
  });
}
