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
import 'package:my_library/data/candidate_fill.dart';
import 'package:my_library/features/capture/shelf_mark_screen.dart';
import 'package:my_library/features/capture/spine_card_screen.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/candidate_sheet.dart';
import 'package:my_library/ui/common_widgets.dart';
import 'package:my_library/ui/duplicate_prompt.dart';
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
      _ready = true;
    });
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
    final path = await _pickImage();
    if (path == null || !mounted) {
      return;
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
        _error = empty ? 'На фото не удалось прочитать корешки.' : '';
      });
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
  }

  Future<void> _saveAll() async {
    final place = _place;
    if (place == null || !mounted) {
      return;
    }
    var saved = 0;
    var skipped = 0;
    for (var shelf = 0; shelf < _shelves.length; shelf++) {
      final books = _shelves[shelf].books;
      for (var index = 0; index < books.length; index++) {
        if (!mounted) {
          return;
        }
        if (_settled.containsKey(_slot(shelf, index))) {
          continue;
        }
        final spine = books[index];
        final kept = await _saveBatchSpine(spine, place);
        if (!mounted) {
          return;
        }
        if (kept == null) {
          return;
        }
        setState(() => _settled[_slot(shelf, index)] = kept);
        if (kept) {
          saved += 1;
        } else {
          skipped += 1;
        }
      }
    }
    if (mounted) {
      showMessage(context, 'Сохранено $saved, пропущено $skipped.');
    }
  }

  Future<bool?> _saveBatchSpine(RecognizedSpine spine, ShelfPlace place) async {
    if (spine.uncertain || spine.title.trim().isEmpty) {
      final result = await _openCard(
        spine,
        shelfId: place.shelfId,
        rowId: place.rowId,
      );
      return result ?? false;
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
        return false;
      }
      return _storeCandidate(seed, chosen, place);
    }
    if (results.length == 1) {
      return _storeCandidate(seed, results.single, place);
    }
    return _storeDraft(seed);
  }

  Future<bool> _storeCandidate(
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
        return false;
      }
      return await _storeDraft(
        filled.copyWith(shelfId: place.shelfId, rowId: place.rowId),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        showMessage(context, userFacingError(error));
      }
      return false;
    }
  }

  Future<bool> _storeDraft(BookDraft draft) async {
    if (mounted) {
      setState(() => _busy = false);
    }
    if (draft.title.trim().isEmpty || !mounted) {
      return false;
    }
    final allowed = await confirmDuplicates(context, ref, [draft]);
    if (!allowed || !mounted) {
      return false;
    }
    setState(() => _busy = true);
    try {
      final id = await ref.read(libraryRepositoryProvider).createBook(draft);
      await ref
          .read(appLogProvider)
          .write('Книга сохранена', '«${draft.title}», id $id');
      return true;
    } catch (error) {
      if (mounted) {
        showMessage(context, userFacingError(error));
      }
      return false;
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
      appBar: AppBar(title: const Text('Полка целиком')),
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
    required this.onSave,
  });

  final int index;
  final RecognizedSpine spine;
  final bool? settled;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final author = spine.author.isEmpty ? '' : ' — ${spine.author}';
    final title = spine.title.isEmpty ? 'Без названия' : spine.title;
    final note = switch (settled) {
      true => 'Сохранено',
      false => 'Пропущено',
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
