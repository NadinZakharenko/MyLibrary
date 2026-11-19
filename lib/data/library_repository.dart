import 'dart:async';

import 'package:drift/drift.dart';
import 'package:my_library/core/database/app_database.dart';
import 'package:my_library/core/format/hashtag.dart';
import 'package:my_library/core/format/loan.dart';
import 'package:my_library/core/format/location_path.dart';
import 'package:my_library/core/format/row_capacity.dart';
import 'package:my_library/core/format/russian_plural.dart';
import 'package:my_library/core/isbn.dart';
import 'package:my_library/core/models/book_copy.dart';
import 'package:my_library/core/models/book_draft.dart';
import 'package:my_library/core/models/dictionary_kind.dart';
import 'package:my_library/core/models/home_layout.dart';
import 'package:my_library/core/models/library_view.dart';
import 'package:my_library/core/models/reading_status.dart';
import 'package:my_library/core/models/shelf_model.dart';
import 'package:my_library/core/notes/voice_note.dart';
import 'package:my_library/core/search/book_search.dart';
import 'package:my_library/core/search/duplicates.dart';
import 'package:my_library/core/storage/image_store.dart';
import 'package:my_library/core/theme/theme_choice.dart';

/// Older versions stored this key. It stays on the secret list so a backup never copies it.
const googleBooksApiKeySetting = 'google_books_api_key';
const loggingEnabledSetting = 'logging_enabled';
const kimiApiKeySetting = 'kimi_api_key';
const kimiCloudConsentSetting = 'kimi_cloud_consent';
const rowOverflowControlSetting = 'row_overflow_control';
const shelfModelSetting = 'shelf_model';
const voiceModelSetting = 'voice_model';
const voiceRecordingConsentSetting = 'voice_recording_consent';
const voiceFormatConsentSetting = 'voice_format_consent';
const yandexApiKeySetting = 'yandex_api_key';
const yandexFolderIdSetting = 'yandex_folder_id';
const homeLayoutSetting = 'home_layout';
const homeLibraryStatsMergedSetting = 'home_library_stats_merged';
const settingsOpenSetting = 'settings_open_sections';
const libraryReminderEnabledSetting = 'library_reminder_enabled';
const yandexBooksProfileSetting = 'yandex_books_profile';
const yandexBooksTokenSetting = 'yandex_books_token';
const yandexBooksReviewConsentSetting = 'yandex_books_review_consent';
const livelibLoginSetting = 'livelib_login';
const livelibPasswordSetting = 'livelib_password';
const livelibSendConsentSetting = 'livelib_send_consent';
const telegramBotNameSetting = 'telegram_bot_name';
const telegramBotTokenSetting = 'telegram_bot_token';
const telegramChatIdSetting = 'telegram_chat_id';
const telegramReminderEnabledSetting = 'telegram_reminder_enabled';
const maxBotNameSetting = 'max_bot_name';
const maxBotTokenSetting = 'max_bot_token';
const maxUserIdSetting = 'max_user_id';
const maxReminderEnabledSetting = 'max_reminder_enabled';

const backupSecretSettings = <String>[
  googleBooksApiKeySetting,
  kimiApiKeySetting,
  yandexApiKeySetting,
  yandexFolderIdSetting,
  yandexBooksTokenSetting,
  livelibLoginSetting,
  livelibPasswordSetting,
  telegramBotTokenSetting,
  telegramChatIdSetting,
  maxBotTokenSetting,
  maxUserIdSetting,
];

const _sharedLoadKey = #librarySharedLoad;

const audioOffShelfMessage =
    'Аудиокниги не ставятся на полку. Снимите с них отметку.';

class ChooseRowException implements Exception {
  const ChooseRowException();
}

class LibraryRepository {
  LibraryRepository(this.db, this.images);

  final AppDatabase db;
  final ImageStore images;

  /// Runs after a book is saved, moved, or deleted. Reminders use it.
  void Function()? afterBooksChanged;

  StreamController<int>? _changeHub;
  StreamSubscription<List<QueryRow>>? _changeSource;
  var _changeNumber = 0;
  int? _sharedChange;
  Future<_LoadedLibrary>? _sharedLoad;

  Stream<HomeSnapshot> watchHome() => _watch(loadHome);

  Stream<CabinetDetails?> watchCabinet(int id) => _watch(() => cabinet(id));

  Stream<ShelfInfo?> watchShelf(int id) => _watch(() => shelf(id));

  Stream<RowPageData?> watchRow(int rowId) => _watch(() => rowPage(rowId));

  Stream<List<BookSummary>> watchUnplaced() => _watch(unplacedBooks);

  Stream<BookDetails?> watchBook(int id) => _watch(() => bookDetails(id));

  Stream<List<LocationOption>> watchLocationOptions() => _watch(locationOptions);

  Stream<List<String>> watchHashtags() => _watch(hashtagLabels);

  Stream<List<BookSearchRecord>> watchSearch() => _watch(searchRecords);

  Future<HomeSnapshot> loadHome() async {
    final loaded = await _load();
    final now = DateTime.now();
    final summaries = loaded.summaries()
      ..sort((a, b) {
        final byDate = b.createdAt.compareTo(a.createdAt);
        if (byDate != 0) {
          return byDate;
        }
        return b.id.compareTo(a.id);
      });
    return HomeSnapshot(
      totalBooks: summaries.length,
      addedLast7Days: summaries
          .where((book) => isWithinLastDays(book.createdAt, now))
          .length,
      unplacedBooks: summaries.where(_isUnplaced).length,
      libraryBooks: summaries
          .where((book) => book.placement == BookPlacement.library)
          .length,
      libraryReturns: summaries
          .where(
            (book) =>
                book.placement == BookPlacement.library &&
                libraryReturnNeedsAttention(book.libraryDueAt, now),
          )
          .toList()
        ..sort((a, b) {
          final left = a.libraryDueAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final right = b.libraryDueAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return left.compareTo(right);
        }),
      wantToReadCount: summaries
          .where((book) => book.readingStatus == ReadingStatus.wantToRead)
          .length,
      readingCount: summaries
          .where((book) => book.readingStatus == ReadingStatus.reading)
          .length,
      finishedCount: summaries
          .where((book) => book.readingStatus == ReadingStatus.finished)
          .length,
      lentCount: summaries.where((book) => loanIsActive(book.loanPerson)).length,
      overdueLoans: summaries
          .where(
            (book) =>
                loanIsActive(book.loanPerson) &&
                loanIsOverdue(book.loanDueAt, now),
          )
          .toList()
        ..sort((a, b) {
          final left = a.loanDueAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final right = b.loanDueAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return left.compareTo(right);
        }),
      recent: summaries.take(8).toList(),
      rooms: loaded.roomOverviews(),
    );
  }

  Future<CabinetDetails?> cabinet(int id) async {
    final loaded = await _load();
    return loaded.cabinetDetails(id);
  }

  Future<ShelfInfo?> shelf(int id) async {
    final loaded = await _load();
    return loaded.shelfInfo(id);
  }

  Future<RowPageData?> rowPage(int rowId) async {
    final loaded = await _load();
    return loaded.rowPage(rowId);
  }

  Future<List<BookSummary>> unplacedBooks() async {
    final loaded = await _load();
    return loaded
        .summaries()
        .where(_isUnplaced)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<BookDetails?> bookDetails(int id) async {
    final loaded = await _load();
    return loaded.details(id);
  }

  Future<List<BookSearchRecord>> searchRecords() async {
    final loaded = await _load();
    return loaded.searchRecords();
  }

  Future<List<LocationOption>> locationOptions() async {
    final loaded = await _load();
    return loaded.locationOptions();
  }

  Future<List<String>> hashtagLabels() async {
    final rows = await (db.select(db.hashtags)..orderBy([
      (table) => OrderingTerm(expression: table.displayName),
    ])).get();
    return rows.map((row) => row.displayName).toList();
  }

  Future<List<String>> suggest(DictionaryKind kind, String query) {
    return switch (kind) {
      DictionaryKind.author => _suggestNames(
        load: () => db.select(db.authors).get(),
        nameOf: (row) => row.name,
        keyOf: (row) => row.nameKey,
        query: query,
      ),
      DictionaryKind.genre => _suggestNames(
        load: () => db.select(db.genres).get(),
        nameOf: (row) => row.name,
        keyOf: (row) => row.nameKey,
        query: query,
      ),
      DictionaryKind.publisher => _suggestNames(
        load: () => db.select(db.publishers).get(),
        nameOf: (row) => row.name,
        keyOf: (row) => row.nameKey,
        query: query,
      ),
      DictionaryKind.hashtag => _suggestHashtags(query),
    };
  }

  Future<AppThemeChoice> themeChoice() async {
    return themeChoiceFromStorage(await _setting(themeModeSettingKey));
  }

  Future<void> setThemeChoice(AppThemeChoice choice) {
    return _setSetting(themeModeSettingKey, themeChoiceStorage(choice));
  }

  Future<bool> loggingEnabled() async {
    return (await _setting(loggingEnabledSetting)) == '1';
  }

  Future<void> setLoggingEnabled(bool enabled) {
    return _setSetting(loggingEnabledSetting, enabled ? '1' : '0');
  }

  Future<String?> kimiApiKey() => _setting(kimiApiKeySetting);

  Future<void> setKimiApiKey(String? value) {
    return _setSetting(kimiApiKeySetting, value);
  }

  Future<bool> kimiCloudConsent() async {
    return (await _setting(kimiCloudConsentSetting)) == '1';
  }

  Future<void> setKimiCloudConsent(bool enabled) {
    return _setSetting(kimiCloudConsentSetting, enabled ? '1' : '0');
  }

  /// Missing value means the check stays on.
  Future<bool> rowOverflowControlEnabled() async {
    return (await _setting(rowOverflowControlSetting)) != '0';
  }

  Future<void> setRowOverflowControl(bool enabled) {
    return _setSetting(rowOverflowControlSetting, enabled ? '1' : '0');
  }

  /// A saved choice wins. An older library with a Kimi key and consent stays on Kimi.
  Future<ShelfModelChoice> shelfModel() async {
    final stored = shelfModelFromStorage(await _setting(shelfModelSetting));
    if (stored != null) {
      return stored;
    }
    final key = await _setting(kimiApiKeySetting);
    final consent = await kimiCloudConsent();
    if (key != null && key.trim().isNotEmpty && consent) {
      return ShelfModelChoice.kimi;
    }
    return ShelfModelChoice.off;
  }

  Future<void> setShelfModel(ShelfModelChoice choice) {
    return _setSetting(shelfModelSetting, shelfModelStorage(choice));
  }

  Future<ShelfModelChoice> voiceModel() async {
    return shelfModelFromStorage(await _setting(voiceModelSetting)) ??
        ShelfModelChoice.off;
  }

  Future<void> setVoiceModel(ShelfModelChoice choice) {
    return _setSetting(voiceModelSetting, shelfModelStorage(choice));
  }

  Future<bool> voiceRecordingConsent() async {
    return (await _setting(voiceRecordingConsentSetting)) == '1';
  }

  Future<void> setVoiceRecordingConsent(bool enabled) {
    return _setSetting(voiceRecordingConsentSetting, enabled ? '1' : '0');
  }

  Future<bool> voiceFormatConsent() async {
    return (await _setting(voiceFormatConsentSetting)) == '1';
  }

  Future<void> setVoiceFormatConsent(bool enabled) {
    return _setSetting(voiceFormatConsentSetting, enabled ? '1' : '0');
  }

  Future<VoiceNoteSettings> voiceNoteSettings() async {
    return VoiceNoteSettings(
      model: await voiceModel(),
      recordingConsent: await voiceRecordingConsent(),
      formatConsent: await voiceFormatConsent(),
      kimiKey: (await kimiApiKey())?.trim() ?? '',
      yandexKey: (await yandexApiKey())?.trim() ?? '',
      folderId: (await yandexFolderId())?.trim() ?? '',
    );
  }

  Future<String?> yandexApiKey() => _setting(yandexApiKeySetting);

  Future<void> setYandexApiKey(String? value) {
    return _setSetting(yandexApiKeySetting, value);
  }

  Future<String?> yandexFolderId() => _setting(yandexFolderIdSetting);

  Future<void> setYandexFolderId(String? value) {
    return _setSetting(yandexFolderIdSetting, value);
  }

  Future<Set<String>> openSettingsSections() async {
    final raw = await _setting(settingsOpenSetting);
    if (raw == null || raw.trim().isEmpty) {
      return const {};
    }
    return raw.split(',').where((item) => item.isNotEmpty).toSet();
  }

  Future<void> setOpenSettingsSections(Set<String> ids) {
    final sorted = ids.toList()..sort();
    return _setSetting(settingsOpenSetting, sorted.join(','));
  }

  Future<bool> libraryReminderEnabled() async {
    return (await _setting(libraryReminderEnabledSetting)) == '1';
  }

  Future<void> setLibraryReminderEnabled(bool enabled) {
    return _setSetting(libraryReminderEnabledSetting, enabled ? '1' : '0');
  }

  Future<String?> yandexBooksProfile() => _setting(yandexBooksProfileSetting);

  Future<void> setYandexBooksProfile(String? value) {
    return _setSetting(yandexBooksProfileSetting, value);
  }

  Future<String?> yandexBooksToken() => _setting(yandexBooksTokenSetting);

  Future<void> setYandexBooksToken(String? value) {
    return _setSetting(yandexBooksTokenSetting, value);
  }

  Future<bool> yandexBooksReviewConsent() async {
    return (await _setting(yandexBooksReviewConsentSetting)) == '1';
  }

  Future<void> setYandexBooksReviewConsent(bool enabled) {
    return _setSetting(yandexBooksReviewConsentSetting, enabled ? '1' : '0');
  }

  Future<String?> livelibLogin() => _setting(livelibLoginSetting);

  Future<void> setLivelibLogin(String? value) {
    return _setSetting(livelibLoginSetting, value);
  }

  Future<String?> livelibPassword() => _setting(livelibPasswordSetting);

  Future<void> setLivelibPassword(String? value) {
    return _setSetting(livelibPasswordSetting, value);
  }

  Future<bool> livelibSendConsent() async {
    return (await _setting(livelibSendConsentSetting)) == '1';
  }

  Future<void> setLivelibSendConsent(bool enabled) {
    return _setSetting(livelibSendConsentSetting, enabled ? '1' : '0');
  }

  Future<String?> telegramBotName() => _setting(telegramBotNameSetting);

  Future<void> setTelegramBotName(String? value) {
    return _setSetting(telegramBotNameSetting, value);
  }

  Future<String?> telegramBotToken() => _setting(telegramBotTokenSetting);

  Future<void> setTelegramBotToken(String? value) {
    return _setSetting(telegramBotTokenSetting, value);
  }

  Future<String?> telegramChatId() => _setting(telegramChatIdSetting);

  Future<void> setTelegramChatId(String? value) {
    return _setSetting(telegramChatIdSetting, value);
  }

  Future<bool> telegramReminderEnabled() async {
    return (await _setting(telegramReminderEnabledSetting)) == '1';
  }

  Future<void> setTelegramReminderEnabled(bool enabled) {
    return _setSetting(telegramReminderEnabledSetting, enabled ? '1' : '0');
  }

  Future<String?> maxBotName() => _setting(maxBotNameSetting);

  Future<void> setMaxBotName(String? value) {
    return _setSetting(maxBotNameSetting, value);
  }

  Future<String?> maxBotToken() => _setting(maxBotTokenSetting);

  Future<void> setMaxBotToken(String? value) {
    return _setSetting(maxBotTokenSetting, value);
  }

  Future<String?> maxUserId() => _setting(maxUserIdSetting);

  Future<void> setMaxUserId(String? value) {
    return _setSetting(maxUserIdSetting, value);
  }

  Future<bool> maxReminderEnabled() async {
    return (await _setting(maxReminderEnabledSetting)) == '1';
  }

  Future<void> setMaxReminderEnabled(bool enabled) {
    return _setSetting(maxReminderEnabledSetting, enabled ? '1' : '0');
  }

  Future<void> markLibraryReminderSent(int id, DateTime due) {
    return (db.update(db.books)..where((row) => row.id.equals(id))).write(
      BooksCompanion(reminderSentForDue: Value(due)),
    );
  }

  Future<Book?> bookByYandexId(String id) {
    final key = id.trim();
    return (db.select(db.books)..where((row) => row.yandexId.equals(key)))
        .getSingleOrNull();
  }

  Future<List<Book>> libraryReminderRows() {
    return (db.select(db.books)
          ..where((row) => row.placement.equals('library')))
        .get();
  }

  Future<ShelfModelConnection> shelfConnection() async {
    return ShelfModelConnection(
      choice: await shelfModel(),
      consent: await kimiCloudConsent(),
      kimiKey: (await kimiApiKey())?.trim() ?? '',
      yandexKey: (await yandexApiKey())?.trim() ?? '',
      folderId: (await yandexFolderId())?.trim() ?? '',
    );
  }

  Future<HomeLayout> homeLayout() async {
    final layout = homeLayoutFromStorage(await _setting(homeLayoutSetting));
    if ((await _setting(homeLibraryStatsMergedSetting)) == '1') {
      return layout;
    }
    final stats = [...layout.stats];
    if (!stats.contains(HomeStat.library)) {
      stats.add(HomeStat.library);
    }
    if (!stats.contains(HomeStat.libraryDue)) {
      stats.add(HomeStat.libraryDue);
    }
    final merged = layout.copyWith(stats: stats);
    await setHomeLayout(merged);
    await _setSetting(homeLibraryStatsMergedSetting, '1');
    return merged;
  }

  Future<void> setHomeLayout(HomeLayout layout) {
    return _setSetting(homeLayoutSetting, homeLayoutStorage(layout));
  }

  Stream<HomeLayout> watchHomeLayout() => _watch(homeLayout);

  Stream<List<BookSummary>> watchHomeStat(HomeStat stat) {
    return _watch(() => booksForHomeStat(stat));
  }

  Future<List<BookSummary>> booksForHomeStat(HomeStat stat) async {
    final loaded = await _load();
    final now = DateTime.now();
    final matched = loaded.summaries().where((book) {
      return switch (stat) {
        HomeStat.total => true,
        HomeStat.week => isWithinLastDays(book.createdAt, now),
        HomeStat.unplaced => _isUnplaced(book),
        HomeStat.library => book.placement == BookPlacement.library,
        HomeStat.libraryDue =>
          book.placement == BookPlacement.library &&
          libraryReturnNeedsAttention(book.libraryDueAt, now),
        HomeStat.want => book.readingStatus == ReadingStatus.wantToRead,
        HomeStat.reading => book.readingStatus == ReadingStatus.reading,
        HomeStat.finished => book.readingStatus == ReadingStatus.finished,
        HomeStat.lent => loanIsActive(book.loanPerson),
        HomeStat.overdue =>
          loanIsActive(book.loanPerson) && loanIsOverdue(book.loanDueAt, now),
      };
    }).toList()
      ..sort((a, b) {
        final byDate = b.createdAt.compareTo(a.createdAt);
        if (byDate != 0) {
          return byDate;
        }
        return b.id.compareTo(a.id);
      });
    return matched;
  }

  Stream<AppThemeChoice> watchTheme() => _watch(themeChoice);

  Future<int> createRoom({required String name, String note = ''}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Название комнаты не может быть пустым');
    }
    final sortOrder = await _nextInt(
      db.selectOnly(db.rooms)..addColumns([db.rooms.sortOrder.max()]),
      db.rooms.sortOrder.max(),
    );
    return db.into(db.rooms).insert(
      RoomsCompanion.insert(
        name: trimmed,
        note: Value(note.trim()),
        sortOrder: Value(sortOrder),
      ),
    );
  }

  Future<void> updateRoom({
    required int id,
    required String name,
    required String note,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Название комнаты не может быть пустым');
    }
    await (db.update(db.rooms)..where((row) => row.id.equals(id))).write(
      RoomsCompanion(name: Value(trimmed), note: Value(note.trim())),
    );
  }

  Future<int> countBooksInRoom(int roomId) {
    return _countBooks(
      'shelf_id IN (SELECT shelves.id FROM shelves '
      'JOIN cabinets ON cabinets.id = shelves.cabinet_id '
      'WHERE cabinets.room_id = ?)',
      roomId,
    );
  }

  Future<int> _countBooks(String where, int id) async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM books WHERE $where',
          variables: [Variable.withInt(id)],
          readsFrom: {db.books, db.shelves, db.cabinets},
        )
        .getSingle();
    return row.read<int>('c');
  }

  Future<void> deleteRoom(int id) async {
    await db.transaction(() async {
      await db.customStatement(
        '''
        UPDATE books
        SET shelf_id = NULL, row_id = NULL, position_index = 0
        WHERE shelf_id IN (
          SELECT shelves.id FROM shelves
          INNER JOIN cabinets ON cabinets.id = shelves.cabinet_id
          WHERE cabinets.room_id = ?
        )
        ''',
        [id],
      );
      await (db.delete(db.rooms)..where((row) => row.id.equals(id))).go();
    });
  }

  Future<void> reorderRooms(List<int> orderedIds) {
    return _reorder(orderedIds, (id, index) async {
      await (db.update(db.rooms)..where((row) => row.id.equals(id))).write(
        RoomsCompanion(sortOrder: Value(index)),
      );
    });
  }

  Future<int> createCabinet({
    required int roomId,
    required String name,
    required int shelfCount,
    required int rowsPerShelf,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Название шкафа не может быть пустым');
    }
    if (shelfCount < 1 || rowsPerShelf < 1) {
      throw ArgumentError('Нужна хотя бы одна полка и один ряд');
    }
    return db.transaction(() async {
      final sortOrder = await _nextInt(
        db.selectOnly(db.cabinets)
          ..addColumns([db.cabinets.sortOrder.max()])
          ..where(db.cabinets.roomId.equals(roomId)),
        db.cabinets.sortOrder.max(),
      );
      final cabinetId = await db.into(db.cabinets).insert(
        CabinetsCompanion.insert(
          roomId: roomId,
          name: trimmed,
          sortOrder: Value(sortOrder),
        ),
      );
      for (var shelfIndex = 0; shelfIndex < shelfCount; shelfIndex++) {
        final shelfId = await db.into(db.shelves).insert(
          ShelvesCompanion.insert(cabinetId: cabinetId, shelfIndex: shelfIndex),
        );
        for (var rowIndex = 0; rowIndex < rowsPerShelf; rowIndex++) {
          await db.into(db.shelfRows).insert(
            ShelfRowsCompanion.insert(shelfId: shelfId, rowIndex: rowIndex),
          );
        }
      }
      return cabinetId;
    });
  }

  Future<void> renameCabinet({required int id, required String name}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Название шкафа не может быть пустым');
    }
    await (db.update(db.cabinets)..where((row) => row.id.equals(id))).write(
      CabinetsCompanion(name: Value(trimmed)),
    );
  }

  Future<int> countBooksInCabinet(int cabinetId) {
    return _countBooks(
      'shelf_id IN (SELECT id FROM shelves WHERE cabinet_id = ?)',
      cabinetId,
    );
  }

  Future<void> deleteCabinet(int id) async {
    await db.transaction(() async {
      await db.customStatement(
        '''
        UPDATE books
        SET shelf_id = NULL, row_id = NULL, position_index = 0
        WHERE shelf_id IN (SELECT id FROM shelves WHERE cabinet_id = ?)
        ''',
        [id],
      );
      await (db.delete(db.cabinets)..where((row) => row.id.equals(id))).go();
    });
  }

  Future<void> reorderCabinets({
    required int roomId,
    required List<int> orderedIds,
  }) {
    return _reorder(orderedIds, (id, index) async {
      await (db.update(db.cabinets)..where(
        (row) => row.id.equals(id) & row.roomId.equals(roomId),
      )).write(CabinetsCompanion(sortOrder: Value(index)));
    });
  }

  Future<int> addShelf({
    required int cabinetId,
    String? label,
    int rowCount = 1,
  }) async {
    if (rowCount < 1) {
      throw ArgumentError('На полке нужен хотя бы один ряд');
    }
    return db.transaction(() async {
      final shelfIndex = await _nextInt(
        db.selectOnly(db.shelves)
          ..addColumns([db.shelves.shelfIndex.max()])
          ..where(db.shelves.cabinetId.equals(cabinetId)),
        db.shelves.shelfIndex.max(),
      );
      final trimmed = label?.trim();
      final shelfId = await db.into(db.shelves).insert(
        ShelvesCompanion.insert(
          cabinetId: cabinetId,
          shelfIndex: shelfIndex,
          label: Value(
            trimmed == null || trimmed.isEmpty ? null : trimmed,
          ),
        ),
      );
      for (var rowIndex = 0; rowIndex < rowCount; rowIndex++) {
        await db.into(db.shelfRows).insert(
          ShelfRowsCompanion.insert(shelfId: shelfId, rowIndex: rowIndex),
        );
      }
      return shelfId;
    });
  }

  Future<void> setShelfFilled({
    required int shelfId,
    required bool filled,
  }) async {
    await (db.update(db.shelves)..where((row) => row.id.equals(shelfId))).write(
      ShelvesCompanion(filled: Value(filled)),
    );
  }

  Future<void> updateShelfLabel({required int shelfId, String? label}) async {
    final trimmed = label?.trim();
    await (db.update(db.shelves)..where((row) => row.id.equals(shelfId))).write(
      ShelvesCompanion(
        label: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
      ),
    );
  }

  Future<void> updateRowLabel({required int rowId, String? label}) async {
    final trimmed = label?.trim();
    await (db.update(db.shelfRows)..where((row) => row.id.equals(rowId))).write(
      ShelfRowsCompanion(
        label: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
      ),
    );
  }

  Future<int> countBooksOnShelf(int shelfId) {
    return _countBooks('shelf_id = ?', shelfId);
  }

  Future<void> deleteShelf(int shelfId) async {
    await db.transaction(() async {
      final shelf = await (db.select(db.shelves)
            ..where((row) => row.id.equals(shelfId)))
          .getSingleOrNull();
      await db.customStatement(
        '''
        UPDATE books
        SET shelf_id = NULL, row_id = NULL, position_index = 0
        WHERE shelf_id = ?
           OR row_id IN (SELECT id FROM shelf_rows WHERE shelf_id = ?)
        ''',
        [shelfId, shelfId],
      );
      await (db.delete(db.shelves)..where((row) => row.id.equals(shelfId))).go();
      if (shelf != null) {
        await _compactShelfIndexes(shelf.cabinetId);
      }
    });
  }

  Future<void> reorderShelves({
    required int cabinetId,
    required List<int> orderedIdsTopToBottom,
  }) {
    return _reorder(orderedIdsTopToBottom, (id, index) async {
      await (db.update(db.shelves)..where(
        (row) => row.id.equals(id) & row.cabinetId.equals(cabinetId),
      )).write(ShelvesCompanion(shelfIndex: Value(index)));
    });
  }

  Future<int> addRow(int shelfId) {
    return db.transaction(() async {
      final rowIndex = await _nextInt(
        db.selectOnly(db.shelfRows)
          ..addColumns([db.shelfRows.rowIndex.max()])
          ..where(db.shelfRows.shelfId.equals(shelfId)),
        db.shelfRows.rowIndex.max(),
      );
      return db.into(db.shelfRows).insert(
        ShelfRowsCompanion.insert(shelfId: shelfId, rowIndex: rowIndex),
      );
    });
  }

  Future<int> countBooksOnRow(int rowId) {
    return _countBooks('row_id = ?', rowId);
  }

  Future<void> deleteRow(int rowId) async {
    await db.transaction(() async {
      final row = await (db.select(db.shelfRows)
            ..where((item) => item.id.equals(rowId)))
          .getSingleOrNull();
      await db.customStatement(
        '''
        UPDATE books
        SET shelf_id = NULL, row_id = NULL, position_index = 0
        WHERE row_id = ?
        ''',
        [rowId],
      );
      await (db.delete(db.shelfRows)..where((item) => item.id.equals(rowId))).go();
      if (row != null) {
        await _compactRowIndexes(row.shelfId);
      }
    });
  }

  Future<void> reorderRows({
    required int shelfId,
    required List<int> orderedIds,
  }) {
    return _reorder(orderedIds, (id, index) async {
      await (db.update(db.shelfRows)..where(
        (row) => row.id.equals(id) & row.shelfId.equals(shelfId),
      )).write(ShelfRowsCompanion(rowIndex: Value(index)));
    });
  }

  /// Adds empty shelves at the bottom or removes the bottom shelves.
  /// Books on a removed shelf stay in the library without a place.
  Future<void> resizeCabinetShelves({
    required int cabinetId,
    required int shelfCount,
  }) async {
    if (shelfCount < 0 || shelfCount > 40) {
      throw ArgumentError('Число полок от 0 до 40');
    }
    final current = await cabinet(cabinetId);
    if (current == null) {
      throw StateError('Шкаф не найден');
    }
    if (shelfCount > current.shelves.length) {
      for (var index = current.shelves.length; index < shelfCount; index++) {
        await addShelf(cabinetId: cabinetId);
      }
      return;
    }
    for (final shelf in current.shelves.skip(shelfCount).toList()) {
      await deleteShelf(shelf.id);
    }
  }

  /// Adds empty rows at the bottom or removes the bottom rows.
  /// Books in a removed row stay in the library without a place.
  Future<void> resizeShelfRows({
    required int shelfId,
    required int rowCount,
  }) async {
    if (rowCount < 1 || rowCount > 40) {
      throw ArgumentError('На полке от 1 до 40 рядов');
    }
    final current = await shelf(shelfId);
    if (current == null) {
      throw StateError('Полка не найдена');
    }
    if (rowCount > current.rows.length) {
      for (var index = current.rows.length; index < rowCount; index++) {
        await addRow(shelfId);
      }
      return;
    }
    for (final row in current.rows.skip(rowCount).toList()) {
      await deleteRow(row.id);
    }
  }

  Future<int> createBook(BookDraft draft) async {
    final prepared = draft.prepared();
    final title = prepared.title.trim();
    if (title.isEmpty) {
      throw ArgumentError('Укажите название');
    }
    final id = await db.transaction(() async {
      final place = await _resolveLocation(prepared.shelfId, prepared.rowId);
      await _rejectFilledShelf(shelfId: place.shelfId, currentShelfId: null);
      final position = await _nextPosition(place.rowId);
      final id = await db.into(db.books).insert(
        BooksCompanion.insert(
          title: title,
          subtitle: Value(prepared.subtitle.trim()),
          description: Value(prepared.description.trim()),
          personalNote: Value(prepared.personalNote.trim()),
          isbn: Value(_cleanIsbn(prepared.isbn)),
          coverPath: Value(_emptyToNull(prepared.coverPath)),
          sourceUrl: Value(_emptyToNull(prepared.sourceUrl)),
          shelfId: Value(place.shelfId),
          rowId: Value(place.rowId),
          positionIndex: Value(position),
          readingStatus: Value(readingStatusStorage(prepared.readingStatus)),
          statusChangedAt: Value(prepared.statusChangedAt ?? DateTime.now()),
          seriesName: Value(_emptyToNull(prepared.seriesName)),
          seriesVolume: Value(prepared.seriesVolume),
          loanPerson: Value(_loanPerson(prepared)),
          loanDueAt: Value(_loanDue(prepared)),
          bookFormat: Value(bookFormatStorage(prepared.format)),
          placement: Value(bookPlacementStorage(prepared.placement)),
          yandexId: Value(_emptyToNull(prepared.yandexId)),
          narrator: Value(prepared.narrator.trim()),
          durationSeconds: Value(prepared.durationSeconds),
          libraryDueAt: Value(prepared.libraryDueAt),
          readerRating: Value(prepared.readerRating),
          createdAt: Value(DateTime.now().toUtc()),
        ),
      );
      await _replaceLinks(id, prepared);
      return id;
    });
    afterBooksChanged?.call();
    return id;
  }

  Future<void> updateBook(int id, BookDraft draft) async {
    final prepared = draft.prepared();
    final title = prepared.title.trim();
    if (title.isEmpty) {
      throw ArgumentError('Укажите название');
    }
    final existing = await bookDetails(id);
    if (existing == null) {
      throw StateError('Книга не найдена');
    }
    final dueChanged = existing.libraryDueAt != prepared.libraryDueAt;
    await db.transaction(() async {
      final place = await _resolveLocation(prepared.shelfId, prepared.rowId);
      await _rejectFilledShelf(
        shelfId: place.shelfId,
        currentShelfId: existing.shelfId,
      );
      final keepsPlace = place.rowId != null && place.rowId == existing.rowId;
      final position = keepsPlace
          ? existing.positionIndex
          : await _nextPosition(place.rowId);
      await (db.update(db.books)..where((row) => row.id.equals(id))).write(
        BooksCompanion(
          title: Value(title),
          subtitle: Value(prepared.subtitle.trim()),
          description: Value(prepared.description.trim()),
          personalNote: Value(prepared.personalNote.trim()),
          isbn: Value(_cleanIsbn(prepared.isbn)),
          coverPath: Value(_emptyToNull(prepared.coverPath)),
          sourceUrl: Value(_emptyToNull(prepared.sourceUrl)),
          shelfId: Value(place.shelfId),
          rowId: Value(place.rowId),
          positionIndex: Value(position),
          readingStatus: Value(readingStatusStorage(prepared.readingStatus)),
          statusChangedAt: Value(
            prepared.statusChangedAt ?? existing.statusChangedAt ?? DateTime.now(),
          ),
          seriesName: Value(_emptyToNull(prepared.seriesName)),
          seriesVolume: Value(prepared.seriesVolume),
          loanPerson: Value(_loanPerson(prepared)),
          loanDueAt: Value(_loanDue(prepared)),
          bookFormat: Value(bookFormatStorage(prepared.format)),
          placement: Value(bookPlacementStorage(prepared.placement)),
          yandexId: Value(_emptyToNull(prepared.yandexId)),
          narrator: Value(prepared.narrator.trim()),
          durationSeconds: Value(prepared.durationSeconds),
          libraryDueAt: Value(prepared.libraryDueAt),
          readerRating: Value(prepared.readerRating),
          reminderSentForDue: dueChanged ? const Value(null) : const Value.absent(),
        ),
      );
      await _replaceLinks(id, prepared);
    });
    await _deleteUnusedFiles(
      previous: {
        if (existing.coverPath != null) existing.coverPath!,
        ...existing.photoPaths,
      },
      next: {
        if (_emptyToNull(prepared.coverPath) != null) prepared.coverPath!,
        ...prepared.photoPaths,
      },
    );
    afterBooksChanged?.call();
  }

  /// Writes only the personal note. Description, publishers and status stay.
  Future<void> updatePersonalNote(int id, String note) async {
    final existing = await (db.select(db.books)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) {
      throw StateError('Книга не найдена');
    }
    await (db.update(db.books)..where((row) => row.id.equals(id))).write(
      BooksCompanion(personalNote: Value(note.trim())),
    );
  }

  Future<void> deleteBook(int id) async {
    final existing = await bookDetails(id);
    if (existing == null) {
      return;
    }
    await (db.delete(db.books)..where((row) => row.id.equals(id))).go();
    afterBooksChanged?.call();
    await _deleteUnusedFiles(
      previous: {
        if (existing.coverPath != null) existing.coverPath!,
        ...existing.photoPaths,
      },
      next: const {},
    );
  }

  Future<void> returnLoan(int id) async {
    await (db.update(db.books)..where((row) => row.id.equals(id))).write(
      const BooksCompanion(loanPerson: Value(null), loanDueAt: Value(null)),
    );
  }

  Future<List<DuplicateMatch>> findDuplicates(
    BookDraft draft, {
    int? excludeId,
  }) async {
    final existing = _duplicateCandidates(await _load());
    return _duplicatesOf(draft, existing, excludeId: excludeId);
  }

  Future<List<List<DuplicateMatch>>> findDuplicatesFor(
    List<BookDraft> drafts,
  ) async {
    final existing = _duplicateCandidates(await _load());
    return [for (final draft in drafts) _duplicatesOf(draft, existing)];
  }

  List<DuplicateCandidate> _duplicateCandidates(_LoadedLibrary loaded) {
    return [
      for (final book in loaded.books)
        DuplicateCandidate(
          id: book.id,
          title: book.title,
          isbn: book.isbn ?? '',
          authors: loaded.authors[book.id] ?? const [],
          locationPath: loaded.summary(book).locationPath,
        ),
    ];
  }

  List<DuplicateMatch> _duplicatesOf(
    BookDraft draft,
    List<DuplicateCandidate> existing, {
    int? excludeId,
  }) {
    return findDuplicateCopies(
      candidate: DuplicateCandidate(
        id: excludeId,
        title: draft.title,
        isbn: draft.isbn,
        authors: draft.authors,
        locationPath: '',
      ),
      existing: existing,
    );
  }

  Future<void> setRowCapacity({required int rowId, required int? capacity}) async {
    if (capacity != null && capacity < 1) {
      throw ArgumentError('Вместимость должна быть больше нуля');
    }
    await (db.update(db.shelfRows)..where((row) => row.id.equals(rowId))).write(
      ShelfRowsCompanion(capacity: Value(capacity)),
    );
  }

  Future<void> moveBook({required int id, int? shelfId, int? rowId}) async {
    final existing = await bookDetails(id);
    if (existing == null) {
      throw StateError('Книга не найдена');
    }
    if (existing.format == BookFormat.audio) {
      throw ArgumentError(audioOffShelfMessage);
    }
    await db.transaction(() async {
      final place = await _resolveLocation(shelfId, rowId);
      await _rejectFilledShelf(
        shelfId: place.shelfId,
        currentShelfId: existing.shelfId,
      );
      final keepsPlace = place.rowId != null && place.rowId == existing.rowId;
      final position = keepsPlace
          ? existing.positionIndex
          : await _nextPosition(place.rowId);
      await (db.update(db.books)..where((row) => row.id.equals(id))).write(
        BooksCompanion(
          shelfId: Value(place.shelfId),
          rowId: Value(place.rowId),
          positionIndex: Value(position),
          placement: const Value('shelf'),
          libraryDueAt: const Value(null),
          reminderSentForDue: const Value(null),
        ),
      );
    });
    afterBooksChanged?.call();
  }

  /// Moves every book in [ids] to one place, in that order.
  ///
  /// Books already on the destination row keep their positions. The others
  /// are appended after the books that were already there. If any book would
  /// be a new placement on a filled shelf, none of the batch is moved.
  Future<void> moveBooks({
    required List<int> ids,
    int? shelfId,
    int? rowId,
  }) async {
    if (ids.isEmpty) {
      return;
    }
    await db.transaction(() async {
      final place = await _resolveLocation(shelfId, rowId);
      final books = <Book>[];
      for (final id in ids) {
        final book = await _requireBook(id);
        if (bookFormatFromStorage(book.bookFormat) == BookFormat.audio) {
          throw ArgumentError(audioOffShelfMessage);
        }
        await _rejectFilledShelf(
          shelfId: place.shelfId,
          currentShelfId: book.shelfId,
        );
        books.add(book);
      }
      var next = await _nextPosition(place.rowId);
      for (final book in books) {
        final keepsPlace = place.rowId != null && place.rowId == book.rowId;
        final position = keepsPlace ? book.positionIndex : next++;
        await (db.update(db.books)..where((row) => row.id.equals(book.id))).write(
          BooksCompanion(
            shelfId: Value(place.shelfId),
            rowId: Value(place.rowId),
            positionIndex: Value(position),
            placement: const Value('shelf'),
            libraryDueAt: const Value(null),
            reminderSentForDue: const Value(null),
          ),
        );
      }
    });
    afterBooksChanged?.call();
  }

  Future<void> setBooksReadingStatus({
    required List<int> ids,
    required ReadingStatus status,
  }) async {
    if (ids.isEmpty) {
      return;
    }
    final stored = readingStatusStorage(status);
    final changedAt = DateTime.now();
    await db.transaction(() async {
      for (final id in ids) {
        await _requireBook(id);
        await (db.update(db.books)..where((row) => row.id.equals(id))).write(
          BooksCompanion(
            readingStatus: Value(stored),
            statusChangedAt: Value(changedAt),
          ),
        );
      }
    });
  }

  Future<void> setBooksPublishers({
    required List<int> ids,
    required List<String> publishers,
  }) async {
    final printed = <int>[];
    for (final id in ids) {
      final book = await _requireBook(id);
      if (bookFormatFromStorage(book.bookFormat) == BookFormat.print) {
        printed.add(id);
      }
    }
    return _replaceBookNames(printed, (id) {
      return _setNames(
        names: publishers,
        clear: () => (db.delete(db.bookPublishers)
              ..where((row) => row.bookId.equals(id)))
            .go(),
        findId: (key) async {
          final row = await (db.select(db.publishers)
                ..where((table) => table.nameKey.equals(key)))
              .getSingleOrNull();
          return row?.id;
        },
        insertId: (name, key) => db.into(db.publishers).insert(
          PublishersCompanion.insert(name: name, nameKey: key),
        ),
        link: (publisherId) => db.into(db.bookPublishers).insert(
          BookPublishersCompanion.insert(bookId: id, publisherId: publisherId),
        ),
      );
    });
  }

  Future<void> setBooksGenres({
    required List<int> ids,
    required List<String> genres,
  }) {
    return _replaceBookNames(ids, (id) {
      return _setNames(
        names: genres,
        clear: () =>
            (db.delete(db.bookGenres)..where((row) => row.bookId.equals(id)))
                .go(),
        findId: (key) async {
          final row = await (db.select(db.genres)
                ..where((table) => table.nameKey.equals(key)))
              .getSingleOrNull();
          return row?.id;
        },
        insertId: (name, key) => db.into(db.genres).insert(
          GenresCompanion.insert(name: name, nameKey: key),
        ),
        link: (genreId) => db.into(db.bookGenres).insert(
          BookGenresCompanion.insert(bookId: id, genreId: genreId),
        ),
      );
    });
  }

  /// Adds [hashtags] to each selected book and keeps the tags it already has.
  Future<void> addBooksHashtags({
    required List<int> ids,
    required List<String> hashtags,
  }) async {
    if (ids.isEmpty || hashtags.isEmpty) {
      return;
    }
    await db.transaction(() async {
      final current = await _hashtagsByBook(keys: false);
      for (final id in ids) {
        await _requireBook(id);
        await _setHashtags(id, [...?current[id], ...hashtags]);
      }
    });
  }

  /// Sets the same loan person. An empty name clears the loan and its due date.
  /// Reading status is left as it is.
  Future<void> setBooksLoanPerson({
    required List<int> ids,
    required String person,
  }) async {
    if (ids.isEmpty) {
      return;
    }
    final name = person.trim();
    await db.transaction(() async {
      for (final id in ids) {
        await _requireBook(id);
        if (name.isEmpty) {
          await (db.update(db.books)..where((row) => row.id.equals(id))).write(
            const BooksCompanion(
              loanPerson: Value(null),
              loanDueAt: Value(null),
            ),
          );
        } else {
          await (db.update(db.books)..where((row) => row.id.equals(id))).write(
            BooksCompanion(loanPerson: Value(name)),
          );
        }
      }
    });
  }

  Future<Book> _requireBook(int id) async {
    final book = await (db.select(db.books)..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (book == null) {
      throw StateError('Книга не найдена');
    }
    return book;
  }

  Future<void> _replaceBookNames(
    List<int> ids,
    Future<void> Function(int id) write,
  ) async {
    if (ids.isEmpty) {
      return;
    }
    await db.transaction(() async {
      for (final id in ids) {
        await _requireBook(id);
        await write(id);
      }
    });
  }

  Future<void> _compactShelfIndexes(int cabinetId) async {
    final shelves = await (db.select(db.shelves)
          ..where((row) => row.cabinetId.equals(cabinetId))
          ..orderBy([
            (row) => OrderingTerm(expression: row.shelfIndex),
            (row) => OrderingTerm(expression: row.id),
          ]))
        .get();
    for (var index = 0; index < shelves.length; index++) {
      if (shelves[index].shelfIndex == index) {
        continue;
      }
      await (db.update(db.shelves)..where((row) => row.id.equals(shelves[index].id)))
          .write(ShelvesCompanion(shelfIndex: Value(index)));
    }
  }

  Future<void> _compactRowIndexes(int shelfId) async {
    final rows = await (db.select(db.shelfRows)
          ..where((row) => row.shelfId.equals(shelfId))
          ..orderBy([
            (row) => OrderingTerm(expression: row.rowIndex),
            (row) => OrderingTerm(expression: row.id),
          ]))
        .get();
    for (var index = 0; index < rows.length; index++) {
      if (rows[index].rowIndex == index) {
        continue;
      }
      await (db.update(db.shelfRows)..where((row) => row.id.equals(rows[index].id)))
          .write(ShelfRowsCompanion(rowIndex: Value(index)));
    }
  }

  Future<void> reorderBooks({
    required int rowId,
    required List<int> orderedIds,
  }) {
    return _reorder(orderedIds, (id, index) async {
      await (db.update(db.books)..where(
        (row) => row.id.equals(id) & row.rowId.equals(rowId),
      )).write(BooksCompanion(positionIndex: Value(index)));
    });
  }

  Future<void> _replaceLinks(int bookId, BookDraft draft) async {
    await _setNames(
      names: draft.authors,
      clear: () => (db.delete(db.bookAuthors)
            ..where((row) => row.bookId.equals(bookId)))
          .go(),
      findId: (key) async {
        final row = await (db.select(db.authors)
              ..where((table) => table.nameKey.equals(key)))
            .getSingleOrNull();
        return row?.id;
      },
      insertId: (name, key) => db.into(db.authors).insert(
        AuthorsCompanion.insert(name: name, nameKey: key),
      ),
      link: (id) => db.into(db.bookAuthors).insert(
        BookAuthorsCompanion.insert(bookId: bookId, authorId: id),
      ),
    );
    await _setNames(
      names: draft.genres,
      clear: () =>
          (db.delete(db.bookGenres)..where((row) => row.bookId.equals(bookId)))
              .go(),
      findId: (key) async {
        final row = await (db.select(db.genres)
              ..where((table) => table.nameKey.equals(key)))
            .getSingleOrNull();
        return row?.id;
      },
      insertId: (name, key) => db.into(db.genres).insert(
        GenresCompanion.insert(name: name, nameKey: key),
      ),
      link: (id) => db.into(db.bookGenres).insert(
        BookGenresCompanion.insert(bookId: bookId, genreId: id),
      ),
    );
    await _setNames(
      names: draft.publishers,
      clear: () => (db.delete(db.bookPublishers)
            ..where((row) => row.bookId.equals(bookId)))
          .go(),
      findId: (key) async {
        final row = await (db.select(db.publishers)
              ..where((table) => table.nameKey.equals(key)))
            .getSingleOrNull();
        return row?.id;
      },
      insertId: (name, key) => db.into(db.publishers).insert(
        PublishersCompanion.insert(name: name, nameKey: key),
      ),
      link: (id) => db.into(db.bookPublishers).insert(
        BookPublishersCompanion.insert(bookId: bookId, publisherId: id),
      ),
    );
    await _setHashtags(bookId, draft.hashtags);
    await (db.delete(db.bookPhotos)..where((row) => row.bookId.equals(bookId)))
        .go();
    final photos = draft.photoPaths.where((path) => path.trim().isNotEmpty);
    var order = 0;
    for (final path in photos) {
      await db.into(db.bookPhotos).insert(
        BookPhotosCompanion.insert(
          bookId: bookId,
          path: path,
          sortOrder: Value(order),
        ),
      );
      order += 1;
    }
  }

  Future<void> _setNames({
    required List<String> names,
    required Future<int> Function() clear,
    required Future<int?> Function(String key) findId,
    required Future<int> Function(String name, String key) insertId,
    required Future<int> Function(int id) link,
  }) async {
    await clear();
    final seen = <String>{};
    for (final raw in names) {
      final name = raw.trim();
      if (name.isEmpty) {
        continue;
      }
      final key = name.toLowerCase();
      if (!seen.add(key)) {
        continue;
      }
      final id = await findId(key) ?? await insertId(name, key);
      await link(id);
    }
  }

  Future<void> _setHashtags(int bookId, List<String> rawTags) async {
    await (db.delete(db.bookHashtags)..where((row) => row.bookId.equals(bookId)))
        .go();
    final seen = <String>{};
    for (final raw in rawTags) {
      final key = normalizeHashtag(raw);
      final display = hashtagDisplayName(raw);
      if (key == null || display == null || !seen.add(key)) {
        continue;
      }
      final existing = await (db.select(db.hashtags)
            ..where((row) => row.nameKey.equals(key)))
          .getSingleOrNull();
      final id =
          existing?.id ??
          await db.into(db.hashtags).insert(
            HashtagsCompanion.insert(nameKey: key, displayName: display),
          );
      await db.into(db.bookHashtags).insert(
        BookHashtagsCompanion.insert(bookId: bookId, hashtagId: id),
      );
    }
  }

  Future<void> _rejectFilledShelf({
    required int? shelfId,
    required int? currentShelfId,
  }) async {
    if (shelfId == null || shelfId == currentShelfId) {
      return;
    }
    if (!await rowOverflowControlEnabled()) {
      return;
    }
    final shelf = await (db.select(db.shelves)
          ..where((row) => row.id.equals(shelfId)))
        .getSingleOrNull();
    if (shelf != null && shelf.filled) {
      throw ArgumentError('Полка переполнена');
    }
  }

  Future<({int? shelfId, int? rowId})> _resolveLocation(
    int? shelfId,
    int? rowId,
  ) async {
    if (rowId != null) {
      final row = await (db.select(db.shelfRows)
            ..where((table) => table.id.equals(rowId)))
          .getSingleOrNull();
      if (row == null) {
        return (shelfId: null, rowId: null);
      }
      return (shelfId: row.shelfId, rowId: row.id);
    }
    if (shelfId == null) {
      return (shelfId: null, rowId: null);
    }
    final rows = await (db.select(db.shelfRows)
          ..where((table) => table.shelfId.equals(shelfId)))
        .get();
    if (rows.length == 1) {
      return (shelfId: shelfId, rowId: rows.single.id);
    }
    if (rows.length > 1) {
      throw const ChooseRowException();
    }
    return (shelfId: null, rowId: null);
  }

  Future<int> _nextPosition(int? rowId) async {
    if (rowId == null) {
      return 0;
    }
    final expression = db.books.positionIndex.max();
    final row = await (db.selectOnly(db.books)
          ..addColumns([expression])
          ..where(db.books.rowId.equals(rowId)))
        .getSingle();
    return (row.read(expression) ?? -1) + 1;
  }

  Future<int> _nextInt(
    Selectable<TypedResult> query,
    Expression<int> maxExpression,
  ) async {
    final row = await query.getSingle();
    final value = row.read<int>(maxExpression);
    return (value ?? -1) + 1;
  }

  Future<void> _reorder(
    List<int> orderedIds,
    Future<void> Function(int id, int index) write,
  ) {
    return db.transaction(() async {
      for (var index = 0; index < orderedIds.length; index++) {
        await write(orderedIds[index], index);
      }
    });
  }

  Future<String?> _setting(String key) async {
    final row = await (db.select(db.appSettings)
          ..where((table) => table.key.equals(key)))
        .getSingleOrNull();
    final value = row?.value.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  Future<void> _setSetting(String key, String? value) async {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await (db.delete(db.appSettings)..where((row) => row.key.equals(key)))
          .go();
      return;
    }
    await db.into(db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: trimmed),
    );
  }

  Future<List<String>> _suggestNames<T>({
    required Future<List<T>> Function() load,
    required String Function(T row) nameOf,
    required String Function(T row) keyOf,
    required String query,
  }) async {
    final needle = query.trim().toLowerCase();
    final rows = await load();
    final matched =
        rows.where((row) => needle.isEmpty || keyOf(row).contains(needle)).toList()
          ..sort((a, b) => nameOf(a).compareTo(nameOf(b)));
    return matched.take(8).map(nameOf).toList();
  }

  Future<List<String>> _suggestHashtags(String query) async {
    final needle = normalizeHashtag(query) ?? '';
    final rows = await (db.select(db.hashtags)).get();
    final matched =
        rows
            .where((row) => needle.isEmpty || row.nameKey.contains(needle))
            .toList()
          ..sort((a, b) => a.displayName.compareTo(b.displayName));
    return matched.take(8).map((row) => row.displayName).toList();
  }

  Future<void> _deleteUnusedFiles({
    required Set<String> previous,
    required Set<String> next,
  }) async {
    for (final path in previous.difference(next)) {
      await images.deleteRelative(path);
    }
  }

  String? _loanPerson(BookDraft draft) {
    final name = draft.loanPerson.trim();
    if (name.isEmpty) {
      return null;
    }
    return name;
  }

  DateTime? _loanDue(BookDraft draft) {
    if (_loanPerson(draft) == null) {
      return null;
    }
    return draft.loanDueAt;
  }

  String? _cleanIsbn(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return normalizeIsbn(trimmed) ?? trimmed;
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  /// One database listener for every open screen. Each change gets a number,
  /// and screens reloading for the same number share one [_load].
  Stream<int> get _changes {
    final existing = _changeHub;
    if (existing != null) {
      return existing.stream;
    }
    final hub = StreamController<int>.broadcast();
    hub.onListen = () {
      var first = true;
      _changeSource = db
          .customSelect(
            'SELECT 1 AS ping',
            readsFrom: {
              db.rooms,
              db.cabinets,
              db.shelves,
              db.shelfRows,
              db.books,
              db.bookPhotos,
              db.authors,
              db.genres,
              db.publishers,
              db.hashtags,
              db.bookAuthors,
              db.bookGenres,
              db.bookPublishers,
              db.bookHashtags,
              db.appSettings,
            },
          )
          .watch()
          .listen((_) {
            if (first) {
              first = false;
              return;
            }
            hub.add(++_changeNumber);
          });
    };
    hub.onCancel = () {
      _changeSource?.cancel();
      _changeSource = null;
    };
    _changeHub = hub;
    return hub.stream;
  }

  Stream<T> _watch<T>(Future<T> Function() load) {
    var ticket = 0;
    StreamSubscription<int>? subscription;
    late final StreamController<T> controller;
    void run(int? change) {
      final mine = ++ticket;
      final future = change == null
          ? load()
          : runZoned(load, zoneValues: {_sharedLoadKey: change});
      future.then(
        (value) {
          if (mine == ticket && !controller.isClosed) {
            controller.add(value);
          }
        },
        onError: (Object error, StackTrace stack) {
          if (mine == ticket && !controller.isClosed) {
            controller.addError(error, stack);
          }
        },
      );
    }

    controller = StreamController<T>(
      onListen: () {
        subscription = _changes.listen(run);
        run(null);
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }

  Future<_LoadedLibrary> _load() {
    final change = Zone.current[_sharedLoadKey];
    if (change is! int) {
      return _loadFresh();
    }
    if (_sharedChange != change || _sharedLoad == null) {
      _sharedChange = change;
      _sharedLoad = _loadFresh();
    }
    return _sharedLoad!;
  }

  Future<_LoadedLibrary> _loadFresh() async {
    final rooms = await (db.select(db.rooms)..orderBy([
      (table) => OrderingTerm(expression: table.sortOrder),
      (table) => OrderingTerm(expression: table.id),
    ])).get();
    final cabinets = await (db.select(db.cabinets)..orderBy([
      (table) => OrderingTerm(expression: table.sortOrder),
      (table) => OrderingTerm(expression: table.id),
    ])).get();
    final shelves = await (db.select(db.shelves)..orderBy([
      (table) => OrderingTerm(expression: table.shelfIndex),
      (table) => OrderingTerm(expression: table.id),
    ])).get();
    final rows = await (db.select(db.shelfRows)..orderBy([
      (table) => OrderingTerm(expression: table.rowIndex),
      (table) => OrderingTerm(expression: table.id),
    ])).get();
    final books = await (db.select(db.books)..orderBy([
      (table) => OrderingTerm(expression: table.positionIndex),
      (table) => OrderingTerm(expression: table.id),
    ])).get();
    final photos = await (db.select(db.bookPhotos)..orderBy([
      (table) => OrderingTerm(expression: table.sortOrder),
      (table) => OrderingTerm(expression: table.id),
    ])).get();
    final controlOverflow = await rowOverflowControlEnabled();
    return _LoadedLibrary(
      rooms: rooms,
      cabinets: cabinets,
      shelves: shelves,
      rows: rows,
      books: books,
      authors: _namesByBook(
        links: await db.select(db.bookAuthors).join([
          innerJoin(
            db.authors,
            db.authors.id.equalsExp(db.bookAuthors.authorId),
          ),
        ]).get(),
        bookId: (row) => row.readTable(db.bookAuthors).bookId,
        name: (row) => row.readTable(db.authors).name,
      ),
      genres: _namesByBook(
        links: await db.select(db.bookGenres).join([
          innerJoin(db.genres, db.genres.id.equalsExp(db.bookGenres.genreId)),
        ]).get(),
        bookId: (row) => row.readTable(db.bookGenres).bookId,
        name: (row) => row.readTable(db.genres).name,
      ),
      publishers: _namesByBook(
        links: await db.select(db.bookPublishers).join([
          innerJoin(
            db.publishers,
            db.publishers.id.equalsExp(db.bookPublishers.publisherId),
          ),
        ]).get(),
        bookId: (row) => row.readTable(db.bookPublishers).bookId,
        name: (row) => row.readTable(db.publishers).name,
      ),
      hashtagLabels: await _hashtagsByBook(keys: false),
      hashtagKeys: await _hashtagsByBook(keys: true),
      photos: _group(photos, (photo) => photo.bookId, (photo) => photo.path),
      controlOverflow: controlOverflow,
    );
  }

  Future<Map<int, List<String>>> _hashtagsByBook({required bool keys}) async {
    final rows = await db.select(db.bookHashtags).join([
      innerJoin(
        db.hashtags,
        db.hashtags.id.equalsExp(db.bookHashtags.hashtagId),
      ),
    ]).get();
    return _namesByBook(
      links: rows,
      bookId: (row) => row.readTable(db.bookHashtags).bookId,
      name: (row) => keys
          ? row.readTable(db.hashtags).nameKey
          : row.readTable(db.hashtags).displayName,
    );
  }

  Map<int, List<String>> _namesByBook<T>({
    required List<T> links,
    required int Function(T row) bookId,
    required String Function(T row) name,
  }) {
    return _group(links, bookId, name);
  }

  Map<int, List<String>> _group<T>(
    List<T> rows,
    int Function(T row) idOf,
    String Function(T row) valueOf,
  ) {
    final map = <int, List<String>>{};
    for (final row in rows) {
      map.putIfAbsent(idOf(row), () => []).add(valueOf(row));
    }
    return map;
  }
}

class _LoadedLibrary {
  _LoadedLibrary({
    required this.rooms,
    required this.cabinets,
    required this.shelves,
    required this.rows,
    required this.books,
    required this.authors,
    required this.genres,
    required this.publishers,
    required this.hashtagLabels,
    required this.hashtagKeys,
    required this.photos,
    required this.controlOverflow,
  });

  final List<Room> rooms;
  final List<Cabinet> cabinets;
  final List<Shelf> shelves;
  final List<ShelfRow> rows;
  final List<Book> books;
  final Map<int, List<String>> authors;
  final Map<int, List<String>> genres;
  final Map<int, List<String>> publishers;
  final Map<int, List<String>> hashtagLabels;
  final Map<int, List<String>> hashtagKeys;
  final Map<int, List<String>> photos;
  final bool controlOverflow;

  bool _overfull(int bookCount, int? capacity) {
    if (!controlOverflow) {
      return false;
    }
    return rowIsOverfull(bookCount: bookCount, capacity: capacity);
  }

  bool _shelfOverfull(int shelfId) {
    for (final row in rows.where((item) => item.shelfId == shelfId)) {
      final count = books.where((book) => book.rowId == row.id).length;
      if (_overfull(count, row.capacity)) {
        return true;
      }
    }
    return false;
  }

  List<BookSummary> summaries() {
    return [for (final book in books) summary(book)];
  }

  List<RoomOverview> roomOverviews() {
    return [
      for (final room in rooms)
        RoomOverview(
          id: room.id,
          name: room.name,
          note: room.note,
          cabinets: [
            for (final cabinet in cabinets.where((item) => item.roomId == room.id))
              CabinetOverview(
                id: cabinet.id,
                name: cabinet.name,
                shelves: [
                  for (final shelf in shelves.where(
                    (item) => item.cabinetId == cabinet.id,
                  ))
                    ShelfTick(
                      id: shelf.id,
                      index: shelf.shelfIndex,
                      bookCount: books
                          .where((book) => book.shelfId == shelf.id)
                          .length,
                      overfull: _shelfOverfull(shelf.id),
                    ),
                ],
              ),
          ],
        ),
    ];
  }

  CabinetDetails? cabinetDetails(int id) {
    final cabinet = _firstWhere(cabinets, (item) => item.id == id);
    if (cabinet == null) {
      return null;
    }
    final room = _firstWhere(rooms, (item) => item.id == cabinet.roomId);
    return CabinetDetails(
      id: cabinet.id,
      roomId: cabinet.roomId,
      roomName: room?.name ?? '',
      name: cabinet.name,
      shelves: [
        for (final shelf in shelves.where((item) => item.cabinetId == cabinet.id))
          shelfInfo(shelf.id)!,
      ],
    );
  }

  ShelfInfo? shelfInfo(int id) {
    final shelf = _firstWhere(shelves, (item) => item.id == id);
    if (shelf == null) {
      return null;
    }
    final shelfRows = rows.where((row) => row.shelfId == shelf.id);
    return ShelfInfo(
      id: shelf.id,
      cabinetId: shelf.cabinetId,
      index: shelf.shelfIndex,
      label: shelf.label,
      bookCount: books.where((book) => book.shelfId == shelf.id).length,
      filled: shelf.filled,
      rows: [
        for (final row in shelfRows)
          RowInfo(
            id: row.id,
            index: row.rowIndex,
            label: row.label,
            bookCount: books.where((book) => book.rowId == row.id).length,
            capacity: row.capacity,
            overfull: _overfull(
              books.where((book) => book.rowId == row.id).length,
              row.capacity,
            ),
          ),
      ],
    );
  }

  RowPageData? rowPage(int rowId) {
    final row = _firstWhere(rows, (item) => item.id == rowId);
    if (row == null) {
      return null;
    }
    final shelf = shelfInfo(row.shelfId);
    if (shelf == null) {
      return null;
    }
    final cabinet = _firstWhere(cabinets, (item) => item.id == shelf.cabinetId);
    final room = cabinet == null
        ? null
        : _firstWhere(rooms, (item) => item.id == cabinet.roomId);
    final rowInfo = shelf.rows.where((item) => item.id == rowId).firstOrNull;
    if (rowInfo == null) {
      return null;
    }
    final onRow =
        books.where((book) => book.rowId == rowId).map(summary).toList()
          ..sort((a, b) {
            final byPosition = a.positionIndex.compareTo(b.positionIndex);
            if (byPosition != 0) {
              return byPosition;
            }
            return a.id.compareTo(b.id);
          });
    return RowPageData(
      shelf: shelf,
      row: rowInfo,
      roomName: room?.name ?? '',
      cabinetName: cabinet?.name ?? '',
      books: onRow,
    );
  }

  BookDetails? details(int id) {
    final book = _firstWhere(books, (item) => item.id == id);
    if (book == null) {
      return null;
    }
    final place = _place(book);
    return BookDetails(
      id: book.id,
      title: book.title,
      subtitle: book.subtitle,
      description: book.description,
      personalNote: book.personalNote,
      isbn: book.isbn ?? '',
      authors: authors[book.id] ?? const [],
      genres: genres[book.id] ?? const [],
      publishers: publishers[book.id] ?? const [],
      hashtags: hashtagLabels[book.id] ?? const [],
      coverPath: book.coverPath,
      photoPaths: photos[book.id] ?? const [],
      sourceUrl: book.sourceUrl ?? '',
      locationPath: place.path,
      positionIndex: book.positionIndex,
      createdAt: book.createdAt,
      shelfId: book.shelfId,
      rowId: book.rowId,
      roomId: place.roomId,
      cabinetId: place.cabinetId,
      readingStatus: readingStatusFromStorage(book.readingStatus),
      statusChangedAt: book.statusChangedAt,
      seriesName: book.seriesName ?? '',
      seriesVolume: book.seriesVolume,
      loanPerson: book.loanPerson ?? '',
      loanDueAt: book.loanDueAt,
      format: bookFormatFromStorage(book.bookFormat),
      placement: bookPlacementFromStorage(book.placement),
      libraryDueAt: book.libraryDueAt,
      yandexId: book.yandexId ?? '',
      narrator: book.narrator,
      durationSeconds: book.durationSeconds,
      readerRating: book.readerRating,
    );
  }

  BookSummary summary(Book book) {
    final place = _place(book);
    return BookSummary(
      id: book.id,
      title: book.title,
      authorsLabel: (authors[book.id] ?? const []).join(', '),
      genresLabel: (genres[book.id] ?? const []).join(', '),
      coverPath: book.coverPath,
      locationPath: place.path,
      positionIndex: book.positionIndex,
      createdAt: book.createdAt,
      roomId: place.roomId,
      cabinetId: place.cabinetId,
      shelfId: book.shelfId,
      rowId: book.rowId,
      readingStatus: readingStatusFromStorage(book.readingStatus),
      statusChangedAt: book.statusChangedAt,
      seriesName: book.seriesName ?? '',
      seriesVolume: book.seriesVolume,
      loanPerson: book.loanPerson ?? '',
      loanDueAt: book.loanDueAt,
      format: bookFormatFromStorage(book.bookFormat),
      placement: bookPlacementFromStorage(book.placement),
      libraryDueAt: book.libraryDueAt,
      yandexId: book.yandexId ?? '',
      narrator: book.narrator,
      durationSeconds: book.durationSeconds,
    );
  }

  List<BookSearchRecord> searchRecords() {
    final records = <BookSearchRecord>[];
    final ordered = [...books]..sort((a, b) {
      final byDate = b.createdAt.compareTo(a.createdAt);
      if (byDate != 0) {
        return byDate;
      }
      return b.id.compareTo(a.id);
    });
    for (final book in ordered) {
      final place = _place(book);
      records.add(
        BookSearchRecord(
          id: book.id,
          title: book.title,
          subtitle: book.subtitle,
          description: book.description,
          isbn: book.isbn ?? '',
          authors: authors[book.id] ?? const [],
          genres: genres[book.id] ?? const [],
          publishers: publishers[book.id] ?? const [],
          hashtags: hashtagKeys[book.id] ?? const [],
          seriesName: book.seriesName ?? '',
          roomId: place.roomId,
          cabinetId: place.cabinetId,
          shelfId: book.shelfId,
          locationPath: place.path,
          coverPath: book.coverPath,
          readingStatus: readingStatusFromStorage(book.readingStatus),
          format: bookFormatFromStorage(book.bookFormat),
          createdAt: book.createdAt,
        ),
      );
    }
    return records;
  }

  List<LocationOption> locationOptions() {
    final options = <LocationOption>[];
    for (final room in rooms) {
      for (final cabinet in cabinets.where((item) => item.roomId == room.id)) {
        for (final shelf in shelves.where(
          (item) => item.cabinetId == cabinet.id,
        )) {
          final info = shelfInfo(shelf.id);
          if (info == null) {
            continue;
          }
          options.add(
            LocationOption(
              roomId: room.id,
              roomName: room.name,
              cabinetId: cabinet.id,
              cabinetName: cabinet.name,
              shelfId: shelf.id,
              shelfIndex: shelf.shelfIndex,
              shelfLabel: shelf.label,
              shelfFilled: shelf.filled,
              rows: info.rows,
            ),
          );
        }
      }
    }
    return options;
  }

  _Place _place(Book book) {
    final format = bookFormatFromStorage(book.bookFormat);
    final placement = bookPlacementFromStorage(book.placement);
    if (placement == BookPlacement.library) {
      return const _Place(path: 'Библиотека');
    }
    if (format == BookFormat.audio) {
      return const _Place(path: 'Аудио');
    }
    final shelf = book.shelfId == null
        ? null
        : _firstWhere(shelves, (item) => item.id == book.shelfId);
    final cabinet = shelf == null
        ? null
        : _firstWhere(cabinets, (item) => item.id == shelf.cabinetId);
    final room = cabinet == null
        ? null
        : _firstWhere(rooms, (item) => item.id == cabinet.roomId);
    final row = book.rowId == null
        ? null
        : _firstWhere(rows, (item) => item.id == book.rowId);
    final parts = LocationParts(
      roomName: room?.name,
      cabinetName: cabinet?.name,
      shelfIndex: shelf?.shelfIndex,
      shelfLabel: shelf?.label,
      rowIndex: row?.rowIndex,
      rowLabel: row?.label,
      positionIndex: book.positionIndex,
    );
    return _Place(
      path: formatLocationPath(parts),
      roomId: room?.id,
      cabinetId: cabinet?.id,
    );
  }
}

class _Place {
  const _Place({required this.path, this.roomId, this.cabinetId});

  final String path;
  final int? roomId;
  final int? cabinetId;
}

bool _isUnplaced(BookSummary book) {
  return countsAsUnplaced(
    format: book.format,
    placement: book.placement,
    shelfId: book.shelfId,
  );
}

T? _firstWhere<T>(List<T> items, bool Function(T item) test) {
  for (final item in items) {
    if (test(item)) {
      return item;
    }
  }
  return null;
}
