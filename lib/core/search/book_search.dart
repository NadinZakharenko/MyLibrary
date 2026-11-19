import 'package:my_library/core/format/hashtag.dart';
import 'package:my_library/core/models/book_copy.dart';
import 'package:my_library/core/models/reading_status.dart';

/// Fields the search screen is allowed to match and filter on.
class BookSearchRecord {
  const BookSearchRecord({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.description = '',
    this.isbn = '',
    this.authors = const [],
    this.genres = const [],
    this.publishers = const [],
    this.hashtags = const [],
    this.seriesName = '',
    this.roomId,
    this.cabinetId,
    this.shelfId,
    this.locationPath = '',
    this.coverPath,
    this.readingStatus = ReadingStatus.wantToRead,
    this.format = BookFormat.print,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String subtitle;
  final String description;
  final String isbn;
  final List<String> authors;
  final List<String> genres;
  final List<String> publishers;

  /// Already normalized hashtag keys.
  final List<String> hashtags;
  final String seriesName;
  final int? roomId;
  final int? cabinetId;
  final int? shelfId;
  final String locationPath;
  final String? coverPath;
  final ReadingStatus readingStatus;
  final BookFormat format;
  final DateTime createdAt;

  String get authorsLabel => authors.join(', ');
}

class SearchFilter {
  const SearchFilter({
    this.query = '',
    this.roomId,
    this.cabinetId,
    this.hashtag,
    this.format,
  });

  /// Empty means both printed books and audiobooks.

  final String query;
  final int? roomId;
  final int? cabinetId;

  /// Raw user input. Compared after [normalizeHashtag].
  final String? hashtag;
  final BookFormat? format;
}

final _spaces = RegExp(r'\s+');

/// Search text per record; records are rebuilt when the library changes.
final _haystacks = Expando<String>();

/// Every non-empty query token must occur in title, subtitle, description,
/// ISBN, series, author, genre, publisher, or hashtag. Room, cabinet, and
/// hashtag filters are exact.
List<BookSearchRecord> filterBooks(
  List<BookSearchRecord> books,
  SearchFilter filter,
) {
  final tokens = filter.query
      .trim()
      .toLowerCase()
      .split(_spaces)
      .where((token) => token.isNotEmpty)
      .toList();
  final hashtagKey = filter.hashtag == null
      ? null
      : normalizeHashtag(filter.hashtag!);

  return [
    for (final book in books)
      if (_matches(book, filter, tokens, hashtagKey)) book,
  ];
}

bool bookMatchesSearch(BookSearchRecord book, SearchFilter filter) {
  return filterBooks([book], filter).isNotEmpty;
}

bool _matches(
  BookSearchRecord book,
  SearchFilter filter,
  List<String> tokens,
  String? hashtagKey,
) {
  if (filter.roomId != null && book.roomId != filter.roomId) {
    return false;
  }
  if (filter.cabinetId != null && book.cabinetId != filter.cabinetId) {
    return false;
  }
  if (hashtagKey != null && !book.hashtags.contains(hashtagKey)) {
    return false;
  }
  if (filter.format != null && book.format != filter.format) {
    return false;
  }
  if (tokens.isEmpty) {
    return true;
  }
  final haystack = _haystacks[book] ??= [
    book.title,
    book.subtitle,
    book.description,
    book.isbn,
    book.seriesName,
    ...book.authors,
    ...book.genres,
    ...book.publishers,
    ...book.hashtags,
  ].join('\n').toLowerCase();
  for (final token in tokens) {
    if (!haystack.contains(token)) {
      return false;
    }
  }
  return true;
}
