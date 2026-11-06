import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_library/core/isbn.dart';
import 'package:my_library/core/metadata/metadata_mapper.dart';
import 'package:my_library/core/metadata/spine_slices.dart';
import 'package:my_library/data/shelf_model_client.dart';
import 'package:my_library/core/models/book_copy.dart';
import 'package:my_library/core/models/book_draft.dart';
import 'package:my_library/core/models/metadata_candidate.dart';
import 'package:my_library/data/candidate_fill.dart';
import 'package:my_library/core/platform_support.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/user_message.dart';

enum CaptureNext { candidates, form, batch, rejected }

class CaptureState {
  const CaptureState({
    this.method,
    this.drafts = const [],
    this.activeIndex = 0,
    this.busy = false,
    this.error,
  });

  final CaptureMethod? method;
  final List<BookDraft> drafts;
  final int activeIndex;
  final bool busy;
  final String? error;

  BookDraft? get active {
    if (drafts.isEmpty) {
      return null;
    }
    final index = activeIndex.clamp(0, drafts.length - 1);
    return drafts[index];
  }

  CaptureState copyWith({
    Object? method = _keep,
    List<BookDraft>? drafts,
    int? activeIndex,
    bool? busy,
    Object? error = _keep,
  }) {
    return CaptureState(
      method: identical(method, _keep) ? this.method : method as CaptureMethod?,
      drafts: drafts ?? this.drafts,
      activeIndex: activeIndex ?? this.activeIndex,
      busy: busy ?? this.busy,
      error: identical(error, _keep) ? this.error : error as String?,
    );
  }
}

const _keep = Object();

class CaptureController extends Notifier<CaptureState> {
  @override
  CaptureState build() => const CaptureState();

  void reset() {
    state = const CaptureState();
  }

  void setActive(int index) {
    state = state.copyWith(activeIndex: index);
  }

  void assignLocationToAll({required int? shelfId, required int? rowId}) {
    state = state.copyWith(
      drafts: [
        for (final draft in state.drafts)
          if (draft.savedBookId == null)
            draft.copyWith(shelfId: shelfId, rowId: rowId)
          else
            draft,
      ],
    );
  }

  void useManualForm() {
    final current = state.active;
    if (current == null) {
      return;
    }
    final title = current.title.trim().isNotEmpty
        ? current.title.trim()
        : titleFromRecognizedText(current.recognizedText);
    _replaceActive(current.copyWith(title: title, candidates: const []));
  }

  Future<CaptureNext> searchManual({
    required String title,
    String author = '',
  }) {
    final trimmedTitle = title.trim();
    final trimmedAuthor = author.trim();
    final query = [
      trimmedTitle,
      trimmedAuthor,
    ].where((part) => part.isNotEmpty).join(' ');
    return _lookup(
      method: CaptureMethod.manual,
      seed: BookDraft(
        localKey: _key(),
        title: trimmedTitle,
        authors: trimmedAuthor.isEmpty ? const [] : [trimmedAuthor],
      ),
      title: trimmedTitle,
      author: trimmedAuthor,
      query: query,
    );
  }

  Future<CaptureNext> consumeBarcode(String raw) async {
    final isbn = isbnFromText(raw);
    if (isbn == null) {
      state = state.copyWith(
        method: CaptureMethod.barcode,
        busy: false,
        error: 'Это не ISBN: ${raw.trim()}',
      );
      await _log('Штрихкод отклонён', raw);
      return CaptureNext.rejected;
    }
    return _lookup(
      method: CaptureMethod.barcode,
      seed: BookDraft(localKey: _key(), isbn: isbn),
      isbn: isbn,
    );
  }

  Future<CaptureNext> consumePhoto(String absolutePath) async {
    state = state.copyWith(
      method: CaptureMethod.singlePhoto,
      busy: true,
      error: null,
    );
    final draft = await _draftFromImage(absolutePath);
    state = state.copyWith(
      method: CaptureMethod.singlePhoto,
      drafts: [draft],
      activeIndex: 0,
      busy: false,
    );
    await _log(
      'Фото обработано',
      'название «${draft.title}», вариантов: ${draft.candidates.length}',
    );
    if (draft.candidates.isNotEmpty) {
      return CaptureNext.candidates;
    }
    return CaptureNext.form;
  }

  Future<CaptureNext> consumeBatch(List<String> absolutePaths) async {
    state = state.copyWith(
      method: CaptureMethod.batchPhotos,
      busy: true,
      error: null,
      drafts: const [],
    );
    final drafts = <BookDraft>[];
    for (final path in absolutePaths) {
      drafts.add(await _draftFromImage(path));
    }
    state = state.copyWith(
      method: CaptureMethod.batchPhotos,
      busy: false,
      drafts: drafts,
      activeIndex: 0,
    );
    return CaptureNext.batch;
  }

  Future<void> applyCandidate(MetadataCandidate candidate) async {
    final current = state.active;
    if (current == null) {
      return;
    }
    state = state.copyWith(busy: true, error: null);
    try {
      _replaceActive(await _materialize(current, candidate));
      state = state.copyWith(busy: false);
    } catch (error) {
      state = state.copyWith(busy: false, error: userFacingError(error));
    }
  }

  Future<int?> saveDraft(BookDraft draft) async {
    final index = state.activeIndex;
    if (index < 0 || index >= state.drafts.length) {
      return null;
    }
    if (draft.savedBookId != null) {
      return draft.savedBookId;
    }
    state = state.copyWith(busy: true, error: null);
    try {
      final id = await ref.read(libraryRepositoryProvider).createBook(draft);
      await _log('Книга сохранена', '«${draft.title}», id $id');
      final drafts = [...state.drafts];
      drafts[index] = draft.copyWith(savedBookId: id, candidates: const []);
      state = state.copyWith(busy: false, drafts: drafts);
      return id;
    } catch (error) {
      state = state.copyWith(busy: false, error: userFacingError(error));
      await _log('Ошибка сохранения', userFacingError(error));
      return null;
    }
  }

  Future<int> saveAll() async {
    var saved = 0;
    final total = state.drafts.length;
    for (var index = 0; index < total; index++) {
      final draft = state.drafts[index];
      if (!draft.canSave) {
        continue;
      }
      state = state.copyWith(activeIndex: index);
      final id = await saveDraft(state.drafts[index]);
      if (id != null) {
        saved += 1;
      }
    }
    return saved;
  }

  Future<CaptureNext> _lookup({
    required CaptureMethod method,
    required BookDraft seed,
    String? query,
    String? title,
    String? author,
    String? isbn,
  }) async {
    state = state.copyWith(
      method: method,
      busy: true,
      error: null,
      drafts: [seed],
      activeIndex: 0,
    );
    await _log(
      'Поиск в каталоге',
      [
        if (isbn != null && isbn.isNotEmpty) 'ISBN $isbn',
        if (query != null && query.trim().isNotEmpty) '«${query.trim()}»',
      ].join(', '),
    );
    try {
      final candidates = await ref.read(metadataServiceProvider).search(
        query: query,
        title: title,
        author: author,
        isbn: isbn,
      );
      if (candidates.isEmpty) {
        state = state.copyWith(
          busy: false,
          error: 'В каталогах ничего не найдено.',
          drafts: [seed],
        );
        await _log('Каталог пуст');
        return CaptureNext.form;
      }
      if (candidates.length == 1) {
        final filled = await _materialize(seed, candidates.single);
        state = state.copyWith(busy: false, drafts: [filled]);
        await _log('Карточка заполнена', '«${filled.title}»');
        return CaptureNext.form;
      }
      state = state.copyWith(
        busy: false,
        drafts: [seed.copyWith(candidates: candidates)],
      );
      await _log('Найдены варианты', 'количество: ${candidates.length}');
      return CaptureNext.candidates;
    } catch (error) {
      final message = userFacingError(error);
      state = state.copyWith(busy: false, error: message);
      await _log('Ошибка поиска', message);
      return CaptureNext.form;
    }
  }

  Future<void> _log(String action, [String? detail]) {
    return ref.read(appLogProvider).write(action, detail);
  }

  Future<BookDraft> _draftFromImage(String absolutePath) async {
    final bytes = await File(absolutePath).readAsBytes();
    final photoPath = await ref.read(imageStoreProvider).saveBytes(
      bytes,
      cover: false,
    );
    final scannedIsbn = await _isbnFromImage(absolutePath);
    final connection = await ref.read(libraryRepositoryProvider).shelfConnection();
    if (connection.canReadPhoto) {
      try {
        final seen = await readShelfSpine(
          connection: connection,
          jpeg: bytes,
          kimi: ref.read(kimiShelfReaderProvider),
          yandex: ref.read(yandexShelfReaderProvider),
        );
        if (seen != null) {
          await _log(
            'Разбор фото',
            'модель «${seen.title}», ISBN ${scannedIsbn ?? "нет"}',
          );
          final candidates = await _searchQuietly(
            isbn: scannedIsbn,
            title: seen.title,
            author: seen.author,
          );
          final seed = BookDraft(
            localKey: _key(),
            isbn: scannedIsbn ?? '',
            title: seen.title,
            authors: seen.author.trim().isEmpty ? const [] : [seen.author.trim()],
            photoPaths: [photoPath],
          );
          if (candidates.isNotEmpty) {
            state = state.copyWith(error: null);
          }
          if (candidates.length == 1) {
            return await _materialize(seed, candidates.single);
          }
          if (candidates.isEmpty) {
            state = state.copyWith(
              error: state.error ?? 'По фото в каталогах ничего не найдено.',
            );
          }
          return seed.copyWith(candidates: candidates);
        }
      } catch (error) {
        state = state.copyWith(error: userFacingError(error));
      }
    }
    var latin = '';
    var russian = '';
    if (!deviceCaptureSupported) {
      state = state.copyWith(
        error:
            'Распознавание текста доступно на телефоне. Заполните карточку вручную.',
      );
    } else {
      try {
        latin =
            await ref.read(coverTextRecognizerProvider).recognizeFile(
              absolutePath,
            ) ??
            '';
      } catch (_) {
        state = state.copyWith(error: 'Не удалось прочитать цифры на фото.');
      }
      try {
        russian = await ref
            .read(spineScriptRecognizerProvider)
            .recognizeFile(absolutePath);
      } catch (_) {
        state = state.copyWith(error: 'Не удалось прочитать русскую надпись на фото.');
      }
    }
    final cleaned = readableSpineText(russian);
    final recognized = cyrillicLetters(cleaned) >= 2 ? cleaned : '';
    final isbn = scannedIsbn ?? isbnFromText(latin) ?? isbnFromText(cleaned);
    await _log(
      'Разбор фото',
      'ISBN ${isbn ?? "нет"}, распознано ${recognized.length} симв.',
    );
    final queries = [
      for (final query in searchQueriesFromRecognizedText(recognized))
        if (cyrillicLetters(query) >= 3) query,
    ];
    List<MetadataCandidate> candidates = const [];
    if (isbn != null) {
      candidates = await _searchQuietly(
        isbn: isbn,
        title: queries.isEmpty ? null : queries.first,
      );
    }
    if (candidates.isEmpty) {
      for (final query in queries) {
        candidates = await _searchQuietly(title: query);
        if (candidates.isNotEmpty) {
          break;
        }
      }
    }
    final seed = BookDraft(
      localKey: _key(),
      isbn: isbn ?? '',
      title: recognized.isEmpty ? '' : titleFromRecognizedText(recognized),
      photoPaths: [photoPath],
      recognizedText: recognized,
    );
    if (candidates.isNotEmpty) {
      state = state.copyWith(error: null);
    }
    if (candidates.length == 1) {
      return _materialize(seed, candidates.single);
    }
    if (candidates.isEmpty) {
      state = state.copyWith(
        error: state.error ?? 'По фото в каталогах ничего не найдено.',
      );
    }
    return seed.copyWith(candidates: candidates);
  }

  Future<List<MetadataCandidate>> _searchQuietly({
    String? query,
    String? title,
    String? author,
    String? isbn,
  }) async {
    try {
      return await ref.read(metadataServiceProvider).search(
        query: query,
        title: title,
        author: author,
        isbn: isbn,
      );
    } catch (error) {
      state = state.copyWith(error: userFacingError(error));
      return const [];
    }
  }

  Future<String?> _isbnFromImage(String absolutePath) async {
    if (!deviceCaptureSupported) {
      return null;
    }
    final scanner = MobileScannerController();
    try {
      final capture = await scanner.analyzeImage(absolutePath);
      for (final barcode in capture?.barcodes ?? const <Barcode>[]) {
        final raw = barcode.rawValue;
        if (raw == null) {
          continue;
        }
        final isbn = isbnFromText(raw);
        if (isbn != null) {
          return isbn;
        }
      }
    } catch (_) {
      return null;
    } finally {
      await scanner.dispose();
    }
    return null;
  }

  Future<BookDraft> _materialize(
    BookDraft seed,
    MetadataCandidate candidate,
  ) async {
    final enriched = candidate;
    var coverPath = seed.coverPath;
    final coverUrl = enriched.coverUrl;
    if (coverUrl != null) {
      final bytes = await ref.read(metadataServiceProvider).download(
        Uri.parse(coverUrl),
      );
      if (bytes != null) {
        coverPath = await ref.read(imageStoreProvider).saveBytes(
          bytes,
          cover: true,
        );
      }
    }
    return seed.copyWith(
      title: enriched.title,
      subtitle: enriched.subtitle,
      description: enriched.description,
      isbn: enriched.isbn.isEmpty ? seed.isbn : enriched.isbn,
      authors: enriched.authors.isEmpty ? seed.authors : enriched.authors,
      genres: enriched.genres,
      publishers: enriched.publisher.trim().isEmpty
          ? seed.publishers
          : [enriched.publisher.trim()],
      sourceUrl: enriched.sourceUrl ?? seed.sourceUrl,
      seriesName: enriched.seriesName.trim().isEmpty
          ? seed.seriesName
          : enriched.seriesName.trim(),
      seriesVolume: enriched.seriesVolume ?? seed.seriesVolume,
      coverPath: coverPath,
      candidates: const [],
      format: catalogAudio(enriched) ? BookFormat.audio : seed.format,
      yandexId: catalogYandexId(seed, enriched),
      narrator: enriched.narrator.trim().isEmpty
          ? seed.narrator
          : enriched.narrator.trim(),
    );
  }

  void _replaceActive(BookDraft draft) {
    if (state.drafts.isEmpty) {
      state = state.copyWith(drafts: [draft], activeIndex: 0);
      return;
    }
    final drafts = [...state.drafts];
    final index = state.activeIndex.clamp(0, drafts.length - 1);
    drafts[index] = draft;
    state = state.copyWith(drafts: drafts, activeIndex: index);
  }

  String _key() => DateTime.now().microsecondsSinceEpoch.toString();
}

final captureControllerProvider =
    NotifierProvider<CaptureController, CaptureState>(CaptureController.new);
