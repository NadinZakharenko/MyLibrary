import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_library/core/isbn.dart';
import 'package:my_library/core/metadata/shelf_image.dart';
import 'package:my_library/core/metadata/shelf_reading.dart';
import 'package:my_library/core/metadata/spine_slices.dart';
import 'package:my_library/data/shelf_model_client.dart';
import 'package:my_library/core/models/book_draft.dart';
import 'package:my_library/core/models/metadata_candidate.dart';
import 'package:my_library/core/platform_support.dart';
import 'package:my_library/data/candidate_fill.dart';
import 'package:my_library/features/books/book_editor.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/candidate_sheet.dart';
import 'package:my_library/ui/common_widgets.dart';
import 'package:my_library/ui/duplicate_prompt.dart';
import 'package:my_library/ui/user_message.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum _ShelfStep { mark, preview, read, choose, edit, done }

class ShelfMarkArgs {
  const ShelfMarkArgs({
    required this.path,
    required this.shelfId,
    required this.rowId,
  });

  final String path;
  final int shelfId;
  final int rowId;
}

class ShelfMarkScreen extends ConsumerStatefulWidget {
  const ShelfMarkScreen({
    super.key,
    required this.imagePath,
    required this.shelfId,
    required this.rowId,
  });

  final String imagePath;
  final int shelfId;
  final int rowId;

  @override
  ConsumerState<ShelfMarkScreen> createState() => _ShelfMarkScreenState();
}

class _ShelfMarkScreenState extends ConsumerState<ShelfMarkScreen> {
  final _transform = TransformationController();
  img.Image? _decoded;
  Uint8List? _jpeg;
  Directory? _temp;
  var _cuts = <int>[];
  int? _selected;
  var _move = false;
  var _dragIndex = -1;
  var _step = _ShelfStep.mark;
  var _busy = false;
  var _error = '';
  var _narrow = 0;
  var _strips = <File>[];
  var _index = 0;
  var _saved = 0;
  var _skipped = 0;
  var _candidates = <MetadataCandidate>[];
  BookDraft? _draft;
  String? _imported;
  var _modelFailed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    final imported = _imported;
    if (imported != null) {
      ref.read(imageStoreProvider).deleteRelative(imported);
    }
    final temp = _temp;
    if (temp != null) {
      temp.delete(recursive: true).ignore();
    }
    _transform.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final raw = await File(widget.imagePath).readAsBytes();
      final jpeg = downscaleJpeg(raw);
      final decoded = img.decodeImage(jpeg);
      if (decoded == null) {
        throw const ShelfImageException('Не удалось прочитать фото.');
      }
      final cache = await getTemporaryDirectory();
      final temp = Directory(p.join(cache.path, 'my_library_spines'));
      if (await temp.exists()) {
        await temp.delete(recursive: true);
      }
      await temp.create(recursive: true);
      if (!mounted) {
        return;
      }
      setState(() {
        _jpeg = jpeg;
        _decoded = decoded;
        _temp = temp;
      });
    } on ShelfImageException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Не удалось открыть фото.');
      }
    }
  }

  Future<void> _preview() async {
    final decoded = _decoded;
    final temp = _temp;
    if (decoded == null || temp == null) {
      return;
    }
    if (_cuts.isEmpty) {
      showMessage(context, 'Поставьте хотя бы одну черту между корешками.');
      return;
    }
    setState(() => _busy = true);
    for (final file in _strips) {
      if (await file.exists()) {
        await file.delete();
      }
    }
    final slices = spineSlices(width: decoded.width, cuts: _cuts);
    final strips = <File>[];
    for (var index = 0; index < slices.length; index++) {
      final file = File(p.join(temp.path, 'spine_$index.jpg'));
      await file.writeAsBytes(
        encodeSpineJpeg(decoded, slices[index], SpineTurn.upright),
        flush: true,
      );
      strips.add(file);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _strips = strips;
      _narrow = narrowSpineGaps(width: decoded.width, cuts: _cuts);
      _busy = false;
      _step = _ShelfStep.preview;
    });
  }

  Future<void> _startSearch() async {
    if (_strips.isEmpty) {
      return;
    }
    await ref
        .read(appLogProvider)
        .write('полка размечена', 'корешков ${_strips.length}');
    if (!mounted) {
      return;
    }
    setState(() {
      _index = 0;
      _saved = 0;
      _skipped = 0;
    });
    await _readCurrent();
  }

  Future<void> _readCurrent() async {
    if (_index < 0 || _index >= _strips.length) {
      setState(() => _step = _ShelfStep.done);
      return;
    }
    setState(() {
      _busy = true;
      _step = _ShelfStep.read;
      _error = '';
      _candidates = const [];
      _draft = null;
    });
    final modelBook = await _readModel(_strips[_index]);
    if (!mounted) {
      return;
    }
    final text = modelBook == null ? await _recognize(_strips[_index]) : '';
    if (!mounted) {
      return;
    }
    final cleaned = readableSpineText(text);
    final isbn = modelBook == null
        ? isbnFromText(cleaned)
        : await _isbnFromStrip(_strips[_index]);
    final query = spineSearchQuery(cleaned);
    final titleQuery = modelBook != null
        ? modelBook.title
        : (cyrillicLetters(query) >= 2 ? query : '');
    final authorQuery = modelBook?.author ?? '';
    var candidates = <MetadataCandidate>[];
    try {
      if (isbn != null) {
        candidates = await ref
            .read(metadataServiceProvider)
            .search(
              isbn: isbn,
              title: titleQuery.length >= 2 ? titleQuery : null,
              author: authorQuery.length >= 2 ? authorQuery : null,
            );
      } else if (titleQuery.length >= 2 || authorQuery.length >= 2) {
        candidates = await ref
            .read(metadataServiceProvider)
            .search(
              title: titleQuery.length >= 2 ? titleQuery : null,
              author: authorQuery.length >= 2 ? authorQuery : null,
            );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = userFacingError(error));
      }
    }
    if (!mounted) {
      return;
    }
    final shown = _clip(cleaned, 400);
    var draft = modelBook == null
        ? BookDraft(
            title: cyrillicLetters(shown) >= 3 ? _clip(shown, 120) : '',
            isbn: isbn ?? '',
            recognizedText: shown,
            shelfId: widget.shelfId,
            rowId: widget.rowId,
          )
        : BookDraft(
            title: modelBook.title,
            authors: modelBook.author.trim().isEmpty
                ? const []
                : [modelBook.author.trim()],
            isbn: isbn ?? '',
            shelfId: widget.shelfId,
            rowId: widget.rowId,
          );
    if (candidates.isEmpty) {
      draft = await _copySpine(draft);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _draft = draft;
      _candidates = candidates;
      _step = candidates.isEmpty ? _ShelfStep.edit : _ShelfStep.choose;
    });
  }

  Future<RecognizedSpine?> _readModel(File strip) async {
    if (_modelFailed) {
      return null;
    }
    final connection = await ref
        .read(libraryRepositoryProvider)
        .shelfConnection();
    if (!connection.canReadPhoto) {
      return null;
    }
    try {
      return await readShelfSpine(
        connection: connection,
        jpeg: await strip.readAsBytes(),
        kimi: ref.read(kimiShelfReaderProvider),
        yandex: ref.read(yandexShelfReaderProvider),
      );
    } catch (error) {
      _modelFailed = true;
      if (mounted) {
        setState(() => _error = userFacingError(error));
      }
      return null;
    }
  }

  Future<String?> _isbnFromStrip(File strip) async {
    if (!deviceCaptureSupported) {
      return null;
    }
    final scanner = MobileScannerController();
    try {
      final capture = await scanner.analyzeImage(strip.path);
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

  Future<String> _recognize(File strip) async {
    if (!deviceCaptureSupported) {
      return '';
    }
    final decoded = img.decodeImage(await strip.readAsBytes());
    final temp = _temp;
    if (decoded == null || temp == null) {
      return '';
    }
    final readings = <SpineReading>[];
    var loggedFailure = false;
    for (final turn in SpineTurn.values) {
      final path = p.join(temp.path, 'turn_${turn.name}.jpg');
      final file = File(path);
      try {
        await file.writeAsBytes(
          encodeSpineJpeg(
            decoded,
            SpineSlice(left: 0, right: decoded.width),
            turn,
          ),
          flush: true,
        );
        final recognizer = ref.read(spineScriptRecognizerProvider);
        final line = await recognizer.recognizeFile(path, psm: '7');
        final text = spineReadingScore(line) > 0
            ? line
            : await recognizer.recognizeFile(path, psm: '6');
        readings.add(SpineReading(text: text, turn: turn));
      } catch (error) {
        if (!loggedFailure) {
          loggedFailure = true;
          await ref
              .read(appLogProvider)
              .write('Ошибка распознавания корешка', userFacingError(error));
        }
      } finally {
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    return pickSpineReading(readings).text;
  }

  Future<void> _choose(MetadataCandidate candidate) async {
    final seed = _draft;
    if (seed == null || _busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final filled = await fillDraftFromCandidate(
        seed: seed,
        candidate: candidate,
        metadata: ref.read(metadataServiceProvider),
        images: ref.read(imageStoreProvider),
      );
      final withPhoto = await _copySpine(filled);
      if (!mounted) {
        return;
      }
      setState(() {
        _draft = withPhoto;
        _busy = false;
        _step = _ShelfStep.edit;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _busy = false);
      showMessage(context, userFacingError(error));
    }
  }

  Future<BookDraft> _copySpine(BookDraft draft) async {
    if (_imported != null) {
      return draft.copyWith(photoPaths: [_imported!, ...draft.photoPaths]);
    }
    if (_index < 0 || _index >= _strips.length) {
      return draft;
    }
    final images = ref.read(imageStoreProvider);
    final bytes = await _strips[_index].readAsBytes();
    final relative = await images.saveBytes(bytes, cover: false);
    if (!mounted) {
      await images.deleteRelative(relative);
      return draft;
    }
    _imported = relative;
    return draft.copyWith(photoPaths: [relative, ...draft.photoPaths]);
  }

  Future<void> _save(BookDraft edited) async {
    final allowed = await confirmDuplicates(context, ref, [edited]);
    if (!allowed || !mounted) {
      return;
    }
    try {
      final id = await ref.read(libraryRepositoryProvider).createBook(edited);
      _imported = null;
      await ref
          .read(appLogProvider)
          .write('Книга сохранена', '«${edited.title}», id $id');
      if (!mounted) {
        return;
      }
      setState(() => _saved += 1);
      await _advance();
    } catch (error) {
      if (mounted) {
        showMessage(context, userFacingError(error));
      }
    }
  }

  Future<void> _skip() async {
    if (_busy) {
      return;
    }
    final imported = _imported;
    _imported = null;
    if (imported != null) {
      await ref.read(imageStoreProvider).deleteRelative(imported);
    }
    await ref
        .read(appLogProvider)
        .write('Корешок пропущен', 'номер ${_index + 1}');
    if (!mounted) {
      return;
    }
    setState(() => _skipped += 1);
    await _advance();
  }

  Future<void> _advance() async {
    final next = _index + 1;
    if (!mounted) {
      return;
    }
    if (next >= _strips.length) {
      setState(() {
        _index = next;
        _step = _ShelfStep.done;
        _draft = null;
        _candidates = const [];
      });
      return;
    }
    setState(() => _index = next);
    await _readCurrent();
  }

  Future<void> _removeStrip(int index) async {
    final file = _strips[index];
    if (await file.exists()) {
      await file.delete();
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _strips = [
        for (var i = 0; i < _strips.length; i++)
          if (i != index) _strips[i],
      ];
    });
  }

  String _clip(String text, int max) {
    final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (flat.length <= max) {
      return flat;
    }
    return flat.substring(0, max);
  }

  int _imageX(double localX, double scaleX) {
    return (localX * scaleX).round();
  }

  double _slop(double scaleX) {
    final viewScale = math.max(_transform.value.getMaxScaleOnAxis(), 0.1);
    return 28 / viewScale * scaleX;
  }

  int? _nearest(int x, {required double slop}) {
    int? index;
    var best = slop;
    for (var i = 0; i < _cuts.length; i++) {
      final distance = (_cuts[i] - x).abs().toDouble();
      if (distance <= best) {
        best = distance;
        index = i;
      }
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    final decoded = _decoded;
    if (_error.isNotEmpty && decoded == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Полка целиком')),
        body: Center(child: Text(_error)),
      );
    }
    if (decoded == null || _jpeg == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return switch (_step) {
      _ShelfStep.mark => _markScaffold(decoded),
      _ShelfStep.preview => _previewScaffold(),
      _ShelfStep.read => _waitScaffold(
        'Читаем корешок ${_index + 1} из ${_strips.length}',
      ),
      _ShelfStep.choose => _chooseScaffold(),
      _ShelfStep.edit => _editScaffold(),
      _ShelfStep.done => _doneScaffold(),
    };
  }

  Widget _markScaffold(img.Image decoded) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Черты между корешками'),
        actions: [
          IconButton(
            tooltip: 'Отменить последнюю',
            onPressed: _cuts.isEmpty
                ? null
                : () => setState(() {
                    _cuts = _cuts.sublist(0, _cuts.length - 1);
                    _selected = null;
                  }),
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            tooltip: 'Убрать выбранную черту',
            onPressed: _selected == null
                ? null
                : () => setState(() {
                    final selected = _selected!;
                    _cuts = [
                      for (var i = 0; i < _cuts.length; i++)
                        if (i != selected) _cuts[i],
                    ];
                    _selected = null;
                  }),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Проведите черту по промежутку между корешками. «Сдвиг» двигает и увеличивает снимок.',
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final displayWidth = constraints.maxWidth;
                final displayHeight =
                    displayWidth * decoded.height / decoded.width;
                final scaleX = decoded.width / displayWidth;
                return InteractiveViewer(
                  transformationController: _transform,
                  panEnabled: _move,
                  scaleEnabled: _move,
                  minScale: 1,
                  maxScale: 6,
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: _move
                        ? null
                        : (event) {
                            final x = _imageX(event.localPosition.dx, scaleX);
                            final near = _nearest(x, slop: _slop(scaleX));
                            if (near != null) {
                              _dragIndex = near;
                              setState(() => _selected = near);
                              return;
                            }
                            if (x <= 0 || x >= decoded.width) {
                              _dragIndex = -1;
                              return;
                            }
                            setState(() {
                              _cuts = [..._cuts, x];
                              _selected = _cuts.length - 1;
                              _dragIndex = _selected!;
                            });
                          },
                    onPointerMove: _move
                        ? null
                        : (event) {
                            if (_dragIndex < 0 || _dragIndex >= _cuts.length) {
                              return;
                            }
                            final x = _imageX(
                              event.localPosition.dx,
                              scaleX,
                            ).clamp(1, decoded.width - 1);
                            setState(() => _cuts[_dragIndex] = x);
                          },
                    onPointerUp: _move ? null : (_) => _dragIndex = -1,
                    child: SizedBox(
                      width: displayWidth,
                      height: displayHeight,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(_jpeg!, fit: BoxFit.fill),
                          CustomPaint(
                            painter: _CutPainter(
                              cuts: _cuts,
                              selected: _selected,
                              scaleX: scaleX,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() => _move = !_move),
                    child: Text(_move ? 'Черты' : 'Сдвиг'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy ? null : _preview,
                      child: Text(_busy ? 'Готовим…' : 'Дальше'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewScaffold() {
    return Scaffold(
      appBar: AppBar(title: const Text('Корешки')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _narrow > 0
                  ? 'Корешков: ${_strips.length}. Слишком узкие промежутки пропущены. Лишнее можно убрать.'
                  : 'Корешков: ${_strips.length}. Лишнее можно убрать, затем искать по очереди.',
            ),
          ),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _strips.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Expanded(
                      child: Image.file(_strips[index], fit: BoxFit.contain),
                    ),
                    IconButton(
                      tooltip: 'Убрать корешок',
                      onPressed: () => _removeStrip(index),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() => _step = _ShelfStep.mark),
                    child: const Text('К чертам'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _strips.isEmpty ? null : _startSearch,
                      child: const Text('Искать'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _waitScaffold(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          if (_index >= 0 && _index < _strips.length)
            Expanded(child: Image.file(_strips[_index], fit: BoxFit.contain)),
          const Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _chooseScaffold() {
    final draft = _draft;
    return Scaffold(
      appBar: AppBar(title: Text('Корешок ${_index + 1} из ${_strips.length}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_index >= 0 && _index < _strips.length)
            SizedBox(
              height: 180,
              child: Image.file(_strips[_index], fit: BoxFit.contain),
            ),
          const SizedBox(height: 12),
          const Text(
            'Выберите издание. Один вариант тоже нужно подтвердить. Книга сохранится только с карточки.',
          ),
          if (draft != null && draft.recognizedText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Прочитано: ${draft.recognizedText}'),
          ],
          const SizedBox(height: 12),
          for (final candidate in _candidates)
            Card(
              child: MetadataCandidateTile(
                candidate: candidate,
                onTap: _busy ? null : () => _choose(candidate),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy
                ? null
                : () async {
                    final seed = _draft;
                    if (seed == null) {
                      return;
                    }
                    setState(() => _busy = true);
                    final withPhoto = await _copySpine(seed);
                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      _draft = withPhoto;
                      _busy = false;
                      _step = _ShelfStep.edit;
                    });
                  },
            child: const Text('Заполнить вручную'),
          ),
          TextButton(
            onPressed: _busy ? null : _skip,
            child: const Text('Пропустить'),
          ),
          if (_busy) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  Widget _editScaffold() {
    final draft = _draft;
    if (draft == null) {
      return _waitScaffold('Готовим карточку');
    }
    return BookEditor(
      key: ValueKey('spine-$_index-${draft.title}'),
      initial: draft.copyWith(shelfId: widget.shelfId, rowId: widget.rowId),
      heading: 'Корешок ${_index + 1} из ${_strips.length}',
      onSkip: _skip,
      onSave: _save,
    );
  }

  Widget _doneScaffold() {
    return Scaffold(
      appBar: AppBar(title: const Text('Полка готова')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Сохранено: $_saved. Пропущено: $_skipped.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Готово'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CutPainter extends CustomPainter {
  const _CutPainter({
    required this.cuts,
    required this.selected,
    required this.scaleX,
    required this.color,
  });

  final List<int> cuts;
  final int? selected;
  final double scaleX;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (var index = 0; index < cuts.length; index++) {
      final x = cuts[index] / scaleX;
      final selectedLine = index == selected;
      final paint = Paint()
        ..color = selectedLine ? color : const Color(0xCCFFFFFF)
        ..strokeWidth = selectedLine ? 3 : 2;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CutPainter oldDelegate) => true;
}
