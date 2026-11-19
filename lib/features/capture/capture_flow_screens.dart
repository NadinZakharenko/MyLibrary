import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_library/core/models/book_draft.dart';
import 'package:my_library/features/books/book_editor.dart';
import 'package:my_library/features/capture/capture_controller.dart';
import 'package:my_library/features/capture/capture_navigation.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/candidate_sheet.dart';
import 'package:my_library/ui/common_widgets.dart';
import 'package:my_library/ui/duplicate_prompt.dart';
import 'package:my_library/ui/location_picker.dart';
import 'package:my_library/ui/open_book.dart';

class ManualLookupScreen extends ConsumerStatefulWidget {
  const ManualLookupScreen({super.key});

  @override
  ConsumerState<ManualLookupScreen> createState() => _ManualLookupScreenState();
}

class _ManualLookupScreenState extends ConsumerState<ManualLookupScreen> {
  final _title = TextEditingController();
  final _author = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поиск по названию')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Название'),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _author,
            decoration: const InputDecoration(labelText: 'Автор'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _search,
            child: Text(_busy ? 'Ищем…' : 'Найти'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _busy
                ? null
                : () async {
                    ref.read(captureControllerProvider.notifier).reset();
                    await ref
                        .read(captureControllerProvider.notifier)
                        .searchManual(title: _title.text, author: _author.text);
                    ref
                        .read(captureControllerProvider.notifier)
                        .useManualForm();
                    if (context.mounted) {
                      context.push('/add/form');
                    }
                  },
            child: const Text('Заполнить карточку без поиска'),
          ),
        ],
      ),
    );
  }

  Future<void> _search() async {
    if (_title.text.trim().isEmpty && _author.text.trim().isEmpty) {
      showMessage(context, 'Введите название или автора.');
      return;
    }
    setState(() => _busy = true);
    final next = await ref
        .read(captureControllerProvider.notifier)
        .searchManual(title: _title.text, author: _author.text);
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    await openCaptureNext(context, ref, next);
  }
}

class CandidatesScreen extends ConsumerWidget {
  const CandidatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capture = ref.watch(captureControllerProvider);
    final draft = capture.active;
    return Scaffold(
      appBar: AppBar(title: const Text('Варианты')),
      body: draft == null
          ? const EmptyState(
              icon: Icons.search_off,
              title: 'Нет активного поиска',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Выберите подходящее издание или заполните карточку сами. Ничего не сохранится, пока вы не нажмёте «Сохранить».',
                ),
                const SizedBox(height: 12),
                if (draft.candidates.isEmpty)
                  const Text('Каталоги ничего не вернули.')
                else
                  for (final candidate in draft.candidates)
                    Card(
                      child: MetadataCandidateTile(
                        candidate: candidate,
                        onTap: capture.busy
                            ? null
                            : () async {
                                await ref
                                    .read(captureControllerProvider.notifier)
                                    .applyCandidate(candidate);
                                if (!context.mounted) {
                                  return;
                                }
                                final error = ref
                                    .read(captureControllerProvider)
                                    .error;
                                if (error != null) {
                                  showMessage(context, error);
                                  return;
                                }
                                context.push('/add/form');
                              },
                      ),
                    ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    ref
                        .read(captureControllerProvider.notifier)
                        .useManualForm();
                    context.push('/add/form');
                  },
                  child: const Text('Заполнить вручную'),
                ),
              ],
            ),
    );
  }
}

class DraftFormScreen extends ConsumerWidget {
  const DraftFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capture = ref.watch(captureControllerProvider);
    final draft = capture.active;
    if (draft == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.edit_note,
          title: 'Нет черновика',
          message: 'Сначала выберите способ добавления.',
        ),
      );
    }
    return BookEditor(
      initial: draft,
      heading: 'Карточка книги',
      onSave: (edited) async {
        final allowed = await confirmDuplicates(context, ref, [edited]);
        if (!allowed || !context.mounted) {
          return;
        }
        final id = await ref
            .read(captureControllerProvider.notifier)
            .saveDraft(edited);
        if (!context.mounted) {
          return;
        }
        if (id == null) {
          final error = ref.read(captureControllerProvider).error;
          if (error != null) {
            showMessage(context, error);
          }
          return;
        }
        final method = ref.read(captureControllerProvider).method;
        if (method == CaptureMethod.batchPhotos) {
          context.pop();
        } else {
          context.go('/add/book/$id');
        }
      },
    );
  }
}

class BatchDraftsScreen extends ConsumerWidget {
  const BatchDraftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capture = ref.watch(captureControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Черновики')),
      body: capture.drafts.isEmpty
          ? const EmptyState(
              icon: Icons.photo_library_outlined,
              title: 'Черновиков нет',
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _assignPlace(context, ref),
                          child: const Text('Место для всех'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: capture.busy
                              ? null
                              : () async {
                                  final allowed = await confirmDuplicates(
                                    context,
                                    ref,
                                    ref.read(captureControllerProvider).drafts,
                                  );
                                  if (!allowed || !context.mounted) {
                                    return;
                                  }
                                  final saved = await ref
                                      .read(captureControllerProvider.notifier)
                                      .saveAll();
                                  if (context.mounted) {
                                    showMessage(
                                      context,
                                      saved == 0
                                          ? 'Нет карточек с названием.'
                                          : 'Сохранено: $saved',
                                    );
                                  }
                                },
                          child: const Text('Сохранить'),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: capture.drafts.length,
                    itemBuilder: (context, index) {
                      final draft = capture.drafts[index];
                      return ListTile(
                        leading: CoverImage(
                          relativePath:
                              draft.coverPath ??
                              (draft.photoPaths.isEmpty
                                  ? null
                                  : draft.photoPaths.first),
                        ),
                        title: Text(
                          draft.title.trim().isEmpty
                              ? 'Без названия'
                              : draft.title,
                        ),
                        subtitle: Text(draftStatusLabel(draft.status)),
                        trailing: draft.savedBookId == null
                            ? const Icon(Icons.chevron_right)
                            : const Icon(Icons.check),
                        onTap: draft.savedBookId == null
                            ? () {
                                ref
                                    .read(captureControllerProvider.notifier)
                                    .setActive(index);
                                context.push('/add/form');
                              }
                            : () => openBook(context, draft.savedBookId!),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _assignPlace(BuildContext context, WidgetRef ref) async {
    final selection = await showModalBottomSheet<({int? shelfId, int? rowId})>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _BatchLocationSheet(),
    );
    if (selection == null) {
      return;
    }
    ref
        .read(captureControllerProvider.notifier)
        .assignLocationToAll(
          shelfId: selection.shelfId,
          rowId: selection.rowId,
        );
    if (context.mounted) {
      showMessage(context, 'Место назначено всем несохранённым черновикам.');
    }
  }
}

class _BatchLocationSheet extends ConsumerStatefulWidget {
  const _BatchLocationSheet();

  @override
  ConsumerState<_BatchLocationSheet> createState() =>
      _BatchLocationSheetState();
}

class _BatchLocationSheetState extends ConsumerState<_BatchLocationSheet> {
  int? _shelfId;
  int? _rowId;

  @override
  Widget build(BuildContext context) {
    final options = ref.watch(locationOptionsProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: options.when(
          loading: () => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Text(error.toString()),
          data: (items) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Общее место',
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
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(context, (shelfId: _shelfId, rowId: _rowId)),
                child: const Text('Назначить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  var _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сканер ISBN')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_handled) {
            return;
          }
          final raw = capture.barcodes
              .map((barcode) => barcode.rawValue)
              .whereType<String>()
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .firstOrNull;
          if (raw == null) {
            return;
          }
          _handled = true;
          context.pop(raw);
        },
        errorBuilder: (context, error) {
          return const EmptyState(
            icon: Icons.qr_code_scanner,
            title: 'Камера недоступна',
            message: 'Сканер работает на телефоне. ISBN можно ввести в карточке книги.',
          );
        },
      ),
    );
  }
}
