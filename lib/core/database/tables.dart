import 'package:drift/drift.dart';

@DataClassName('Room')
class Rooms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('Cabinet')
class Cabinets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get roomId => integer().references(Rooms, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('Shelf')
class Shelves extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cabinetId =>
      integer().references(Cabinets, #id, onDelete: KeyAction.cascade)();
  IntColumn get shelfIndex => integer()();
  TextColumn get label => text().nullable()();
  BoolColumn get filled => boolean().withDefault(const Constant(false))();
}

@DataClassName('ShelfRow')
class ShelfRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get shelfId =>
      integer().references(Shelves, #id, onDelete: KeyAction.cascade)();
  IntColumn get rowIndex => integer()();
  TextColumn get label => text().nullable()();
  IntColumn get capacity => integer().nullable()();
}

@DataClassName('Book')
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get personalNote => text().withDefault(const Constant(''))();
  TextColumn get isbn => text().nullable()();
  TextColumn get coverPath => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  IntColumn get shelfId =>
      integer().nullable().references(Shelves, #id, onDelete: KeyAction.setNull)();
  IntColumn get rowId =>
      integer().nullable().references(ShelfRows, #id, onDelete: KeyAction.setNull)();
  IntColumn get positionIndex => integer().withDefault(const Constant(0))();
  TextColumn get readingStatus =>
      text().withDefault(const Constant('wantToRead'))();
  DateTimeColumn get statusChangedAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get seriesName => text().nullable()();
  IntColumn get seriesVolume => integer().nullable()();
  TextColumn get loanPerson => text().nullable()();
  DateTimeColumn get loanDueAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get bookFormat => text().withDefault(const Constant('print'))();
  TextColumn get placement => text().withDefault(const Constant('shelf'))();
  TextColumn get yandexId => text().nullable()();
  TextColumn get narrator => text().withDefault(const Constant(''))();
  IntColumn get durationSeconds => integer().nullable()();
  DateTimeColumn get libraryDueAt => dateTime().nullable()();
  IntColumn get readerRating => integer().nullable()();
  DateTimeColumn get reminderSentForDue => dateTime().nullable()();
}

@DataClassName('BookPhoto')
class BookPhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get path => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('Author')
class Authors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get nameKey => text().unique()();
}

@DataClassName('Genre')
class Genres extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get nameKey => text().unique()();
}

@DataClassName('Publisher')
class Publishers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get nameKey => text().unique()();
}

@DataClassName('Hashtag')
class Hashtags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nameKey => text().unique()();
  TextColumn get displayName => text()();
}

@DataClassName('BookAuthorLink')
class BookAuthors extends Table {
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get authorId =>
      integer().references(Authors, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {bookId, authorId};
}

@DataClassName('BookGenreLink')
class BookGenres extends Table {
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get genreId =>
      integer().references(Genres, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {bookId, genreId};
}

@DataClassName('BookPublisherLink')
class BookPublishers extends Table {
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get publisherId =>
      integer().references(Publishers, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {bookId, publisherId};
}

@DataClassName('BookHashtagLink')
class BookHashtags extends Table {
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get hashtagId =>
      integer().references(Hashtags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {bookId, hashtagId};
}

@DataClassName('AppSetting')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
