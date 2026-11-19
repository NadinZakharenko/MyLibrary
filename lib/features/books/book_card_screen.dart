import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_library/core/format/book_share.dart';
import 'package:my_library/core/format/copy_notes.dart';
import 'package:share_plus/share_plus.dart';
import 'package:my_library/core/format/loan.dart';
import 'package:my_library/core/models/book_copy.dart';
import 'package:my_library/core/format/russian_plural.dart';
import 'package:my_library/core/format/series_label.dart';
import 'package:my_library/core/models/book_draft.dart';
import 'package:my_library/core/models/library_view.dart';
import 'package:my_library/data/library_repository.dart';
import 'package:my_library/features/books/book_catalog_actions.dart';
import 'package:my_library/features/books/book_editor.dart';
import 'package:my_library/features/books/book_note_field.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/common_widgets.dart';
import 'package:my_library/ui/duplicate_prompt.dart';
import 'package:my_library/ui/location_picker.dart';
import 'package:my_library/ui/open_shelf.dart';
import 'package:my_library/ui/open_url.dart';
import 'package:my_library/ui/user_message.dart';

class BookCardScreen extends ConsumerWidget {
  const BookCardScreen({super.key, required this.bookId});

  final int bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bookProvider(bookId));
    return AsyncBody(
      value: book,
      onRetry: () => ref.invalidate(bookProvider(bookId)),
      data: (data) {
        if (data == null) {
          return const Scaffold(
            body: EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Книга не найдена',
            ),
          );
        }
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(
            leading: _bookCardLeading(context),
            title: const Text('Книга'),
            actions: [
              IconButton(
                tooltip: 'Изменить',
                onPressed: () => context.push(
                  '${GoRouterState.of(context).uri.path}/edit',
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Поделиться',
                onPressed: () => shareBook(data),
                icon: const Icon(Icons.share_outlined),
              ),
              IconButton(
                tooltip: 'Удалить',
                onPressed: () async {
                  final confirmed = await confirmDialog(
                    context,
                    title: 'Удалить книгу',
                    message: 'Будет удалена только эта книга. Другие экземпляры того же издания не изменятся.',
                  );
                  if (!confirmed || !context.mounted) {
                    return;
                  }
                  await ref.read(libraryRepositoryProvider).deleteBook(data.id);
                  if (context.mounted) {
                    _leaveBookCard(context);
                  }
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CoverImage(
                    relativePath: data.coverPath,
                    width: 110,
                    height: 164,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.title, style: theme.textTheme.headlineSmall),
                        if (data.subtitle.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(data.subtitle),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          data.authors.isEmpty
                              ? 'Автор не указан'
                              : data.authors.join(', '),
                        ),
                        if (data.genres.isNotEmpty)
                          Text(data.genres.join(', ')),
                        const SizedBox(height: 8),
                        Text(
                          readingStatusLabelFor(
                            data.readingStatus,
                            data.format,
                          ),
                        ),
                        if (data.statusChangedAt != null)
                          Text(
                            '${readingStatusDateLabelFor(data.readingStatus, data.format)}: ${formatDay(data.statusChangedAt!)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        if (seriesLabel(data.seriesName, data.seriesVolume) !=
                            null)
                          Text(
                            seriesLabel(data.seriesName, data.seriesVolume)!,
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Добавлена ${formatDay(data.createdAt)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (data.cabinetId == null)
                Text(data.locationPath, style: theme.textTheme.titleMedium)
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => openCabinetAtShelf(
                      context,
                      cabinetId: data.cabinetId,
                      shelfId: data.shelfId,
                    ),
                    child: Text(
                      data.locationPath,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
              if (loanIsActive(data.loanPerson)) ...[
                const SizedBox(height: 8),
                Text(
                  copyNotes(
                    readingStatus: data.readingStatus,
                    loanPerson: data.loanPerson,
                    loanDueAt: data.loanDueAt,
                  ).last,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () =>
                      ref.read(libraryRepositoryProvider).returnLoan(data.id),
                  child: const Text('Книга возвращена'),
                ),
              ],
              if (data.format != BookFormat.audio) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _move(context, ref, data),
                  child: const Text('Переместить'),
                ),
              ],
              const SizedBox(height: 16),
              Text('Описание', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                data.description.trim().isEmpty
                    ? 'Описание не заполнено'
                    : data.description,
              ),
              const SizedBox(height: 16),
              _BookNoteEditor(book: data),
              const SizedBox(height: 16),
              if (data.format == BookFormat.audio) ...[
                _line('Чтец', data.narrator),
                _line('Длительность', durationLabel(data.durationSeconds)),
              ],
              if (data.placement == BookPlacement.library)
                _line(
                  'Вернуть в библиотеку',
                  data.libraryDueAt == null
                      ? 'срок не указан'
                      : formatDay(data.libraryDueAt!),
                ),
              if (data.format == BookFormat.print) ...[
                _line('Издательство', data.publishers.join(', ')),
                _line('ISBN', data.isbn),
              ],
              if (data.sourceUrl.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Ссылка', style: theme.textTheme.titleSmall),
                SelectableText(
                  data.sourceUrl,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: theme.colorScheme.primary,
                  ),
                  onTap: () => openExternalPage(context, data.sourceUrl),
                ),
              ],
              BookCatalogActions(book: data),
              if (data.hashtags.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in data.hashtags) Chip(label: Text('#$tag')),
                  ],
                ),
              ],
              if (data.photoPaths.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Фото', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.photoPaths.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) => CoverImage(
                      relativePath: data.photoPaths[index],
                      width: 90,
                      height: 120,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _move(
    BuildContext context,
    WidgetRef ref,
    BookDetails book,
  ) async {
    final moved = await showModalBottomSheet<({int? shelfId, int? rowId})>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _MoveSheet(book: book),
    );
    if (moved == null || !context.mounted) {
      return;
    }
    try {
      await ref
          .read(libraryRepositoryProvider)
          .moveBook(id: book.id, shelfId: moved.shelfId, rowId: moved.rowId);
    } catch (error) {
      if (context.mounted) {
        showMessage(context, userFacingError(error));
      }
    }
  }
}

class _MoveSheet extends ConsumerStatefulWidget {
  const _MoveSheet({required this.book});

  final BookDetails book;

  @override
  ConsumerState<_MoveSheet> createState() => _MoveSheetState();
}

class _MoveSheetState extends ConsumerState<_MoveSheet> {
  late int? _shelfId = widget.book.shelfId;
  late int? _rowId = widget.book.rowId;

  @override
  Widget build(BuildContext context) {
    final options = ref.watch(locationOptionsProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: options.when(
          loading: () => const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Text(userFacingError(error)),
          data: (items) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Куда поставить',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              LocationPicker(
                options: items,
                shelfId: _shelfId,
                rowId: _rowId,
                onChanged: ({required shelfId, required rowId}) {
                  setState(() {
                    _shelfId = shelfId;
                    _rowId = rowId;
                  });
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(context, (shelfId: _shelfId, rowId: _rowId)),
                child: const Text('Переместить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget? _bookCardLeading(BuildContext context) {
  if (context.canPop()) {
    return null;
  }
  return IconButton(
    tooltip: 'На главную',
    onPressed: () => context.go('/home'),
    icon: const Icon(Icons.arrow_back),
  );
}

void _leaveBookCard(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/home');
  }
}

Widget _line(String label, String value) {
  if (value.trim().isEmpty) {
    return const SizedBox.shrink();
  }
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text('$label: $value'),
  );
}

class EditBookScreen extends ConsumerWidget {
  const EditBookScreen({super.key, required this.bookId});

  final int bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bookProvider(bookId));
    return AsyncBody(
      value: book,
      onRetry: () => ref.invalidate(bookProvider(bookId)),
      data: (data) {
        if (data == null) {
          return const Scaffold(
            body: EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Книга не найдена',
            ),
          );
        }
        return BookEditor(
          heading: 'Изменить книгу',
          initial: BookDraft(
            title: data.title,
            subtitle: data.subtitle,
            description: data.description,
            personalNote: data.personalNote,
            isbn: data.isbn,
            authors: data.authors,
            genres: data.genres,
            publishers: data.publishers,
            hashtags: data.hashtags,
            coverPath: data.coverPath,
            photoPaths: data.photoPaths,
            sourceUrl: data.sourceUrl,
            shelfId: data.shelfId,
            rowId: data.rowId,
            savedBookId: data.id,
            readingStatus: data.readingStatus,
            statusChangedAt: data.statusChangedAt,
            seriesName: data.seriesName,
            seriesVolume: data.seriesVolume,
            loanPerson: data.loanPerson,
            loanDueAt: data.loanDueAt,
            format: data.format,
            placement: data.placement,
            libraryDueAt: data.libraryDueAt,
            yandexId: data.yandexId,
            narrator: data.narrator,
            durationSeconds: data.durationSeconds,
            readerRating: data.readerRating,
          ),
          onSave: (draft) async {
            final allowed = await confirmDuplicates(context, ref, [draft]);
            if (!allowed || !context.mounted) {
              return;
            }
            await ref.read(libraryRepositoryProvider).updateBook(bookId, draft);
            if (context.mounted) {
              context.pop();
            }
          },
        );
      },
    );
  }
}

class _BookNoteEditor extends ConsumerStatefulWidget {
  const _BookNoteEditor({required this.book});

  final BookDetails book;

  @override
  ConsumerState<_BookNoteEditor> createState() => _BookNoteEditorState();
}

class _BookNoteEditorState extends ConsumerState<_BookNoteEditor> {
  late final TextEditingController _note = TextEditingController(
    text: widget.book.personalNote,
  );
  var _saving = false;
  var _dirty = false;
  var _applying = false;
  LibraryRepository? _repository;

  @override
  void initState() {
    super.initState();
    _note.addListener(() {
      if (!_applying) {
        _dirty = true;
      }
    });
  }

  @override
  void didUpdateWidget(covariant _BookNoteEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dirty && _note.text != widget.book.personalNote) {
      _applying = true;
      _note.text = widget.book.personalNote;
      _applying = false;
    }
  }

  @override
  void dispose() {
    final text = _note.text;
    if (_dirty && !_saving && text.trim() != widget.book.personalNote.trim()) {
      _repository
          ?.updatePersonalNote(widget.book.id, text)
          .catchError((Object _) {});
    }
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _repository = ref.watch(libraryRepositoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BookNoteField(controller: _note, enabled: !_saving),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Сохраняем…' : 'Сохранить заметку'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(libraryRepositoryProvider)
          .updatePersonalNote(widget.book.id, _note.text);
      _dirty = false;
      if (mounted) {
        showMessage(context, 'Заметка сохранена.');
      }
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
}

Future<void> shareBook(BookDetails book) {
  final title = book.title.trim();
  return SharePlus.instance.share(
    ShareParams(
      text: bookShareText(
        title: book.title,
        authors: book.authors,
        sourceUrl: book.sourceUrl,
      ),
      subject: title.isEmpty ? 'Книга' : title,
    ),
  );
}
