import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_library/core/metadata/shelf_reading.dart';
import 'package:my_library/core/models/book_draft.dart';
import 'package:my_library/core/models/metadata_candidate.dart';
import 'package:my_library/core/models/shelf_model.dart';
import 'package:my_library/core/search/duplicates.dart';
import 'package:my_library/data/candidate_fill.dart';
import 'package:my_library/data/shelf_session_store.dart';
import 'package:my_library/features/capture/shelf_batch.dart';
import 'package:my_library/features/capture/shelf_mark_screen.dart';
import 'package:my_library/features/capture/spine_card_screen.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/candidate_sheet.dart';
import 'package:my_library/ui/common_widgets.dart';
import 'package:my_library/ui/location_picker.dart';
import 'package:my_library/ui/user_message.dart';

class ShelfProbeScreen extends ConsumerStatefulWidget {
  const ShelfProbeScreen({super.key});

  @override
  ConsumerState<ShelfProbeScreen> createState() => _ShelfProbeScreenState();
}

class _ShelfProbeScreenState extends ConsumerState<ShelfProbeScreen> {
  var _ready = false;
  var _consent = false;
  var _busy = false;
  var _choice = ShelfModelChoice.off;
  var _hasKimiKey = false;
  var _hasYandex = false;
  var _error = '';
  String? _photoPath;
  int? _shelfId;
  int? _rowId;
  List<RecognizedShelf> _shelves = const [];
  final _settled = <String, bool>{};
  final _matches = <String, List<DuplicateMatch>>{};
  final _duplicateSkips = <String>{};
  DateTime? _createdAt;
  var _stored = false;
  Future<void> _writes = Future<void>.value();
  var _matchGeneration = 0;

  bool get _modelReady {
    return switch (_choice) {
      ShelfModelChoice.off => false,
      ShelfModelChoice.kimi => _hasKimiKey,
      ShelfModelChoice.yandex => _hasYandex,
    };
  }

  bool get _placeReady => _shelfId != null && _rowId != null;

  ShelfPlace? get _place {
    final shelfId = _shelfId;
    final rowId = _rowId;
    if (shelfId == null || rowId == null) {
      return null;
    }
    return ShelfPlace(shelfId: shelfId, rowId: rowId);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repository = ref.read(libraryRepositoryProvider);
    final consent = await repository.kimiCloudConsent();
    final choice = await repository.shelfModel();
    final kimiKey = await repository.kimiApiKey();
    final yandexKey = await repository.yandexApiKey();
    final folder = await repository.yandexFolderId();
    final session = await _restoreSession();
    if (!mounted) {
      return;
    }
    setState(() {
      _consent = consent;
      _choice = choice;
      _hasKimiKey = kimiKey != null && kimiKey.trim().isNotEmpty;
      _hasYandex =
          yandexKey != null &&
          yandexKey.trim().isNotEmpty &&
          folder != null &&
          folder.trim().isNotEmpty;
      if (session != null) {
        _photoPath = session.photoPath;
        _shelfId = session.shelfId;
        _rowId = session.rowId;
        _shelves = session.shelves;
        _settled.addAll(session.settled);
        _createdAt = session.createdAt;
        _stored = true;
      }
      _ready = true;
    });
    if (session != null) {
      await _refreshMatches();
    }
  }

  Future<ShelfSession?> _restoreSession() async {
    try {
      final session = await ref.read(shelfSessionStoreProvider).load();
      if (session == null) {
        return null;
      }
      final options = await ref.read(locationOptionsProvider.future);
      final placeExists = options.any(
        (option) =>
            option.shelfId == session.shelfId &&
            option.rows.any((row) => row.id == session.rowId),
      );
      return placeExists ? session : session.copyWith(shelfId: null, rowId: null);
    } catch (_) {
      await ref.read(appLogProvider).write('Не удалось открыть прежний снимок полки');
      return null;
    }
  }

  /// Writes are chained so an older snapshot never overwrites a newer one.
  Future<ShelfSession?> _persist() {
    final store = ref.read(shelfSessionStoreProvider);
    final log = ref.read(appLogProvider);
    final container = ProviderScope.containerOf(context, listen: false);
    final photo = _photoPath;
    final keep = _shelves.isNotEmpty && _hasPending;
    final session = ShelfSession(
      shelfId: _shelfId,
      rowId: _rowId,
      photoPath: photo ?? '',
      shelves: _shelves,
      settled: Map.of(_settled),
      createdAt: _createdAt ??= DateTime.now(),
    );
    _stored = keep;
    final result = _writes.then((_) async {
      try {
        if (!keep) {
          await store.clear();
          return null;
        }
        return await store.save(session, sourcePhoto: photo);
      } catch (_) {
        await log.write('Не удалось записать снимок полки');
        return null;
      } finally {
        container.invalidate(shelfSessionProvider);
      }
    });
    _writes = result.then((_) {});
    return result;
  }

  Future<void> _forget() async {
    setState(() {
      _shelves = const [];
      _settled.clear();
      _matches.clear();
      _duplicateSkips.clear();
      _photoPath = null;
      _createdAt = null;
      _error = '';
    });
    await _persist();
  }

  Future<void> _confirmForget() async {
    final confirmed = await confirmDialog(
      context,
      title: 'Забыть снимок?',
      message:
          'Несохранённые книги с этого снимка будут забыты. Уже сохранённые останутся в библиотеке.',
      confirmLabel: 'Забыть',
    );
    if (confirmed && mounted) {
      await _forget();
    }
  }

  Future<void> _refreshMatches() async {
    final generation = ++_matchGeneration;
    final shelves = _shelves;
    final slots = <String>[];
    final drafts = <BookDraft>[];
    for (var shelf = 0; shelf < shelves.length; shelf++) {
      for (var index = 0; index < shelves[shelf].books.length; index++) {
        slots.add(_slot(shelf, index));
        drafts.add(_draftFor(shelves[shelf].books[index]));
      }
    }
    try {
      final found = await ref
          .read(libraryRepositoryProvider)
          .findDuplicatesFor(drafts);
      if (!mounted || generation != _matchGeneration) {
        return;
      }
      setState(() {
        _matches.clear();
        for (var i = 0; i < slots.length; i++) {
          if (found[i].isNotEmpty) {
            _matches[slots[i]] = found[i];
          }
        }
      });
    } catch (_) {
      if (mounted) {
        await ref.read(appLogProvider).write('Не удалось проверить дубли полки');
      }
    }
  }

  Future<void> _allow() async {
    await ref.read(libraryRepositoryProvider).setKimiCloudConsent(true);
    await ref.read(appLogProvider).write('Отправка фото полки разрешена');
    if (mounted) {
      setState(() => _consent = true);
    }
  }

  Future<void> _mark() async {
    final place = _place;
    if (place == null) {
      return;
    }
    final saved = _photoPath;
    final path = saved != null && File(saved).existsSync()
        ? saved
        : await _pickImage();
    if (path == null || !mounted) {
      return;
    }
    await context.push(
      '/add/shelf/mark',
      extra: ShelfMarkArgs(
        path: path,
        shelfId: place.shelfId,
        rowId: place.rowId,
      ),
    );
  }

  Future<String?> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Сделать фото'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text('Выбрать фото'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) {
      return null;
    }
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );
      return file?.path;
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Не удалось открыть фото.');
      }
      return null;
    }
  }

  Future<void> _pick() async {
    if (!_placeReady) {
      return;
    }
    if (_stored) {
      final confirmed = await confirmDialog(
        context,
        title: 'Начать новую полку?',
        message: 'Несохранённые книги с прошлого снимка будут забыты.',
        confirmLabel: 'Начать',
      );
      if (!confirmed || !mounted) {
        return;
      }
    }
    final path = await _pickImage();
    if (path == null || !mounted) {
      return;
    }
    if (_stored) {
      await _forget();
      if (!mounted) {
        return;
      }
    }
    _photoPath = path;
    try {
      await _recognize(await File(path).readAsBytes());
    } catch (error) {
      if (mounted) {
        setState(() => _error = userFacingError(error));
      }
    }
  }

  Future<void> _retry() async {
    final path = _photoPath;
    if (path == null || !File(path).existsSync()) {
      await _pick();
      return;
    }
    try {
      await _recognize(await File(path).readAsBytes());
    } catch (error) {
      if (mounted) {
        setState(() => _error = userFacingError(error));
      }
    }
  }

  Future<void> _recognize(Uint8List bytes) async {
    setState(() {
      _busy = true;
      _error = '';
      _shelves = const [];
    });
    try {
      final shelves = await switch (_choice) {
        ShelfModelChoice.off => throw StateError('Модель не выбрана'),
        ShelfModelChoice.kimi => _readKimi(bytes),
        ShelfModelChoice.yandex => _readYandex(bytes),
      };
      if (!mounted) {
        return;
      }
      final empty =
          shelves.isEmpty || shelves.every((shelf) => shelf.books.isEmpty);
      setState(() {
        _busy = false;
        _shelves = shelves;
        _settled.clear();
        _matches.clear();
        _duplicateSkips.clear();
        _createdAt = DateTime.now();
        _error = empty ? 'На фото не удалось прочитать корешки.' : '';
      });
      final stored = await _persist();
      if (stored != null && mounted) {
        setState(() => _photoPath = stored.photoPath);
      }
      if (mounted) {
        await _refreshMatches();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = userFacingError(error);
      });
    }
  }

  Future<List<RecognizedShelf>> _readKimi(Uint8List bytes) async {
    final key = await ref.read(libraryRepositoryProvider).kimiApiKey();
    if (key == null || key.trim().isEmpty) {
      throw StateError('Добавьте ключ Kimi в настройках.');
    }
    return ref.read(kimiShelfReaderProvider).read(jpeg: bytes, apiKey: key);
  }

  Future<List<RecognizedShelf>> _readYandex(Uint8List bytes) async {
    final repository = ref.read(libraryRepositoryProvider);
    final key = await repository.yandexApiKey();
    final folder = await repository.yandexFolderId();
    if (key == null ||
        key.trim().isEmpty ||
        folder == null ||
        folder.trim().isEmpty) {
      throw StateError('Добавьте ключ и каталог Яндекса в настройках.');
    }
    return ref
        .read(yandexShelfReaderProvider)
        .read(jpeg: bytes, apiKey: key, folderId: folder);
  }

  String _slot(int shelf, int index) => '$shelf:$index';

  bool get _hasPending {
    for (var shelf = 0; shelf < _shelves.length; shelf++) {
      for (var index = 0; index < _shelves[shelf].books.length; index++) {
        if (!_settled.containsKey(_slot(shelf, index))) {
          return true;
        }
      }
    }
    return false;
  }

  BookDraft _draftFor(RecognizedSpine spine, {int? shelfId, int? rowId}) {
    final author = spine.author.trim();
    return BookDraft(
      title: spine.title.trim(),
      authors: author.isEmpty ? const [] : [author],
      isbn: spine.isbn.trim(),
      shelfId: shelfId,
      rowId: rowId,
    );
  }

  Future<bool?> _openCard(RecognizedSpine spine, {int? shelfId, int? rowId}) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => SpineCardScreen(
          initial: _draftFor(spine, shelfId: shelfId, rowId: rowId),
          heading: spine.uncertain ? 'Чтение сомнительное' : 'Карточка книги',
        ),
      ),
    );
  }

  Future<void> _openOne(int shelf, int index) async {
    final place = _place;
    if (place == null) {
      return;
    }
    final result = await _openCard(
      _shelves[shelf].books[index],
      shelfId: place.shelfId,
      rowId: place.rowId,
    );
    if (!mounted || result == null) {
      return;
    }
    setState(() => _settled[_slot(shelf, index)] = result);
    unawaited(_persist());
    if (result) {
      await _refreshMatches();
    }
  }

  Future<void> _saveAll() async {
    final place = _place;
    if (place == null || !mounted) {
      return;
    }
    final tally = BatchTally();
    for (var shelf = 0; shelf < _shelves.length; shelf++) {
      final books = _shelves[shelf].books;
      for (var index = 0; index < books.length; index++) {
        if (!mounted) {
          return;
        }
        final slot = _slot(shelf, index);
        if (_settled.containsKey(slot)) {
          continue;
        }
        final outcome = await _saveBatchSpine(books[index], slot, place);
        if (!mounted || outcome == null) {
          return;
        }
        setState(() {
          _settled[slot] = spineSettledValue(outcome);
          if (outcome == SpineOutcome.duplicate) {
            _duplicateSkips.add(slot);
          }
        });
        unawaited(_persist());
        tally.add(outcome);
        if (outcome == SpineOutcome.saved) {
          await _refreshMatches();
        }
      }
    }
    if (mounted) {
      showMessage(context, tally.message);
    }
  }

  Future<SpineOutcome?> _saveBatchSpine(
    RecognizedSpine spine,
    String slot,
    ShelfPlace place,
  ) async {
    if (spine.uncertain || spine.title.trim().isEmpty) {
      final result = await _openCard(
        spine,
        shelfId: place.shelfId,
        rowId: place.rowId,
      );
      return result == true ? SpineOutcome.saved : SpineOutcome.skipped;
    }
    if (_matches[slot]?.isNotEmpty ?? false) {
      return SpineOutcome.duplicate;
    }
    setState(() => _busy = true);
    List<MetadataCandidate> results = const [];
    try {
      final isbn = spine.isbn.trim();
      results = await ref
          .read(metadataServiceProvider)
          .search(
            isbn: isbn.isEmpty ? null : isbn,
            title: spine.title.trim().length >= 2 ? spine.title.trim() : null,
            author: spine.author.trim().length >= 2
                ? spine.author.trim()
                : null,
          );
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        showMessage(context, userFacingError(error));
      }
      return null;
    }
    if (!mounted) {
      return null;
    }
    setState(() => _busy = false);
    final seed = _draftFor(spine, shelfId: place.shelfId, rowId: place.rowId);
    if (results.length > 1) {
      final chosen = await chooseMetadataCandidate(context, results);
      if (!mounted) {
        return null;
      }
      if (chosen == null) {
        return SpineOutcome.skipped;
      }
      return _storeCandidate(seed, chosen, place);
    }
    if (results.length == 1) {
      return _storeCandidate(seed, results.single, place);
    }
    return _storeDraft(seed);
  }

  Future<SpineOutcome> _storeCandidate(
    BookDraft seed,
    MetadataCandidate candidate,
    ShelfPlace place,
  ) async {
    setState(() => _busy = true);
    try {
      final filled = await fillDraftFromCandidate(
        seed: seed,
        candidate: candidate,
        metadata: ref.read(metadataServiceProvider),
        images: ref.read(imageStoreProvider),
      );
      if (!mounted) {
        return SpineOutcome.skipped;
      }
      return await _storeDraft(
        filled.copyWith(shelfId: place.shelfId, rowId: place.rowId),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        showMessage(context, userFacingError(error));
      }
      return SpineOutcome.skipped;
    }
  }

  /// Batch-only: a duplicate is skipped silently, without the dialog.
  Future<SpineOutcome> _storeDraft(BookDraft draft) async {
    if (draft.title.trim().isEmpty || !mounted) {
      return SpineOutcome.skipped;
    }
    setState(() => _busy = true);
    try {
      final repository = ref.read(libraryRepositoryProvider);
      final matches = await repository.findDuplicates(draft);
      if (matches.isNotEmpty) {
        return SpineOutcome.duplicate;
      }
      final id = await repository.createBook(draft);
      await ref
          .read(appLogProvider)
          .write('Книга сохранена', '«${draft.title}», id $id');
      return SpineOutcome.saved;
    } catch (error) {
      if (mounted) {
        showMessage(context, userFacingError(error));
      }
      return SpineOutcome.skipped;
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final failed = _error.isNotEmpty;
    final canCapture = !_busy && _placeReady;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Полка целиком'),
        actions: [
          if (_stored)
            PopupMenuButton<void>(
              enabled: !_busy,
              itemBuilder: (context) => [
                PopupMenuItem<void>(
                  onTap: _confirmForget,
                  child: const Text('Забыть снимок'),
                ),
              ],
            ),
        ],
      ),
      body: !_ready
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _placePicker(),
                    const SizedBox(height: 16),
                    Text(_intro()),
                    const SizedBox(height: 16),
                    if (_modelReady && !_consent) ...[
                      const Text(
                        'Чтобы отправить фото в выбранную модель, разрешите это здесь или в настройках. Без отправки корешки можно разметить чертами.',
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _allow,
                        child: const Text('Разрешить отправку фото'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: canCapture ? _mark : null,
                        child: const Text('Разметить корешки'),
                      ),
                    ] else if (_modelReady) ...[
                      FilledButton(
                        onPressed: canCapture ? _pick : null,
                        child: const Text('Сфотографировать полку'),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: canCapture ? _mark : null,
                        child: const Text('Разметить корешки'),
                      ),
                    ],
                    if (failed) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Тот же снимок можно разделить чертами. Каждый корешок ищется отдельно, фото остаётся на телефоне.',
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: canCapture ? _mark : null,
                        child: const Text('Разметить корешки'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: canCapture ? _retry : null,
                        child: const Text('Повторить'),
                      ),
                    ],
                    for (var shelf = 0; shelf < _shelves.length; shelf++) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Полка ${shelf + 1}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_shelves[shelf].books.isEmpty)
                        const Text('Корешки не прочитаны.')
                      else
                        for (
                          var index = 0;
                          index < _shelves[shelf].books.length;
                          index++
                        )
                          _SpineTile(
                            index: index,
                            spine: _shelves[shelf].books[index],
                            settled: _settled[_slot(shelf, index)],
                            matches:
                                _matches[_slot(shelf, index)] ?? const [],
                            duplicateSkip: _duplicateSkips.contains(
                              _slot(shelf, index),
                            ),
                            onSave: canCapture
                                ? () => _openOne(shelf, index)
                                : null,
                          ),
                      if (_hasPending) ...[
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: canCapture ? _saveAll : null,
                          child: const Text('Сохранить все'),
                        ),
                      ],
                    ],
                  ],
                ),
                if (_busy)
                  const ColoredBox(
                    color: Color(0x66000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
    );
  }

  Widget _placePicker() {
    final locations = ref.watch(locationOptionsProvider);
    return locations.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Text(userFacingError(error)),
      data: (options) => LocationPicker(
        options: options,
        shelfId: _shelfId,
        rowId: _rowId,
        onChanged: ({required shelfId, required rowId}) {
          setState(() {
            _shelfId = shelfId;
            _rowId = rowId;
          });
          if (_stored) {
            unawaited(_persist());
          }
        },
      ),
    );
  }

  String _intro() {
    return switch (_choice) {
      ShelfModelChoice.off => 'Модели выключены. Проведите черты по промежуткам между корешками: каждый будет искаться отдельно, снимок останется на телефоне.',
      ShelfModelChoice.kimi when !_hasKimiKey => 'Ключ Kimi не задан. Проведите черты по промежуткам между корешками: каждый будет искаться отдельно, снимок останется на телефоне.',
      ShelfModelChoice.yandex when !_hasYandex => 'Для Яндекса нужны ключ и идентификатор каталога. Без них корешки размечаются чертами, снимок остаётся на телефоне.',
      ShelfModelChoice.kimi => 'Снимок уходит в Kimi. Прочитанные книги можно сохранить по одной или все сразу.',
      ShelfModelChoice.yandex => 'Снимок уходит в модель Яндекса. Прочитанные книги можно сохранить по одной или все сразу.',
    };
  }
}

class _SpineTile extends StatelessWidget {
  const _SpineTile({
    required this.index,
    required this.spine,
    required this.settled,
    required this.matches,
    required this.duplicateSkip,
    required this.onSave,
  });

  final int index;
  final RecognizedSpine spine;
  final bool? settled;
  final List<DuplicateMatch> matches;
  final bool duplicateSkip;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final author = spine.author.isEmpty ? '' : ' — ${spine.author}';
    final title = spine.title.isEmpty ? 'Без названия' : spine.title;
    final note = switch (settled) {
      true => 'Сохранено',
      false when duplicateSkip => 'Пропущено: уже в библиотеке',
      false => 'Пропущено',
      null when matches.isNotEmpty =>
        'Уже в библиотеке: ${duplicateReasonLabel(matches.first.reason)}\n${matches.first.locationPath}',
      null when spine.uncertain => 'Чтение сомнительное',
      null => null,
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${index + 1}. $title$author'),
      subtitle: note == null ? null : Text(note),
      trailing: settled == null
          ? TextButton(onPressed: onSave, child: const Text('Сохранить'))
          : null,
      onTap: settled == null ? onSave : null,
    );
  }
}

class ShelfPlace {
  const ShelfPlace({required this.shelfId, required this.rowId});

  final int shelfId;
  final int rowId;
}
