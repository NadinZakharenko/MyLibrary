import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_library/core/format/russian_plural.dart';
import 'package:my_library/core/isbn.dart';
import 'package:my_library/core/models/book_copy.dart';
import 'package:my_library/data/candidate_fill.dart';
import 'package:my_library/core/metadata/rsl.dart';
import 'package:my_library/core/metadata/spine_slices.dart';
import 'package:my_library/core/models/book_draft.dart';
import 'package:my_library/features/books/book_note_field.dart';
import 'package:my_library/core/models/dictionary_kind.dart';
import 'package:my_library/core/models/reading_status.dart';
import 'package:my_library/core/platform_support.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/candidate_sheet.dart';
import 'package:my_library/ui/common_widgets.dart';
import 'package:my_library/ui/open_url.dart';
import 'package:my_library/ui/dictionary_chips.dart';
import 'package:my_library/ui/location_picker.dart';
import 'package:my_library/ui/user_message.dart';

class BookEditor extends ConsumerStatefulWidget {
  const BookEditor({
    super.key,
    required this.initial,
    required this.onSave,
    this.onSkip,
    this.heading = 'Карточка книги',
    this.lookupOnOpen = false,
  });

  final BookDraft initial;
  final Future<void> Function(BookDraft draft) onSave;
  final Future<void> Function()? onSkip;
  final String heading;
  final bool lookupOnOpen;

  @override
  ConsumerState<BookEditor> createState() => _BookEditorState();
}

class _BookEditorState extends ConsumerState<BookEditor> {
  late BookDraft _draft = widget.initial;
  late final TextEditingController _title = TextEditingController(
    text: widget.initial.title,
  );
  late final TextEditingController _subtitle = TextEditingController(
    text: widget.initial.subtitle,
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.initial.description,
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.initial.personalNote,
  );
  late final TextEditingController _isbn = TextEditingController(
    text: widget.initial.isbn,
  );
  late final TextEditingController _sourceUrl = TextEditingController(
    text: widget.initial.sourceUrl,
  );
  late final TextEditingController _series = TextEditingController(
    text: widget.initial.seriesName,
  );
  late final TextEditingController _volume = TextEditingController(
    text: widget.initial.seriesVolume?.toString() ?? '',
  );
  late final TextEditingController _loanPerson = TextEditingController(
    text: widget.initial.loanPerson,
  );
  late final TextEditingController _narrator = TextEditingController(
    text: widget.initial.narrator,
  );
  late final TextEditingController _duration = TextEditingController(
    text: widget.initial.durationSeconds == null
        ? ''
        : '${(widget.initial.durationSeconds! / 60).round()}',
  );
  var _saving = false;
  var _chooseShelf = false;
  var _lookingUp = false;
  var _scanningIsbn = false;
  var _leaving = false;
  var _textChanged = false;
  late final BookDraft _baseline;
  late final List<(TextEditingController, String)> _initialTexts;

  @override
  void initState() {
    super.initState();
    _chooseShelf = _draft.shelfId != null;
    if (_draft.statusChangedAt == null) {
      _draft = _draft.copyWith(statusChangedAt: _today());
    }
    _baseline = _draft;
    _initialTexts = [
      for (final controller in [
        _title,
        _subtitle,
        _description,
        _note,
        _isbn,
        _sourceUrl,
        _series,
        _volume,
        _loanPerson,
        _narrator,
        _duration,
      ])
        (controller, controller.text),
    ];
    for (final (controller, _) in _initialTexts) {
      controller.addListener(_onTextChanged);
    }
    if (widget.lookupOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final title = _title.text.trim();
        final author = _draft.authors
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .join(' ');
        if (isbnFromText(_isbn.text) == null &&
            title.length < 2 &&
            author.length < 2) {
          return;
        }
        _lookupCatalog();
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _description.dispose();
    _note.dispose();
    _isbn.dispose();
    _sourceUrl.dispose();
    _series.dispose();
    _volume.dispose();
    _loanPerson.dispose();
    _narrator.dispose();
    _duration.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final changed = _initialTexts.any((entry) => entry.$1.text != entry.$2);
    if (changed != _textChanged && mounted) {
      setState(() => _textChanged = changed);
    }
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _pickLibraryDue() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.libraryDueAt ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ru'),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _draft = _draft.copyWith(libraryDueAt: picked));
  }

  Future<void> _pickDate({required bool loan}) async {
    final initial = loan
        ? (_draft.loanDueAt ?? DateTime.now())
        : (_draft.statusChangedAt ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1970),
      lastDate: DateTime(DateTime.now().year + 20),
      locale: const Locale('ru'),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _draft = loan
          ? _draft.copyWith(loanDueAt: picked)
          : _draft.copyWith(statusChangedAt: picked);
    });
  }

  Future<void> _save() async {
    final volumeText = _volume.text.trim();
    int? volume;
    if (volumeText.isNotEmpty) {
      volume = int.tryParse(volumeText);
      if (volume == null || volume < 1) {
        showMessage(context, 'Номер тома — целое число больше нуля.');
        return;
      }
    }
    final draft = _current(volume);
    if (draft.title.trim().isEmpty) {
      showMessage(context, 'Укажите название');
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSave(draft);
    } catch (error) {
      if (mounted) {
        showMessage(context, userFacingError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  BookDraft _current(int? volume) {
    return _draft.copyWith(
      title: _title.text,
      subtitle: _subtitle.text,
      description: _description.text,
      personalNote: _note.text,
      isbn: _isbn.text,
      sourceUrl: _sourceUrl.text,
      seriesName: _series.text,
      seriesVolume: volume,
      loanPerson: _loanPerson.text,
      narrator: _narrator.text,
      durationSeconds: _minutes(_duration.text),
    ).prepared();
  }

  int? _minutes(String raw) {
    final minutes = int.tryParse(raw.trim());
    if (minutes == null || minutes <= 0) {
      return null;
    }
    return minutes * 60;
  }

  Future<void> _lookupCatalog() async {
    final isbn = isbnFromText(_isbn.text);
    final title = _title.text.trim();
    final author = _draft.authors
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .join(' ');
    if (isbn == null && title.length < 2 && author.length < 2) {
      showMessage(context, 'Заполните название, автора или ISBN.');
      return;
    }
    setState(() => _lookingUp = true);
    await ref.read(appLogProvider).write(
      'Поиск из карточки',
      [
        if (isbn != null) 'ISBN $isbn',
        if (title.isNotEmpty) '«$title»',
        if (author.isNotEmpty) author,
      ].join(', '),
    );
    try {
      final results = await ref.read(metadataServiceProvider).search(
        isbn: isbn,
        title: title.length >= 2 ? title : null,
        author: author.length >= 2 ? author : null,
        format: _draft.format,
      );
      if (!mounted) {
        return;
      }
      if (results.isEmpty) {
        await ref.read(appLogProvider).write('Каталог пуст');
        if (!mounted) {
          return;
        }
        final page = rslSearchUri(
          isbn: isbn,
          title: title.length >= 2 ? title : '',
          author: author.length >= 2 ? author : '',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('В каталогах ничего не найдено.'),
            action: SnackBarAction(
              label: 'Открыть страницу',
              onPressed: () => openExternalPage(context, page.toString()),
            ),
          ),
        );
        return;
      }
      final chosen = results.length == 1
          ? results.single
          : await chooseMetadataCandidate(context, results);
      if (chosen == null || !mounted) {
        return;
      }
      final enriched = chosen;
      var coverPath = _draft.coverPath;
      final coverUrl = enriched.coverUrl;
      if (coverUrl != null && (coverPath == null || coverPath.isEmpty)) {
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
      if (!mounted) {
        return;
      }
      _title.text = enriched.title;
      _subtitle.text = enriched.subtitle;
      _description.text = enriched.description;
      if (enriched.isbn.isNotEmpty) {
        _isbn.text = enriched.isbn;
      }
      if (enriched.sourceUrl != null) {
        _sourceUrl.text = enriched.sourceUrl!;
      }
      if (enriched.seriesName.isNotEmpty) {
        _series.text = enriched.seriesName;
      }
      if (enriched.seriesVolume != null) {
        _volume.text = '${enriched.seriesVolume}';
      }
      if (enriched.narrator.trim().isNotEmpty) {
        _narrator.text = enriched.narrator.trim();
      }
      setState(() {
        _draft = _draft.copyWith(
          authors: enriched.authors,
          genres: enriched.genres,
          publishers: enriched.publisher.trim().isEmpty
              ? _draft.publishers
              : [enriched.publisher.trim()],
          seriesName: enriched.seriesName.isEmpty
              ? _draft.seriesName
              : enriched.seriesName,
          seriesVolume: enriched.seriesVolume ?? _draft.seriesVolume,
          coverPath: coverPath,
          format: catalogAudio(enriched) ? BookFormat.audio : _draft.format,
          yandexId: catalogYandexId(_draft, enriched),
          narrator: _narrator.text,
        );
      });
      await ref.read(appLogProvider).write(
        'Карточка заполнена',
        '«${enriched.title}»',
      );
      if (!mounted) {
        return;
      }
      showMessage(context, 'Карточка заполнена из каталога. Проверьте поля.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      await ref.read(appLogProvider).write(
        'Ошибка поиска',
        userFacingError(error),
      );
      if (!mounted) {
        return;
      }
      showMessage(context, userFacingError(error));
    } finally {
      if (mounted) {
        setState(() => _lookingUp = false);
      }
    }
  }

  Future<void> _scanIsbn() async {
    if (_saving || _lookingUp || _scanningIsbn) {
      return;
    }
    setState(() => _scanningIsbn = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (file == null || !mounted) {
        return;
      }
      final isbn = await _readIsbnFromPhoto(file.path);
      if (!mounted) {
        return;
      }
      if (isbn == null) {
        showMessage(context, 'ISBN на снимке не найден.');
        return;
      }
      _isbn.text = isbn;
      setState(() => _scanningIsbn = false);
      await _lookupCatalog();
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Не удалось получить изображение.');
      }
    } finally {
      if (mounted && _scanningIsbn) {
        setState(() => _scanningIsbn = false);
      }
    }
  }

  Future<String?> _readIsbnFromPhoto(String absolutePath) async {
    final scanned = await _isbnFromImage(absolutePath);
    if (scanned != null) {
      return scanned;
    }
    if (!deviceCaptureSupported) {
      return null;
    }
    var latin = '';
    var russian = '';
    try {
      latin =
          await ref.read(coverTextRecognizerProvider).recognizeFile(
            absolutePath,
          ) ??
          '';
    } catch (_) {
      latin = '';
    }
    try {
      russian = await ref
          .read(spineScriptRecognizerProvider)
          .recognizeFile(absolutePath);
    } catch (_) {
      russian = '';
    }
    final cleaned = readableSpineText(russian);
    return isbnFromText(latin) ?? isbnFromText(cleaned);
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

  Future<void> _pickCover(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file == null) {
        return;
      }
      final bytes = await file.readAsBytes();
      final path = await ref.read(imageStoreProvider).saveBytes(
        bytes,
        cover: true,
      );
      if (!mounted) {
        return;
      }
      setState(() => _draft = _draft.copyWith(coverPath: path));
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Не удалось получить изображение.');
      }
    }
  }

  Future<void> _addPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) {
        return;
      }
      final bytes = await file.readAsBytes();
      final path = await ref.read(imageStoreProvider).saveBytes(
        bytes,
        cover: false,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _draft = _draft.copyWith(photoPaths: [..._draft.photoPaths, path]);
      });
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Не удалось получить изображение.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isbn = _isbn.text.trim();
    final isbnHint = isbn.isNotEmpty && normalizeIsbn(isbn) == null
        ? 'ISBN не прошёл проверку, но его можно сохранить'
        : null;
    final options = ref.watch(locationOptionsProvider);
    return _guardUnsaved(Scaffold(
      appBar: AppBar(
        title: Text(widget.heading),
        actions: [
          if (widget.onSkip != null)
            TextButton(
              onPressed: _saving
                  ? null
                  : () async {
                      await widget.onSkip!();
                    },
              child: const Text('Пропустить'),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Сохранение…' : 'Сохранить'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (_draft.recognizedText.trim().isNotEmpty) ...[
            Text(
              'Распознанный текст',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(_draft.recognizedText),
            const SizedBox(height: 16),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoverImage(
                relativePath: _draft.coverPath,
                width: 96,
                height: 144,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => _pickCover(ImageSource.camera),
                      child: const Text('Камера'),
                    ),
                    OutlinedButton(
                      onPressed: () => _pickCover(ImageSource.gallery),
                      child: const Text('Галерея'),
                    ),
                    if (_draft.coverPath != null)
                      TextButton(
                        onPressed: () => setState(() {
                          _draft = _draft.copyWith(coverPath: null);
                        }),
                        child: const Text('Убрать обложку'),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Название'),
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subtitle,
            decoration: const InputDecoration(labelText: 'Подзаголовок'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final format in BookFormat.values)
                ChoiceChip(
                  label: Text(bookFormatLabel(format)),
                  selected: _draft.format == format,
                  onSelected: (_) {
                    setState(() {
                      _draft = _draft.copyWith(format: format).prepared();
                    });
                  },
                ),
            ],
          ),
          if (_draft.format == BookFormat.print) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('На полке'),
                  selected: _draft.placement == BookPlacement.shelf &&
                      (_chooseShelf || _draft.shelfId != null),
                  onSelected: (_) => setState(() {
                    _chooseShelf = true;
                    _draft = _draft.copyWith(placement: BookPlacement.shelf);
                  }),
                ),
                ChoiceChip(
                  label: const Text('Без места'),
                  selected: _draft.placement == BookPlacement.shelf &&
                      _draft.shelfId == null &&
                      !_chooseShelf,
                  onSelected: (_) => setState(() {
                    _chooseShelf = false;
                    _draft = _draft.copyWith(
                      placement: BookPlacement.shelf,
                      shelfId: null,
                      rowId: null,
                      libraryDueAt: null,
                    );
                  }),
                ),
                ChoiceChip(
                  label: const Text('Библиотека'),
                  selected: _draft.placement == BookPlacement.library,
                  onSelected: (_) => setState(() {
                    _chooseShelf = false;
                    _draft = _draft.copyWith(
                      placement: BookPlacement.library,
                      shelfId: null,
                      rowId: null,
                      readingStatus: ReadingStatus.finished,
                      statusChangedAt: _draft.statusChangedAt ?? _today(),
                    );
                  }),
                ),
              ],
            ),
          ],
          if (_draft.placement == BookPlacement.library) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _pickLibraryDue,
                child: Text(
                  _draft.libraryDueAt == null
                      ? 'Срок возврата не указан'
                      : 'Вернуть в библиотеку до ${formatDay(_draft.libraryDueAt!)}',
                ),
              ),
            ),
            if (_draft.libraryDueAt != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() {
                    _draft = _draft.copyWith(libraryDueAt: null);
                  }),
                  child: const Text('Убрать срок возврата'),
                ),
              ),
          ],
          const SizedBox(height: 12),
          Text(
            _draft.format == BookFormat.audio ? 'Статус прослушивания' : 'Статус чтения',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final status in ReadingStatus.values)
                ChoiceChip(
                  label: Text(readingStatusLabelFor(status, _draft.format)),
                  selected: _draft.readingStatus == status,
                  onSelected: (_) {
                    setState(() {
                      _draft = _draft.copyWith(
                        readingStatus: status,
                        statusChangedAt: _today(),
                      );
                    });
                  },
                ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _pickDate(loan: false),
              child: Text(
                '${readingStatusDateLabelFor(_draft.readingStatus, _draft.format)}: ${formatDay(_draft.statusChangedAt ?? _today())}',
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _series,
            decoration: const InputDecoration(labelText: 'Серия'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _volume,
            decoration: const InputDecoration(labelText: 'Номер тома'),
            keyboardType: TextInputType.number,
          ),
          if (_draft.format == BookFormat.audio) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _narrator,
              decoration: const InputDecoration(labelText: 'Чтец'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _duration,
              decoration: const InputDecoration(labelText: 'Длительность, минуты'),
              keyboardType: TextInputType.number,
            ),
          ],
          if (_draft.format == BookFormat.print &&
              _draft.placement == BookPlacement.shelf) ...[
          const SizedBox(height: 16),
          Text('На руках', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _loanPerson,
            decoration: const InputDecoration(
              labelText: 'Кому отдана',
              helperText: 'Пустое поле снимает выдачу',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _pickDate(loan: true),
              child: Text(
                _draft.loanDueAt == null
                    ? 'Дата возврата не указана'
                    : 'Вернуть до ${formatDay(_draft.loanDueAt!)}',
              ),
            ),
          ),
          if (_draft.loanDueAt != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() {
                  _draft = _draft.copyWith(loanDueAt: null);
                }),
                child: const Text('Убрать дату возврата'),
              ),
            ),
          ],
          const SizedBox(height: 16),
          DictionaryChips(
            kind: DictionaryKind.author,
            label: 'Авторы',
            values: _draft.authors,
            onChanged: (values) =>
                setState(() => _draft = _draft.copyWith(authors: values)),
          ),
          const SizedBox(height: 16),
          DictionaryChips(
            kind: DictionaryKind.genre,
            label: 'Жанры',
            values: _draft.genres,
            onChanged: (values) =>
                setState(() => _draft = _draft.copyWith(genres: values)),
          ),
          if (_draft.format == BookFormat.print) ...[
            const SizedBox(height: 16),
            DictionaryChips(
              kind: DictionaryKind.publisher,
              label: 'Издательства',
              values: _draft.publishers,
              onChanged: (values) =>
                  setState(() => _draft = _draft.copyWith(publishers: values)),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            decoration: const InputDecoration(labelText: 'Описание'),
            minLines: 4,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          BookNoteField(controller: _note, enabled: !_saving && !_lookingUp),
          if (_draft.format == BookFormat.print) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _isbn,
            decoration: InputDecoration(
              labelText: 'ISBN',
              helperText: isbnHint,
              suffixIcon: _scanningIsbn
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Снять ISBN',
                      onPressed: _saving || _lookingUp ? null : _scanIsbn,
                      icon: const Icon(Icons.photo_camera_outlined),
                    ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _saving || _lookingUp || _scanningIsbn
                  ? null
                  : _lookupCatalog,
              child: Text(_lookingUp ? 'Ищем…' : 'Найти в каталоге'),
            ),
          ),
          ],
          const SizedBox(height: 16),
          DictionaryChips(
            kind: DictionaryKind.hashtag,
            label: 'Хештеги',
            hint: '#фантастика',
            values: _draft.hashtags,
            onChanged: (values) =>
                setState(() => _draft = _draft.copyWith(hashtags: values)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sourceUrl,
            decoration: const InputDecoration(
              labelText: 'Ссылка',
              hintText: 'Можно вставить адрес магазина или LiveLib',
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Фото', style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              TextButton(onPressed: _addPhoto, child: const Text('Добавить')),
            ],
          ),
          if (_draft.photoPaths.isEmpty)
            const Text('Дополнительных фото нет.')
          else
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _draft.photoPaths.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final path = _draft.photoPaths[index];
                  return Stack(
                    children: [
                      CoverImage(relativePath: path, width: 72, height: 96),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          tooltip: 'Убрать фото',
                          onPressed: () {
                            setState(() {
                              _draft = _draft.copyWith(
                                photoPaths: [
                                  for (var i = 0; i < _draft.photoPaths.length; i++)
                                    if (i != index) _draft.photoPaths[i],
                                ],
                              );
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          if (_draft.format == BookFormat.print &&
              _draft.placement == BookPlacement.shelf &&
              (_chooseShelf || _draft.shelfId != null)) ...[
          const SizedBox(height: 20),
          options.when(
            data: (items) => LocationPicker(
              options: items,
              shelfId: _draft.shelfId,
              rowId: _draft.rowId,
              onChanged: ({required shelfId, required rowId}) {
                setState(() {
                  _draft = _draft.copyWith(shelfId: shelfId, rowId: rowId);
                });
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text(userFacingError(error)),
          ),
          ],
        ],
      ),
    ));
  }

  Widget _guardUnsaved(Widget page) {
    final changed = _textChanged || !identical(_draft, _baseline);
    return PopScope(
      canPop: !changed || _saving || _leaving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        final leave = await confirmDialog(
          context,
          title: 'Выйти без сохранения?',
          message: 'Изменения в карточке не сохранены.',
          confirmLabel: 'Выйти',
        );
        if (!leave || !mounted) {
          return;
        }
        setState(() => _leaving = true);
        Navigator.of(context).pop();
      },
      child: page,
    );
  }
}
