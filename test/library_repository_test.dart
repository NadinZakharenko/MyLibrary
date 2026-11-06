import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/core/database/app_database.dart';
import 'package:my_library/core/models/book_draft.dart';
import 'package:my_library/core/models/shelf_model.dart';
import 'package:my_library/core/models/dictionary_kind.dart';
import 'package:my_library/core/search/book_search.dart';
import 'package:my_library/core/storage/image_store.dart';
import 'package:my_library/core/storage/library_paths.dart';
import 'package:my_library/core/models/reading_status.dart';
import 'package:my_library/core/search/duplicates.dart';
import 'package:my_library/core/theme/theme_choice.dart';
import 'package:my_library/data/backup_service.dart';
import 'package:my_library/data/library_repository.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory temp;
  late AppDatabase db;
  late LibraryRepository repo;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('mylibrary_test_');
    final paths = LibraryPaths(temp);
    db = AppDatabase(NativeDatabase.memory());
    repo = LibraryRepository(db, ImageStore(paths));
    await repo.images.ensureDirs();
  });

  tearDown(() async {
    await db.close();
    if (await temp.exists()) {
      await temp.delete(recursive: true);
    }
  });

  test('builds the location path and counts shelves from rows', () async {
    final roomId = await repo.createRoom(name: 'Гостиная');
    final cabinetId = await repo.createCabinet(
      roomId: roomId,
      name: 'Шкаф у окна',
      shelfCount: 3,
      rowsPerShelf: 2,
    );
    final cabinet = await repo.cabinet(cabinetId);
    expect(cabinet!.shelves, hasLength(3));
    expect(cabinet.shelves[2].index, 2);
    expect(cabinet.shelves[2].rowCount, 2);

    final row = cabinet.shelves[2].rows[1];
    for (var index = 0; index < 4; index++) {
      await repo.createBook(
        BookDraft(title: 'Книга $index', shelfId: cabinet.shelves[2].id, rowId: row.id),
      );
    }

    final page = await repo.rowPage(row.id);
    expect(
      page!.books.last.locationPath,
      'Гостиная → Шкаф у окна → Полка 3 → Ряд 2 → 4-я слева',
    );
    expect(page.books.first.locationPath, contains('1-я слева'));

    final home = await repo.loadHome();
    final ticks = home.rooms.single.cabinets.single.shelves;
    expect(ticks, hasLength(3));
    expect(ticks[2].bookCount, 4);
    expect(ticks[0].bookCount, 0);
  });

  test('drops the bottom shelf and row and keeps the books', () async {
    final roomId = await repo.createRoom(name: 'Гостиная');
    final cabinetId = await repo.createCabinet(
      roomId: roomId,
      name: 'Шкаф',
      shelfCount: 2,
      rowsPerShelf: 2,
    );
    final cabinet = await repo.cabinet(cabinetId);
    final bottom = cabinet!.shelves[1];
    await repo.createBook(
      BookDraft(
        title: 'Нижняя',
        shelfId: bottom.id,
        rowId: bottom.rows.last.id,
      ),
    );

    await repo.resizeShelfRows(shelfId: bottom.id, rowCount: 1);
    expect((await repo.unplacedBooks()).single.title, 'Нижняя');

    await repo.resizeCabinetShelves(cabinetId: cabinetId, shelfCount: 1);
    final after = await repo.cabinet(cabinetId);
    expect(after!.shelves, hasLength(1));
    expect(after.shelves.single.rowCount, 2);

    await repo.resizeCabinetShelves(cabinetId: cabinetId, shelfCount: 2);
    final grown = await repo.cabinet(cabinetId);
    expect(grown!.shelves, hasLength(2));
    expect(grown.shelves.last.rowCount, 1);
  });

  test('keeps Kimi when the key and consent were already saved', () async {
    expect(await repo.shelfModel(), ShelfModelChoice.off);
    await repo.setKimiApiKey('kimi-key-value');
    await repo.setKimiCloudConsent(true);
    expect(await repo.shelfModel(), ShelfModelChoice.kimi);
    await repo.setShelfModel(ShelfModelChoice.off);
    expect(await repo.shelfModel(), ShelfModelChoice.off);
  });

  test('counts unplaced books and excludes copies older than 7 days', () async {
    await repo.createBook(const BookDraft(title: 'Свежая'));
    final oldId = await repo.createBook(const BookDraft(title: 'Старая'));
    await (db.update(db.books)..where((row) => row.id.equals(oldId))).write(
      BooksCompanion(
        createdAt: Value(DateTime.now().toUtc().subtract(const Duration(days: 8))),
      ),
    );

    final home = await repo.loadHome();
    expect(home.totalBooks, 2);
    expect(home.unplacedBooks, 2);
    expect(home.addedLast7Days, 1);
    expect((await repo.unplacedBooks()).map((book) => book.title), [
      'Свежая',
      'Старая',
    ]);
    expect((await repo.bookDetails(oldId))!.locationPath, 'без места');
  });

  test('stores one hashtag for different spellings and filters by it', () async {
    await repo.createBook(
      const BookDraft(title: 'Первая', hashtags: ['#Фантастика', '##Фантастика']),
    );
    await repo.createBook(
      const BookDraft(title: 'Вторая', hashtags: ['фантастика']),
    );

    final tags = await db.select(db.hashtags).get();
    expect(tags, hasLength(1));
    expect(tags.single.nameKey, 'фантастика');
    expect(tags.single.displayName, 'Фантастика');

    final found = filterBooks(
      await repo.searchRecords(),
      const SearchFilter(hashtag: '#ФАНТАСТИКА', query: 'вторая'),
    );
    expect(found, hasLength(1));
    expect(found.single.title, 'Вторая');
    expect(await repo.suggest(DictionaryKind.hashtag, '#'), ['Фантастика']);
  });

  test('detaches books when a shelf is deleted and deletes only one copy', () async {
    final roomId = await repo.createRoom(name: 'Кабинет');
    final cabinetId = await repo.createCabinet(
      roomId: roomId,
      name: 'Шкаф',
      shelfCount: 1,
      rowsPerShelf: 1,
    );
    final shelf = (await repo.cabinet(cabinetId))!.shelves.single;
    final kept = await repo.createBook(
      BookDraft(
        title: 'Остаётся',
        authors: const ['Автор'],
        shelfId: shelf.id,
      ),
    );
    final removed = await repo.createBook(
      BookDraft(title: 'Удаляется', authors: const ['Автор'], shelfId: shelf.id),
    );

    expect((await repo.bookDetails(kept))!.rowId, shelf.rows.single.id);
    await repo.deleteShelf(shelf.id);
    final detached = await repo.bookDetails(kept);
    expect(detached!.shelfId, isNull);
    expect(detached.rowId, isNull);
    expect(detached.locationPath, 'без места');
    expect(await repo.bookDetails(removed), isNotNull);

    await repo.deleteBook(removed);
    expect(await repo.bookDetails(removed), isNull);
    expect((await repo.bookDetails(kept))!.title, 'Остаётся');
    expect(await db.select(db.authors).get(), hasLength(1));
  });

  test('reorders books left to right and requires a row on a multi-row shelf', () async {
    final roomId = await repo.createRoom(name: 'Гостиная');
    final cabinetId = await repo.createCabinet(
      roomId: roomId,
      name: 'Шкаф',
      shelfCount: 1,
      rowsPerShelf: 2,
    );
    final shelf = (await repo.cabinet(cabinetId))!.shelves.single;
    final row = shelf.rows.first;
    final first = await repo.createBook(
      BookDraft(title: 'Левая', shelfId: shelf.id, rowId: row.id),
    );
    final second = await repo.createBook(
      BookDraft(title: 'Правая', shelfId: shelf.id, rowId: row.id),
    );

    await repo.reorderBooks(rowId: row.id, orderedIds: [second, first]);
    final page = await repo.rowPage(row.id);
    expect(page!.books.map((book) => book.id), [second, first]);
    expect(page.books.first.locationPath, endsWith('1-я слева'));
    expect(page.books.last.locationPath, endsWith('2-я слева'));

    expect(
      () => repo.createBook(BookDraft(title: 'Без ряда', shelfId: shelf.id)),
      throwsA(isA<ChooseRowException>()),
    );
  });

  test('round-trips a backup and rejects an unsafe archive path', () async {
    final relative = await repo.images.saveBytes(
      Uint8List.fromList(List<int>.filled(80, 7)),
      cover: true,
    );
    final id = await repo.createBook(
      BookDraft(title: 'Архив', coverPath: relative),
    );
    final bytes = await BackupService().buildArchive(
      db: db,
      paths: repo.images.paths,
    );

    final restoredRoot = await Directory.systemTemp.createTemp('mylibrary_restore_');
    addTearDown(() async {
      if (await restoredRoot.exists()) {
        await restoredRoot.delete(recursive: true);
      }
    });
    final restoredPaths = LibraryPaths(restoredRoot);
    await BackupService().restore(paths: restoredPaths, bytes: bytes);
    final restoredDb = AppDatabase(NativeDatabase(restoredPaths.databaseFile));
    addTearDown(restoredDb.close);
    final restored = LibraryRepository(restoredDb, ImageStore(restoredPaths));
    final book = await restored.bookDetails(id);
    expect(book!.title, 'Архив');
    expect(restored.images.resolve(book.coverPath!)!.existsSync(), isTrue);

    final hostile = ArchiveBuilder.unsafe();
    expect(
      () => BackupService().restore(paths: restoredPaths, bytes: hostile),
      throwsA(isA<BackupException>()),
    );
  });

  test('image paths cannot leave the media folder', () {
    expect(repo.images.resolve('covers/a.jpg'), isNotNull);
    expect(repo.images.resolve('../library.sqlite'), isNull);
    expect(repo.images.resolve('covers/../../library.sqlite'), isNull);
    expect(repo.images.resolve('..\\library.sqlite'), isNull);
    expect(repo.images.resolve('/etc/hosts'), isNull);
    expect(repo.images.resolve('${temp.absolute.path}/x.jpg'), isNull);
  });

  test('backup drops the API key and a broken archive keeps the library', () async {
    await repo.setKimiApiKey('kimi-archive-secret');
    await repo.setYandexApiKey('yandex-archive-secret');
    await repo.setYandexFolderId('b1garchivefolder');
    await repo.createBook(BookDraft(title: 'Из архива'));
    final bytes = await BackupService().buildArchive(
      db: db,
      paths: repo.images.paths,
    );
    final stored = ZipDecoder().decodeBytes(bytes).findFile('library.sqlite')!;
    expect(
      String.fromCharCodes(stored.content).contains('kimi-archive-secret'),
      isFalse,
    );
    expect(
      String.fromCharCodes(stored.content).contains('yandex-archive-secret'),
      isFalse,
    );
    expect(
      String.fromCharCodes(stored.content).contains('b1garchivefolder'),
      isFalse,
    );

    final root = await Directory.systemTemp.createTemp('mylibrary_target_');
    addTearDown(() async {
      try {
        await root.delete(recursive: true);
      } on FileSystemException {
        // Windows can keep a just-closed SQLite file locked for a moment.
      }
    });
    final target = LibraryPaths(root);
    final local = AppDatabase(NativeDatabase(target.databaseFile));
    final localRepo = LibraryRepository(local, ImageStore(target));
    await localRepo.setKimiApiKey('local-kimi-key');
    await localRepo.setYandexApiKey('local-yandex-key');
    await localRepo.setYandexFolderId('b1glocalfolder');
    final localId = await localRepo.createBook(BookDraft(title: 'Своя'));
    await local.close();

    for (final broken in [ArchiveBuilder.notSqlite(), ArchiveBuilder.corrupt()]) {
      await expectLater(
        BackupService().restore(paths: target, bytes: broken),
        throwsA(isA<BackupException>()),
      );
    }
    final kept = AppDatabase(NativeDatabase(target.databaseFile));
    final keptRepo = LibraryRepository(kept, ImageStore(target));
    expect((await keptRepo.bookDetails(localId))!.title, 'Своя');
    await kept.close();

    await BackupService().restore(paths: target, bytes: bytes);
    final restored = AppDatabase(NativeDatabase(target.databaseFile));
    addTearDown(restored.close);
    final restoredRepo = LibraryRepository(restored, ImageStore(target));
    final titles = (await restored.select(restored.books).get())
        .map((book) => book.title)
        .toList();
    expect(titles, ['Из архива']);
    expect(await restoredRepo.kimiApiKey(), 'local-kimi-key');
    expect(await restoredRepo.yandexApiKey(), 'local-yandex-key');
    expect(await restoredRepo.yandexFolderId(), 'b1glocalfolder');
  });

  test('stores reading status, loan, series, theme, and row overflow', () async {
    final finished = DateTime(2026, 3, 1);
    final due = DateTime(2020, 1, 1);
    final id = await repo.createBook(
      BookDraft(
        title: 'Ученик',
        authors: const ['Автор'],
        isbn: '9780306406157',
        readingStatus: ReadingStatus.finished,
        statusChangedAt: finished,
        seriesName: 'Трилогия',
        seriesVolume: 2,
        loanPerson: 'Ира',
        loanDueAt: due,
      ),
    );
    final details = await repo.bookDetails(id);
    expect(details!.readingStatus, ReadingStatus.finished);
    expect(details.statusChangedAt, finished);
    expect(details.seriesName, 'Трилогия');
    expect(details.seriesVolume, 2);
    expect(details.loanPerson, 'Ира');

    final home = await repo.loadHome();
    expect(home.finishedCount, 1);
    expect(home.wantToReadCount, 0);
    expect(home.lentCount, 1);
    expect(home.overdueLoans.single.id, id);

    final found = filterBooks(
      await repo.searchRecords(),
      const SearchFilter(query: 'трилогия'),
    );
    expect(found.single.id, id);

    final copies = await repo.findDuplicates(
      const BookDraft(title: 'Другое', isbn: '978-0-306-40615-7'),
    );
    expect(copies.single.reason, DuplicateReason.isbn);
    expect(
      await repo.findDuplicates(
        const BookDraft(title: 'ученик', authors: ['автор']),
        excludeId: id,
      ),
      isEmpty,
    );

    await repo.returnLoan(id);
    final returned = await repo.bookDetails(id);
    expect(returned!.loanPerson, isEmpty);
    expect(returned.loanDueAt, isNull);
    expect((await repo.loadHome()).lentCount, 0);

    await repo.setThemeChoice(AppThemeChoice.dark);
    expect(await repo.themeChoice(), AppThemeChoice.dark);

    final roomId = await repo.createRoom(name: 'Кабинет');
    final cabinetId = await repo.createCabinet(
      roomId: roomId,
      name: 'Шкаф',
      shelfCount: 1,
      rowsPerShelf: 1,
    );
    final row = (await repo.cabinet(cabinetId))!.shelves.single.rows.single;
    await repo.setRowCapacity(rowId: row.id, capacity: 1);
    await repo.createBook(BookDraft(title: 'Одна', shelfId: row.id));
    await repo.createBook(BookDraft(title: 'Две', shelfId: row.id));
    final shelf = (await repo.cabinet(cabinetId))!.shelves.single;
    expect(shelf.rows.single.overfull, isTrue);
    expect(shelf.overfull, isTrue);
    expect((await repo.loadHome()).rooms.single.cabinets.single.shelves.single.overfull, isTrue);

    expect(await repo.rowOverflowControlEnabled(), isTrue);
    await repo.setRowOverflowControl(false);
    final hidden = (await repo.cabinet(cabinetId))!.shelves.single;
    expect(hidden.rows.single.overfull, isFalse);
    expect(hidden.overfull, isFalse);
    expect(await repo.rowOverflowControlEnabled(), isFalse);

    await repo.setRowOverflowControl(true);
    final shown = (await repo.cabinet(cabinetId))!.shelves.single;
    expect(shown.rows.single.overfull, isTrue);
    expect(shown.rows.single.capacity, 1);
  });

  test('keeps a filled shelf closed only while overflow control is on', () async {
    final roomId = await repo.createRoom(name: 'Комната');
    final cabinetId = await repo.createCabinet(
      roomId: roomId,
      name: 'Шкаф',
      shelfCount: 1,
      rowsPerShelf: 1,
    );
    final shelf = (await repo.cabinet(cabinetId))!.shelves.single;
    final rowId = shelf.rows.single.id;
    expect(shelf.filled, isFalse);

    await repo.setShelfFilled(shelfId: shelf.id, filled: true);
    expect((await repo.shelf(shelf.id))!.filled, isTrue);
    expect(await repo.rowOverflowControlEnabled(), isTrue);
    final stored = await (db.select(db.shelves)
          ..where((table) => table.id.equals(shelf.id)))
        .getSingle();
    expect(stored.filled, isTrue);

    final place = BookDraft(
      title: 'Новая',
      shelfId: shelf.id,
      rowId: rowId,
    );
    await expectLater(
      repo.createBook(place),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          'Полка переполнена',
        ),
      ),
    );

    await repo.setRowOverflowControl(false);
    final id = await repo.createBook(place);
    expect((await repo.bookDetails(id))!.shelfId, shelf.id);

    await repo.setRowOverflowControl(true);
    await repo.updateBook(id, place);
    expect((await repo.bookDetails(id))!.shelfId, shelf.id);

    await repo.moveBook(id: id, shelfId: null, rowId: null);
    expect((await repo.bookDetails(id))!.shelfId, isNull);
    expect((await repo.shelf(shelf.id))!.filled, isTrue);
    await expectLater(
      repo.moveBook(id: id, shelfId: shelf.id, rowId: rowId),
      throwsA(isA<ArgumentError>()),
    );

    await repo.setShelfFilled(shelfId: shelf.id, filled: false);
    await repo.moveBook(id: id, shelfId: shelf.id, rowId: rowId);
    expect((await repo.bookDetails(id))!.shelfId, shelf.id);
  });

  test('keeps names with the shelf or row and closes number gaps after delete', () async {
    final roomId = await repo.createRoom(name: 'Кабинет');
    final cabinetId = await repo.createCabinet(
      roomId: roomId,
      name: 'Шкаф',
      shelfCount: 3,
      rowsPerShelf: 2,
    );
    final before = (await repo.cabinet(cabinetId))!;
    await repo.updateShelfLabel(shelfId: before.shelves[0].id, label: 'верх');
    await repo.updateShelfLabel(shelfId: before.shelves[1].id, label: 'детективы');
    await repo.updateRowLabel(rowId: before.shelves[1].rows[1].id, label: 'толстые');
    final keptShelf = before.shelves[1];
    final keptRow = keptShelf.rows[1];
    await repo.createBook(
      BookDraft(title: 'Детектив', shelfId: keptShelf.id, rowId: keptRow.id),
    );

    await repo.deleteShelf(before.shelves[0].id);
    final afterShelfDelete = (await repo.cabinet(cabinetId))!;
    expect(afterShelfDelete.shelves.map((shelf) => shelf.index), [0, 1]);
    expect(afterShelfDelete.shelves.first.label, 'детективы');
    expect(afterShelfDelete.shelves.first.title, 'Полка 1 · детективы');
    expect(afterShelfDelete.shelves.last.label, isNull);
    expect(afterShelfDelete.shelves.last.title, 'Полка 2');

    final moved = afterShelfDelete.shelves.first;
    expect(moved.rows[1].label, 'толстые');
    expect(moved.rows[1].title, 'Ряд 2 · толстые');
    final page = await repo.rowPage(moved.rows[1].id);
    expect(
      page!.books.single.locationPath,
      'Кабинет → Шкаф → Полка 1 · детективы → Ряд 2 · толстые → 1-я слева',
    );

    await repo.deleteRow(moved.rows[0].id);
    final afterRowDelete = (await repo.shelf(moved.id))!;
    expect(afterRowDelete.rows, hasLength(1));
    expect(afterRowDelete.rows.single.index, 0);
    expect(afterRowDelete.rows.single.label, 'толстые');
    expect(afterRowDelete.rows.single.title, 'Ряд 1 · толстые');
    final renamed = await repo.rowPage(afterRowDelete.rows.single.id);
    expect(
      renamed!.books.single.locationPath,
      'Кабинет → Шкаф → Полка 1 · детективы → Ряд 1 · толстые → 1-я слева',
    );

    await repo.updateRowLabel(rowId: afterRowDelete.rows.single.id, label: '   ');
    final cleared = (await repo.shelf(moved.id))!;
    expect(cleared.rows.single.label, isNull);
    expect(cleared.rows.single.title, 'Ряд 1');
  });

  test('adds the row label column when upgrading from schema 3', () async {
    final file = File('${temp.path}/schema3.sqlite');
    final legacy = _Version3Database(NativeDatabase(file));
    try {
      await legacy.customStatement('SELECT 1');
      await legacy.customStatement('ALTER TABLE shelf_rows DROP COLUMN label');
      await legacy.customStatement('ALTER TABLE books DROP COLUMN personal_note');
      await legacy.customStatement('ALTER TABLE books DROP COLUMN book_format');
      await legacy.customStatement('ALTER TABLE books DROP COLUMN placement');
      await legacy.customStatement('ALTER TABLE books DROP COLUMN yandex_id');
      await legacy.customStatement('ALTER TABLE books DROP COLUMN narrator');
      await legacy.customStatement('ALTER TABLE books DROP COLUMN duration_seconds');
      await legacy.customStatement('ALTER TABLE books DROP COLUMN library_due_at');
      await legacy.customStatement('ALTER TABLE books DROP COLUMN reader_rating');
      await legacy.customStatement('ALTER TABLE books DROP COLUMN reminder_sent_for_due');
      final before = await legacy.customSelect('PRAGMA table_info(shelf_rows)').get();
      expect(before.map((row) => row.data['name']), isNot(contains('label')));
      final booksBefore = await legacy.customSelect('PRAGMA table_info(books)').get();
      expect(booksBefore.map((row) => row.data['name']), isNot(contains('personal_note')));
    } finally {
      await legacy.close();
    }

    final upgraded = AppDatabase(NativeDatabase(file));
    try {
      final after = await upgraded.customSelect('PRAGMA table_info(shelf_rows)').get();
      expect(after.map((row) => row.data['name']), contains('label'));
      final books = await upgraded.customSelect('PRAGMA table_info(books)').get();
      expect(books.map((row) => row.data['name']), contains('personal_note'));
      final version = await upgraded.customSelect('PRAGMA user_version').get();
      expect(version.single.data.values.single, currentSchemaVersion);
    } finally {
      await upgraded.close();
    }
  });

  test('moves a selection in order or rejects the whole batch', () async {
    final roomId = await repo.createRoom(name: 'Комната');
    final cabinetId = await repo.createCabinet(
      roomId: roomId,
      name: 'Шкаф',
      shelfCount: 1,
      rowsPerShelf: 1,
    );
    final shelf = (await repo.cabinet(cabinetId))!.shelves.single;
    final rowId = shelf.rows.single.id;
    final kept = await repo.createBook(
      BookDraft(title: 'Уже стоит', shelfId: shelf.id, rowId: rowId),
    );
    final first = await repo.createBook(BookDraft(title: 'Первая'));
    final second = await repo.createBook(BookDraft(title: 'Вторая'));

    await repo.moveBooks(
      ids: [second, first],
      shelfId: shelf.id,
      rowId: rowId,
    );
    final placed = (await repo.rowPage(rowId))!;
    expect(placed.books.map((book) => book.id).toList(), [kept, second, first]);

    await repo.moveBook(id: first, shelfId: null, rowId: null);
    await repo.moveBook(id: second, shelfId: null, rowId: null);
    await repo.setShelfFilled(shelfId: shelf.id, filled: true);
    await expectLater(
      repo.moveBooks(ids: [kept, first], shelfId: shelf.id, rowId: rowId),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          'Полка переполнена',
        ),
      ),
    );
    expect((await repo.bookDetails(first))!.shelfId, isNull);
    expect((await repo.bookDetails(second))!.shelfId, isNull);
    expect((await repo.bookDetails(kept))!.rowId, rowId);
    expect((await repo.shelf(shelf.id))!.filled, isTrue);

    await repo.moveBooks(ids: [kept], shelfId: shelf.id, rowId: rowId);
    expect((await repo.bookDetails(kept))!.rowId, rowId);
  });

  test('updates status and publishers for every selected book', () async {
    final due = DateTime.utc(2026, 12, 1);
    final one = await repo.createBook(
      BookDraft(
        title: 'Одна',
        readingStatus: ReadingStatus.wantToRead,
        publishers: ['Старое'],
        genres: ['Повесть'],
        loanPerson: 'Анна',
        loanDueAt: due,
      ),
    );
    final two = await repo.createBook(
      BookDraft(
        title: 'Другая',
        publishers: ['Другое'],
        hashtags: ['дом'],
      ),
    );

    await repo.setBooksReadingStatus(
      ids: [one, two],
      status: ReadingStatus.finished,
    );
    expect((await repo.bookDetails(one))!.readingStatus, ReadingStatus.finished);
    expect((await repo.bookDetails(two))!.readingStatus, ReadingStatus.finished);
    expect((await repo.bookDetails(one))!.loanPerson, 'Анна');

    await repo.setBooksPublishers(ids: [one, two], publishers: ['АСТ']);
    expect((await repo.bookDetails(one))!.publishers, ['АСТ']);
    expect((await repo.bookDetails(two))!.publishers, ['АСТ']);
    await repo.setBooksPublishers(ids: [one], publishers: const []);
    expect((await repo.bookDetails(one))!.publishers, isEmpty);
    expect((await repo.bookDetails(two))!.publishers, ['АСТ']);

    await repo.setBooksGenres(ids: [one, two], genres: ['Роман']);
    expect((await repo.bookDetails(one))!.genres, ['Роман']);
    expect((await repo.bookDetails(two))!.genres, ['Роман']);

    await repo.addBooksHashtags(ids: [two], hashtags: ['дача']);
    final tags = (await repo.bookDetails(two))!.hashtags;
    expect(tags, contains('дом'));
    expect(tags, contains('дача'));

    await repo.setBooksLoanPerson(ids: [one], person: '  ');
    final cleared = (await repo.bookDetails(one))!;
    expect(cleared.loanPerson, isEmpty);
    expect(cleared.loanDueAt, isNull);
    expect(cleared.readingStatus, ReadingStatus.finished);
  });
}

class _Version3Database extends AppDatabase {
  _Version3Database(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
  );
}

class ArchiveBuilder {
  static List<int> unsafe() {
    final archive = Archive();
    archive.addFile(ArchiveFile('library.sqlite', 4, [1, 2, 3, 4]));
    archive.addFile(ArchiveFile('../secret.txt', 1, [9]));
    return ZipEncoder().encode(archive);
  }

  static List<int> notSqlite() => _withDatabase(List<int>.filled(4096, 7));

  static List<int> corrupt() {
    final bytes = List<int>.filled(4096, 0xAB);
    bytes.setRange(0, 16, 'SQLite format 3\u0000'.codeUnits);
    bytes.setRange(60, 64, [0, 0, 0, 2]);
    return _withDatabase(bytes);
  }

  static List<int> _withDatabase(List<int> bytes) {
    final archive = Archive();
    archive.addFile(ArchiveFile('library.sqlite', bytes.length, bytes));
    return ZipEncoder().encode(archive);
  }
}
