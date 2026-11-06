import 'package:drift/drift.dart';
import 'package:my_library/core/database/tables.dart';

part 'app_database.g.dart';

const currentSchemaVersion = 6;

@DriftDatabase(
  tables: [
    Rooms,
    Cabinets,
    Shelves,
    ShelfRows,
    Books,
    BookPhotos,
    Authors,
    Genres,
    Publishers,
    Hashtags,
    BookAuthors,
    BookGenres,
    BookPublishers,
    BookHashtags,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(books, books.readingStatus);
        await migrator.addColumn(books, books.statusChangedAt);
        await migrator.addColumn(books, books.seriesName);
        await migrator.addColumn(books, books.seriesVolume);
        await migrator.addColumn(books, books.loanPerson);
        await migrator.addColumn(books, books.loanDueAt);
        await migrator.addColumn(shelfRows, shelfRows.capacity);
        await customStatement(
          'UPDATE books SET status_changed_at = created_at',
        );
      }
      if (from < 3) {
        await migrator.addColumn(shelves, shelves.filled);
      }
      if (from < 4) {
        await migrator.addColumn(shelfRows, shelfRows.label);
      }
      if (from < 5) {
        await migrator.addColumn(books, books.personalNote);
      }
      if (from < 6) {
        await migrator.addColumn(books, books.bookFormat);
        await migrator.addColumn(books, books.placement);
        await migrator.addColumn(books, books.yandexId);
        await migrator.addColumn(books, books.narrator);
        await migrator.addColumn(books, books.durationSeconds);
        await migrator.addColumn(books, books.libraryDueAt);
        await migrator.addColumn(books, books.readerRating);
        await migrator.addColumn(books, books.reminderSentForDue);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
