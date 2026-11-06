import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_library/core/logging/app_log.dart';
import 'package:my_library/core/models/home_layout.dart';
import 'package:my_library/core/models/shelf_model.dart';
import 'package:my_library/core/models/library_view.dart';
import 'package:my_library/core/platform_support.dart';
import 'package:my_library/core/search/book_search.dart';
import 'package:my_library/core/storage/image_store.dart';
import 'package:my_library/core/storage/library_paths.dart';
import 'package:my_library/core/theme/theme_choice.dart';
import 'package:my_library/core/logging/catalog_request.dart';
import 'package:my_library/data/cover_text_recognizer.dart';
import 'package:my_library/data/database_handle.dart';
import 'package:my_library/data/kimi_shelf_reader.dart';
import 'package:my_library/core/notes/voice_note.dart';
import 'package:my_library/data/device_speech.dart';
import 'package:my_library/data/voice_note_client.dart';
import 'package:my_library/data/yandex_shelf_reader.dart';
import 'package:my_library/data/library_reminders.dart';
import 'package:my_library/data/library_repository.dart';
import 'package:my_library/data/metadata_service.dart';
import 'package:my_library/data/mlkit_cover_text_recognizer.dart';
import 'package:my_library/data/shelf_model_client.dart';
import 'package:my_library/data/spine_text_recognizer.dart';

final libraryPathsProvider = Provider<LibraryPaths>((ref) {
  throw StateError('LibraryPaths должен быть задан при запуске');
});

final databaseHandleProvider = Provider<DatabaseHandle>((ref) {
  final handle = DatabaseHandle(ref.watch(libraryPathsProvider));
  ref.onDispose(handle.close);
  return handle;
});

final databaseProvider = Provider((ref) {
  return ref.watch(databaseHandleProvider).database;
});

final imageStoreProvider = Provider<ImageStore>((ref) {
  return ImageStore(ref.watch(libraryPathsProvider));
});

class CatalogSendConsent {
  const CatalogSendConsent({required this.livelib, required this.yandexBooks});

  final bool livelib;
  final bool yandexBooks;
}

final catalogSendConsentProvider = FutureProvider<CatalogSendConsent>((ref) async {
  final repository = ref.watch(libraryRepositoryProvider);
  return CatalogSendConsent(
    livelib: await repository.livelibSendConsent(),
    yandexBooks: await repository.yandexBooksReviewConsent(),
  );
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(
    ref.watch(databaseProvider),
    ref.watch(imageStoreProvider),
  );
});

final shelfModelChoiceProvider = FutureProvider<ShelfModelChoice>((ref) {
  return ref.watch(libraryRepositoryProvider).shelfModel();
});

final voiceModelChoiceProvider = FutureProvider<ShelfModelChoice>((ref) {
  return ref.watch(libraryRepositoryProvider).voiceModel();
});

final libraryRemindersProvider = Provider<LibraryReminders>((ref) {
  return LibraryReminders(
    ref.watch(libraryRepositoryProvider),
    ref.watch(appLogProvider),
  );
});

final appLogProvider = Provider<AppLog>((ref) {
  return AppLog(ref.watch(libraryPathsProvider).logFile);
});

final metadataServiceProvider = Provider<MetadataService>((ref) {
  final service = MetadataService(
    model: ({String? isbn, String? title, String? author}) {
      return askConnectedModel(
        repository: ref.read(libraryRepositoryProvider),
        kimi: ref.read(kimiShelfReaderProvider),
        yandex: ref.read(yandexShelfReaderProvider),
        isbn: isbn,
        title: title,
        author: author,
      );
    },
    log: (record) {
      final status = record.statusCode?.toString() ?? 'нет кода';
      final outcome = record.error == null
          ? '$status, вариантов: ${record.resultCount}'
          : '$status, ${record.error}';
      return ref.read(appLogProvider).write(
        '${record.catalog} · ${record.kind}',
        '${record.detail} | $outcome',
      );
    },
  );
  ref.onDispose(service.close);
  return service;
});

String _modelDetail(ModelCallRecord record) {
  final parts = <String>[
    if (record.statusCode != null) 'код ${record.statusCode}',
    if (record.shelfCount != null)
      'полок ${record.shelfCount}, корешков ${record.bookCount ?? 0}',
    if (record.error != null) record.error!,
  ];
  return parts.join(', ');
}

final kimiShelfReaderProvider = Provider<KimiShelfReader>((ref) {
  final reader = KimiShelfReader(
    log: (record) {
      return ref.read(appLogProvider).write(
        'Модель · ${record.model}',
        _modelDetail(record),
      );
    },
  );
  ref.onDispose(reader.close);
  return reader;
});

final voiceNoteClientProvider = Provider<VoiceNoteClient>((ref) {
  final client = VoiceNoteClient(
    log: (record) {
      return ref.read(appLogProvider).writeAlways(
        'Модель · ${record.model}',
        _modelDetail(record),
      );
    },
  );
  ref.onDispose(client.close);
  return client;
});

final phoneRecognizerProvider = Provider<PhoneRecognizer>((ref) {
  return SystemPhoneRecognizer(
    log: (detail) {
      ref.read(appLogProvider).writeAlways('Распознавание речи', detail);
    },
  );
});

final noteRecorderProvider = Provider<NoteRecorder>((ref) {
  final recorder = SystemNoteRecorder();
  ref.onDispose(recorder.dispose);
  return recorder;
});

final yandexShelfReaderProvider = Provider<YandexShelfReader>((ref) {
  final reader = YandexShelfReader(
    log: (record) {
      return ref.read(appLogProvider).write(
        'Модель · Яндекс · ${record.model}',
        _modelDetail(record),
      );
    },
  );
  ref.onDispose(reader.close);
  return reader;
});

final homeLayoutProvider = StreamProvider<HomeLayout>((ref) {
  return ref.watch(libraryRepositoryProvider).watchHomeLayout();
});

final homeStatProvider = StreamProvider.family<List<BookSummary>, HomeStat>((ref, stat) {
  return ref.watch(libraryRepositoryProvider).watchHomeStat(stat);
});

final spineScriptRecognizerProvider = Provider<SpineScriptRecognizer>((ref) {
  if (deviceCaptureSupported) {
    return const TesseractSpineRecognizer();
  }
  return const UnavailableSpineScriptRecognizer();
});

final coverTextRecognizerProvider = Provider<CoverTextRecognizer>((ref) {
  if (deviceCaptureSupported) {
    return const MlkitCoverTextRecognizer();
  }
  return const UnavailableCoverTextRecognizer();
});

final homeProvider = StreamProvider<HomeSnapshot>((ref) {
  return ref.watch(libraryRepositoryProvider).watchHome();
});

final cabinetProvider = StreamProvider.family<CabinetDetails?, int>((ref, id) {
  return ref.watch(libraryRepositoryProvider).watchCabinet(id);
});

final shelfProvider = StreamProvider.family<ShelfInfo?, int>((ref, id) {
  return ref.watch(libraryRepositoryProvider).watchShelf(id);
});

final rowProvider = StreamProvider.family<RowPageData?, int>((ref, id) {
  return ref.watch(libraryRepositoryProvider).watchRow(id);
});

final unplacedProvider = StreamProvider<List<BookSummary>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchUnplaced();
});

final bookProvider = StreamProvider.family<BookDetails?, int>((ref, id) {
  return ref.watch(libraryRepositoryProvider).watchBook(id);
});

final locationOptionsProvider = StreamProvider<List<LocationOption>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchLocationOptions();
});

final hashtagsProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchHashtags();
});

final searchIndexProvider = StreamProvider<List<BookSearchRecord>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchSearch();
});

final themeChoiceProvider = StreamProvider<AppThemeChoice>((ref) {
  return ref.watch(libraryRepositoryProvider).watchTheme();
});
