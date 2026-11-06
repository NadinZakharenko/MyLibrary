import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_library/core/models/dictionary_kind.dart';
import 'package:my_library/core/models/reading_status.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/common_widgets.dart';
import 'package:my_library/ui/dictionary_chips.dart';
import 'package:my_library/ui/location_picker.dart';
import 'package:my_library/ui/user_message.dart';

/// One selection for every bulk action on a book list.
class BookSelectionController extends ChangeNotifier {
  bool active = false;
  bool _disposed = false;
  final List<int> _ids = [];

  List<int> get ids => List.unmodifiable(_ids);

  bool isSelected(int id) => _ids.contains(id);

  void start() {
    if (active) {
      return;
    }
    active = true;
    notifyListeners();
  }

  void cancel() {
    if (_disposed) {
      return;
    }
    active = false;
    _ids.clear();
    notifyListeners();
  }

  void toggle(int id) {
    if (!active) {
      return;
    }
    if (!_ids.remove(id)) {
      _ids.add(id);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class BookSelectionHost extends StatefulWidget {
  const BookSelectionHost({super.key, required this.builder});

  final Widget Function(BuildContext context, BookSelectionController selection)
  builder;

  @override
  State<BookSelectionHost> createState() => _BookSelectionHostState();
}

class _BookSelectionHostState extends State<BookSelectionHost> {
  final _selection = BookSelectionController();

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _selection,
      builder: (context, _) => widget.builder(context, _selection),
    );
  }
}

class BookSelectionButton extends StatelessWidget {
  const BookSelectionButton({super.key, required this.selection});

  final BookSelectionController selection;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: selection.active ? selection.cancel : selection.start,
      child: Text(selection.active ? 'Отмена' : 'Выбрать'),
    );
  }
}

class BookBulkBar extends ConsumerWidget {
  const BookBulkBar({super.key, required this.selection});

  final BookSelectionController selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!selection.active || selection.ids.isEmpty) {
      return const SizedBox.shrink();
    }
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              TextButton(
                onPressed: () => _move(context, ref),
                child: const Text('Переместить'),
              ),
              TextButton(
                onPressed: () => _status(context, ref),
                child: const Text('Статус'),
              ),
              TextButton(
                onPressed: () => _publishers(context, ref),
                child: const Text('Издательство'),
              ),
              TextButton(
                onPressed: () => _loan(context, ref),
                child: const Text('Кому отдана'),
              ),
              TextButton(
                onPressed: () => _genres(context, ref),
                child: const Text('Жанр'),
              ),
              TextButton(
                onPressed: () => _hashtags(context, ref),
                child: const Text('Хештег'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _move(BuildContext context, WidgetRef ref) async {
    final place = await showModalBottomSheet<({int? shelfId, int? rowId})>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _MoveBooksSheet(),
    );
    if (place == null || !context.mounted) {
      return;
    }
    await _run(
      context,
      (ids) => ref.read(libraryRepositoryProvider).moveBooks(
        ids: ids,
        shelfId: place.shelfId,
        rowId: place.rowId,
      ),
      (count) => 'Перемещено: $count',
    );
  }

  Future<void> _status(BuildContext context, WidgetRef ref) async {
    final status = await showModalBottomSheet<ReadingStatus>(
      context: context,
      showDragHandle: true,
      builder: (context) => const _StatusSheet(),
    );
    if (status == null || !context.mounted) {
      return;
    }
    await _run(
      context,
      (ids) => ref.read(libraryRepositoryProvider).setBooksReadingStatus(
        ids: ids,
        status: status,
      ),
      (count) => 'Статус обновлён: $count',
    );
  }

  Future<void> _publishers(BuildContext context, WidgetRef ref) async {
    final names = await _dictionary(
      context,
      kind: DictionaryKind.publisher,
      title: 'Издательства',
      allowEmpty: true,
    );
    if (names == null || !context.mounted) {
      return;
    }
    await _run(
      context,
      (ids) => ref.read(libraryRepositoryProvider).setBooksPublishers(
        ids: ids,
        publishers: names,
      ),
      (count) => 'Издательства обновлены: $count',
    );
  }

  Future<void> _genres(BuildContext context, WidgetRef ref) async {
    final names = await _dictionary(
      context,
      kind: DictionaryKind.genre,
      title: 'Жанры',
      allowEmpty: true,
    );
    if (names == null || !context.mounted) {
      return;
    }
    await _run(
      context,
      (ids) => ref.read(libraryRepositoryProvider).setBooksGenres(
        ids: ids,
        genres: names,
      ),
      (count) => 'Жанры обновлены: $count',
    );
  }

  Future<void> _hashtags(BuildContext context, WidgetRef ref) async {
    final names = await _dictionary(
      context,
      kind: DictionaryKind.hashtag,
      title: 'Хештеги',
      hint: '#фантастика',
      allowEmpty: false,
    );
    if (names == null || !context.mounted) {
      return;
    }
    await _run(
      context,
      (ids) => ref.read(libraryRepositoryProvider).addBooksHashtags(
        ids: ids,
        hashtags: names,
      ),
      (count) => 'Хештеги добавлены: $count',
    );
  }

  Future<void> _loan(BuildContext context, WidgetRef ref) async {
    final person = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _LoanSheet(),
    );
    if (person == null || !context.mounted) {
      return;
    }
    await _run(
      context,
      (ids) => ref.read(libraryRepositoryProvider).setBooksLoanPerson(
        ids: ids,
        person: person,
      ),
      (count) => 'Выдача обновлена: $count',
    );
  }

  Future<List<String>?> _dictionary(
    BuildContext context, {
    required DictionaryKind kind,
    required String title,
    required bool allowEmpty,
    String? hint,
  }) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _DictionarySheet(
        kind: kind,
        title: title,
        hint: hint,
        allowEmpty: allowEmpty,
      ),
    );
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function(List<int> ids) action,
    String Function(int count) success,
  ) async {
    final ids = [...selection.ids];
    if (ids.isEmpty) {
      return;
    }
    try {
      await action(ids);
      if (context.mounted) {
        showMessage(context, success(ids.length));
      }
      selection.cancel();
    } catch (error) {
      if (context.mounted) {
        showMessage(context, userFacingError(error));
      }
    }
  }
}

class _MoveBooksSheet extends ConsumerStatefulWidget {
  const _MoveBooksSheet();

  @override
  ConsumerState<_MoveBooksSheet> createState() => _MoveBooksSheetState();
}

class _MoveBooksSheetState extends ConsumerState<_MoveBooksSheet> {
  int? _shelfId;
  int? _rowId;

  @override
  Widget build(BuildContext context) {
    final options = ref.watch(locationOptionsProvider);
    return SafeArea(
      child: SingleChildScrollView(
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
                onPressed: () => Navigator.pop(
                  context,
                  (shelfId: _shelfId, rowId: _rowId),
                ),
                child: const Text('Переместить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusSheet extends StatefulWidget {
  const _StatusSheet();

  @override
  State<_StatusSheet> createState() => _StatusSheetState();
}

class _StatusSheetState extends State<_StatusSheet> {
  ReadingStatus? _status;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Статус чтения',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final status in ReadingStatus.values)
                  ChoiceChip(
                    label: Text(readingStatusLabel(status)),
                    selected: _status == status,
                    onSelected: (_) => setState(() => _status = status),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _status == null
                  ? null
                  : () => Navigator.pop(context, _status),
              child: const Text('Применить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DictionarySheet extends StatefulWidget {
  const _DictionarySheet({
    required this.kind,
    required this.title,
    required this.allowEmpty,
    this.hint,
  });

  final DictionaryKind kind;
  final String title;
  final bool allowEmpty;
  final String? hint;

  @override
  State<_DictionarySheet> createState() => _DictionarySheetState();
}

class _DictionarySheetState extends State<_DictionarySheet> {
  List<String> _values = const [];

  @override
  Widget build(BuildContext context) {
    final canApply = widget.allowEmpty || _values.isNotEmpty;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            DictionaryChips(
              kind: widget.kind,
              label: widget.title,
              hint: widget.hint,
              values: _values,
              onChanged: (values) => setState(() => _values = values),
            ),
            if (widget.allowEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Пустой список очищает поле у выбранных книг.'),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: canApply
                  ? () => Navigator.pop(context, _values)
                  : null,
              child: const Text('Применить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoanSheet extends StatefulWidget {
  const _LoanSheet();

  @override
  State<_LoanSheet> createState() => _LoanSheetState();
}

class _LoanSheetState extends State<_LoanSheet> {
  final _person = TextEditingController();

  @override
  void dispose() {
    _person.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Кому отдана', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _person,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Кому отдана',
              helperText: 'Пустое поле снимает выдачу',
            ),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context, _person.text),
            child: const Text('Применить'),
          ),
        ],
      ),
    );
  }
}
