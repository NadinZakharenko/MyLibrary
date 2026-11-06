import 'package:my_library/core/format/location_path.dart';
import 'package:my_library/core/models/book_copy.dart';
import 'package:my_library/core/models/reading_status.dart';

class RoomOverview {
  const RoomOverview({
    required this.id,
    required this.name,
    required this.note,
    required this.cabinets,
  });

  final int id;
  final String name;
  final String note;
  final List<CabinetOverview> cabinets;
}

class CabinetOverview {
  const CabinetOverview({
    required this.id,
    required this.name,
    required this.shelves,
  });

  final int id;
  final String name;
  final List<ShelfTick> shelves;
}

class ShelfTick {
  const ShelfTick({
    required this.id,
    required this.index,
    required this.bookCount,
    required this.overfull,
  });

  final int id;
  final int index;
  final int bookCount;
  final bool overfull;
}

class HomeSnapshot {
  const HomeSnapshot({
    required this.totalBooks,
    required this.addedLast7Days,
    required this.unplacedBooks,
    required this.wantToReadCount,
    required this.readingCount,
    required this.finishedCount,
    required this.lentCount,
    required this.overdueLoans,
    required this.recent,
    required this.rooms,
    this.libraryBooks = 0,
    this.libraryReturns = const [],
  });

  final int totalBooks;
  final int addedLast7Days;
  final int unplacedBooks;
  final int wantToReadCount;
  final int readingCount;
  final int finishedCount;
  final int lentCount;
  final List<BookSummary> overdueLoans;
  final List<BookSummary> recent;
  final List<RoomOverview> rooms;
  final int libraryBooks;
  final List<BookSummary> libraryReturns;

  static const empty = HomeSnapshot(
    totalBooks: 0,
    addedLast7Days: 0,
    unplacedBooks: 0,
    wantToReadCount: 0,
    readingCount: 0,
    finishedCount: 0,
    lentCount: 0,
    overdueLoans: [],
    recent: [],
    rooms: [],
  );
}

class CabinetDetails {
  const CabinetDetails({
    required this.id,
    required this.roomId,
    required this.roomName,
    required this.name,
    required this.shelves,
  });

  final int id;
  final int roomId;
  final String roomName;
  final String name;
  final List<ShelfInfo> shelves;
}

class ShelfInfo {
  const ShelfInfo({
    required this.id,
    required this.cabinetId,
    required this.index,
    required this.label,
    required this.filled,
    required this.bookCount,
    required this.rows,
  });

  final int cabinetId;
  final int id;
  final int index;
  final String? label;
  final bool filled;
  final int bookCount;
  final List<RowInfo> rows;

  int get rowCount => rows.length;

  bool get overfull => rows.any((row) => row.overfull);

  String get title => shelfPlaceTitle(index, label);
}

class RowInfo {
  const RowInfo({
    required this.id,
    required this.index,
    required this.label,
    required this.bookCount,
    required this.capacity,
    required this.overfull,
  });

  final int id;
  final int index;
  final String? label;
  final int bookCount;
  final int? capacity;
  final bool overfull;

  String get title => rowPlaceTitle(index, label);
}

class BookSummary {
  const BookSummary({
    required this.id,
    required this.title,
    required this.authorsLabel,
    required this.genresLabel,
    required this.locationPath,
    required this.positionIndex,
    required this.createdAt,
    this.coverPath,
    this.roomId,
    this.cabinetId,
    this.shelfId,
    this.rowId,
    this.readingStatus = ReadingStatus.wantToRead,
    this.statusChangedAt,
    this.seriesName = '',
    this.seriesVolume,
    this.loanPerson = '',
    this.loanDueAt,
    this.format = BookFormat.print,
    this.placement = BookPlacement.shelf,
    this.libraryDueAt,
    this.yandexId = '',
    this.narrator = '',
    this.durationSeconds,
  });

  final int id;
  final String title;
  final String authorsLabel;
  final String genresLabel;
  final String? coverPath;
  final String locationPath;
  final int positionIndex;
  final DateTime createdAt;
  final int? roomId;
  final int? cabinetId;
  final int? shelfId;
  final int? rowId;
  final ReadingStatus readingStatus;
  final DateTime? statusChangedAt;
  final String seriesName;
  final int? seriesVolume;
  final String loanPerson;
  final DateTime? loanDueAt;
  final BookFormat format;
  final BookPlacement placement;
  final DateTime? libraryDueAt;
  final String yandexId;
  final String narrator;
  final int? durationSeconds;
}

class BookDetails {
  const BookDetails({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    this.personalNote = '',
    required this.isbn,
    required this.authors,
    required this.genres,
    required this.publishers,
    required this.hashtags,
    required this.photoPaths,
    required this.sourceUrl,
    required this.locationPath,
    required this.positionIndex,
    required this.createdAt,
    this.coverPath,
    this.shelfId,
    this.rowId,
    this.roomId,
    this.cabinetId,
    this.readingStatus = ReadingStatus.wantToRead,
    this.statusChangedAt,
    this.seriesName = '',
    this.seriesVolume,
    this.loanPerson = '',
    this.loanDueAt,
    this.format = BookFormat.print,
    this.placement = BookPlacement.shelf,
    this.libraryDueAt,
    this.yandexId = '',
    this.narrator = '',
    this.durationSeconds,
    this.readerRating,
  });

  final int id;
  final String title;
  final String subtitle;
  final String description;
  final String personalNote;
  final String isbn;
  final List<String> authors;
  final List<String> genres;
  final List<String> publishers;
  final List<String> hashtags;
  final String? coverPath;
  final List<String> photoPaths;
  final String sourceUrl;
  final String locationPath;
  final int positionIndex;
  final DateTime createdAt;
  final int? shelfId;
  final int? rowId;
  final int? roomId;
  final int? cabinetId;
  final ReadingStatus readingStatus;
  final DateTime? statusChangedAt;
  final String seriesName;
  final int? seriesVolume;
  final String loanPerson;
  final DateTime? loanDueAt;
  final BookFormat format;
  final BookPlacement placement;
  final DateTime? libraryDueAt;
  final String yandexId;
  final String narrator;
  final int? durationSeconds;
  final int? readerRating;
}

class RowPageData {
  const RowPageData({
    required this.shelf,
    required this.row,
    required this.roomName,
    required this.cabinetName,
    required this.books,
  });

  final ShelfInfo shelf;
  final RowInfo row;
  final String roomName;
  final String cabinetName;
  final List<BookSummary> books;
}

class LocationOption {
  const LocationOption({
    required this.roomId,
    required this.roomName,
    required this.cabinetId,
    required this.cabinetName,
    required this.shelfId,
    required this.shelfIndex,
    required this.shelfLabel,
    required this.shelfFilled,
    required this.rows,
  });

  final int roomId;
  final String roomName;
  final int cabinetId;
  final String cabinetName;
  final int shelfId;
  final int shelfIndex;
  final String? shelfLabel;
  final bool shelfFilled;
  final List<RowInfo> rows;
}
