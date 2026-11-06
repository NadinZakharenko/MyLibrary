import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_library/core/format/russian_plural.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/common_widgets.dart';
import 'package:my_library/ui/user_message.dart';

Future<void> createRoomFlow(BuildContext context, WidgetRef ref) async {
  final input = await _askRoom(context);
  if (input == null || !context.mounted) {
    return;
  }
  await _run(context, () {
    return ref.read(libraryRepositoryProvider).createRoom(
      name: input.name,
      note: input.note,
    );
  });
}

Future<void> renameRoomFlow(
  BuildContext context,
  WidgetRef ref, {
  required int id,
  required String name,
  required String note,
}) async {
  final input = await _askRoom(context, name: name, note: note, title: 'Комната');
  if (input == null || !context.mounted) {
    return;
  }
  await _run(context, () {
    return ref.read(libraryRepositoryProvider).updateRoom(
      id: id,
      name: input.name,
      note: input.note,
    );
  });
}

Future<void> deleteRoomFlow(
  BuildContext context,
  WidgetRef ref, {
  required int id,
  required String name,
}) async {
  final count = await ref.read(libraryRepositoryProvider).countBooksInRoom(id);
  if (!context.mounted) {
    return;
  }
  final message = count == 0
      ? 'Удалить комнату «$name»? Шкафы внутри тоже будут удалены.'
      : 'В комнате ${booksCountLabel(count)}. Они останутся в библиотеке без места. Удалить комнату «$name»?';
  final confirmed = await confirmDialog(
    context,
    title: 'Удалить комнату',
    message: message,
  );
  if (!confirmed || !context.mounted) {
    return;
  }
  await _run(context, () => ref.read(libraryRepositoryProvider).deleteRoom(id));
}

Future<void> createCabinetFlow(
  BuildContext context,
  WidgetRef ref, {
  required int roomId,
}) async {
  final input = await _askCabinet(context);
  if (input == null || !context.mounted) {
    return;
  }
  await _run(context, () {
    return ref.read(libraryRepositoryProvider).createCabinet(
      roomId: roomId,
      name: input.name,
      shelfCount: input.shelfCount,
      rowsPerShelf: input.rowsPerShelf,
    );
  });
}

Future<void> renameCabinetFlow(
  BuildContext context,
  WidgetRef ref, {
  required int id,
  required String name,
}) async {
  final next = await _askText(context, title: 'Шкаф', label: 'Название', initial: name);
  if (next == null || !context.mounted) {
    return;
  }
  await _run(
    context,
    () => ref.read(libraryRepositoryProvider).renameCabinet(id: id, name: next),
  );
}

Future<void> deleteCabinetFlow(
  BuildContext context,
  WidgetRef ref, {
  required int id,
  required String name,
}) async {
  final count = await ref.read(libraryRepositoryProvider).countBooksInCabinet(id);
  if (!context.mounted) {
    return;
  }
  final message = count == 0
      ? 'Удалить шкаф «$name»?'
      : 'В шкафу ${booksCountLabel(count)}. Они останутся без места. Удалить шкаф «$name»?';
  final confirmed = await confirmDialog(
    context,
    title: 'Удалить шкаф',
    message: message,
  );
  if (!confirmed || !context.mounted) {
    return;
  }
  await _run(context, () => ref.read(libraryRepositoryProvider).deleteCabinet(id));
}

Future<void> addShelfFlow(
  BuildContext context,
  WidgetRef ref, {
  required int cabinetId,
}) async {
  final input = await _askShelf(context);
  if (input == null || !context.mounted) {
    return;
  }
  await _run(context, () {
    return ref.read(libraryRepositoryProvider).addShelf(
      cabinetId: cabinetId,
      label: input.label,
      rowCount: input.rowCount,
    );
  });
}

Future<void> editShelfFlow(
  BuildContext context,
  WidgetRef ref, {
  required int shelfId,
}) async {
  final current = await ref.read(libraryRepositoryProvider).shelf(shelfId);
  if (current == null || !context.mounted) {
    return;
  }
  final input = await showDialog<_ShelfInput>(
    context: context,
    builder: (context) => _ShelfDialog(
      title: 'Изменить полку',
      number: current.index + 1,
      label: current.label ?? '',
      rows: current.rowCount,
      confirmLabel: 'Сохранить',
    ),
  );
  if (input == null || !context.mounted) {
    return;
  }
  if (input.rowCount < current.rowCount) {
    var lost = 0;
    for (final row in current.rows.skip(input.rowCount)) {
      lost += row.bookCount;
    }
    if (lost > 0) {
      final confirmed = await confirmDialog(
        context,
        title: 'Изменить полку',
        message:
            '${booksCountLabel(lost)} останутся без места. Ряды убираются снизу.',
        confirmLabel: 'Изменить',
      );
      if (!confirmed || !context.mounted) {
        return;
      }
    }
  }
  await _run(context, () async {
    final repository = ref.read(libraryRepositoryProvider);
    await repository.updateShelfLabel(shelfId: shelfId, label: input.label);
    if (input.rowCount != current.rowCount) {
      await repository.resizeShelfRows(shelfId: shelfId, rowCount: input.rowCount);
    }
  });
}

Future<void> deleteShelfFlow(
  BuildContext context,
  WidgetRef ref, {
  required int shelfId,
  required String title,
}) async {
  final count = await ref.read(libraryRepositoryProvider).countBooksOnShelf(shelfId);
  if (!context.mounted) {
    return;
  }
  final message = count == 0
      ? 'Удалить «$title»?'
      : 'На полке ${booksCountLabel(count)}. Они останутся без места. Удалить «$title»?';
  final confirmed = await confirmDialog(
    context,
    title: 'Удалить полку',
    message: message,
  );
  if (!confirmed || !context.mounted) {
    return;
  }
  await _run(context, () => ref.read(libraryRepositoryProvider).deleteShelf(shelfId));
}

Future<void> editRowFlow(
  BuildContext context,
  WidgetRef ref, {
  required int rowId,
  required int number,
  required String label,
}) async {
  final next = await showDialog<String>(
    context: context,
    builder: (context) => _RowDialog(number: number, label: label),
  );
  if (next == null || !context.mounted) {
    return;
  }
  await _run(context, () {
    return ref.read(libraryRepositoryProvider).updateRowLabel(
      rowId: rowId,
      label: next,
    );
  });
}

Future<void> deleteRowFlow(
  BuildContext context,
  WidgetRef ref, {
  required int rowId,
  required String title,
}) async {
  final count = await ref.read(libraryRepositoryProvider).countBooksOnRow(rowId);
  if (!context.mounted) {
    return;
  }
  final message = count == 0
      ? 'Удалить «$title»?'
      : 'В ряду ${booksCountLabel(count)}. Они останутся без места. Удалить «$title»?';
  final confirmed = await confirmDialog(
    context,
    title: 'Удалить ряд',
    message: message,
  );
  if (!confirmed || !context.mounted) {
    return;
  }
  await _run(context, () => ref.read(libraryRepositoryProvider).deleteRow(rowId));
}

Future<void> reorderFlow(
  BuildContext context, {
  required String title,
  required List<({int id, String label})> items,
  required Future<void> Function(List<int> orderedIds) onSubmit,
}) async {
  if (items.length < 2) {
    showMessage(context, 'Менять порядок пока нечего.');
    return;
  }
  final ordered = await showModalBottomSheet<List<int>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _ReorderSheet(title: title, items: items),
  );
  if (ordered == null || !context.mounted) {
    return;
  }
  await _run(context, () => onSubmit(ordered));
}

Future<void> _run(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
  } catch (error) {
    if (context.mounted) {
      showMessage(context, userFacingError(error));
    }
  }
}

class _RoomInput {
  const _RoomInput(this.name, this.note);

  final String name;
  final String note;
}

class _CabinetInput {
  const _CabinetInput(this.name, this.shelfCount, this.rowsPerShelf);

  final String name;
  final int shelfCount;
  final int rowsPerShelf;
}

class _ShelfInput {
  const _ShelfInput(this.label, this.rowCount);

  final String label;
  final int rowCount;
}

Future<_RoomInput?> _askRoom(
  BuildContext context, {
  String title = 'Новая комната',
  String name = '',
  String note = '',
}) {
  return showDialog<_RoomInput>(
    context: context,
    builder: (context) => _RoomDialog(title: title, name: name, note: note),
  );
}

Future<_CabinetInput?> _askCabinet(BuildContext context) {
  return showDialog<_CabinetInput>(
    context: context,
    builder: (context) => const _CabinetDialog(),
  );
}

Future<_ShelfInput?> _askShelf(BuildContext context) {
  return showDialog<_ShelfInput>(
    context: context,
    builder: (context) => const _ShelfDialog(),
  );
}

Future<String?> _askText(
  BuildContext context, {
  required String title,
  required String label,
  String initial = '',
  bool allowEmpty = false,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _TextDialog(
      title: title,
      label: label,
      initial: initial,
      allowEmpty: allowEmpty,
    ),
  );
}

class _TextDialog extends StatefulWidget {
  const _TextDialog({
    required this.title,
    required this.label,
    required this.initial,
    required this.allowEmpty,
  });

  final String title;
  final String label;
  final String initial;
  final bool allowEmpty;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(labelText: widget.label),
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isEmpty && !widget.allowEmpty) {
              return;
            }
            Navigator.pop(context, text);
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}

class _RoomDialog extends StatefulWidget {
  const _RoomDialog({required this.title, required this.name, required this.note});

  final String title;
  final String name;
  final String note;

  @override
  State<_RoomDialog> createState() => _RoomDialogState();
}

class _RoomDialogState extends State<_RoomDialog> {
  late final TextEditingController _name = TextEditingController(text: widget.name);
  late final TextEditingController _note = TextEditingController(text: widget.note);

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Название'),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            decoration: const InputDecoration(labelText: 'Заметка'),
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            final name = _name.text.trim();
            if (name.isEmpty) {
              return;
            }
            Navigator.pop(context, _RoomInput(name, _note.text.trim()));
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}

class _CabinetDialog extends StatefulWidget {
  const _CabinetDialog();

  @override
  State<_CabinetDialog> createState() => _CabinetDialogState();
}

class _CabinetDialogState extends State<_CabinetDialog> {
  final _name = TextEditingController();
  var _shelves = 4;
  var _rows = 1;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новый шкаф'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Название'),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
          ),
          const SizedBox(height: 12),
          _stepper(
            label: 'Полок',
            value: _shelves,
            onChanged: (value) => setState(() => _shelves = value),
          ),
          _stepper(
            label: 'Рядов на полке',
            value: _rows,
            onChanged: (value) => setState(() => _rows = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            final name = _name.text.trim();
            if (name.isEmpty) {
              return;
            }
            Navigator.pop(context, _CabinetInput(name, _shelves, _rows));
          },
          child: const Text('Создать'),
        ),
      ],
    );
  }
}

class _ShelfDialog extends StatefulWidget {
  const _ShelfDialog({
    this.title = 'Новая полка',
    this.number,
    this.label = '',
    this.rows = 1,
    this.confirmLabel = 'Добавить',
  });

  final String title;
  final int? number;
  final String label;
  final int rows;
  final String confirmLabel;

  @override
  State<_ShelfDialog> createState() => _ShelfDialogState();
}

class _ShelfDialogState extends State<_ShelfDialog> {
  late final TextEditingController _label = TextEditingController(text: widget.label);
  late final TextEditingController? _number = widget.number == null
      ? null
      : TextEditingController(text: '${widget.number}');
  late var _rows = widget.rows < 1 ? 1 : widget.rows;

  @override
  void dispose() {
    _label.dispose();
    _number?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final number = _number;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (number != null) ...[
            TextField(
              controller: number,
              readOnly: true,
              canRequestFocus: false,
              decoration: const InputDecoration(labelText: 'Номер'),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _label,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Название',
              hintText: 'необязательно',
            ),
          ),
          _stepper(
            label: 'Рядов',
            value: _rows,
            max: 40,
            onChanged: (value) => setState(() => _rows = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, _ShelfInput(_label.text.trim(), _rows));
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

Widget _stepper({
  required String label,
  required int value,
  required ValueChanged<int> onChanged,
  int min = 1,
  int max = 20,
}) {
  return Row(
    children: [
      Expanded(child: Text(label)),
      IconButton(
        onPressed: value <= min ? null : () => onChanged(value - 1),
        icon: const Icon(Icons.remove),
      ),
      Text('$value'),
      IconButton(
        onPressed: value >= max ? null : () => onChanged(value + 1),
        icon: const Icon(Icons.add),
      ),
    ],
  );
}

class _RowDialog extends StatefulWidget {
  const _RowDialog({required this.number, required this.label});

  final int number;
  final String label;

  @override
  State<_RowDialog> createState() => _RowDialogState();
}

class _RowDialogState extends State<_RowDialog> {
  late final TextEditingController _number = TextEditingController(
    text: '${widget.number}',
  );
  late final TextEditingController _label = TextEditingController(text: widget.label);

  @override
  void dispose() {
    _number.dispose();
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Изменить ряд'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _number,
            readOnly: true,
            canRequestFocus: false,
            decoration: const InputDecoration(labelText: 'Номер'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _label,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Название',
              hintText: 'необязательно',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _label.text.trim()),
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}

class _ReorderSheet extends StatefulWidget {
  const _ReorderSheet({required this.title, required this.items});

  final String title;
  final List<({int id, String label})> items;

  @override
  State<_ReorderSheet> createState() => _ReorderSheetState();
}

class _ReorderSheetState extends State<_ReorderSheet> {
  late final List<({int id, String label})> _items = [...widget.items];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.7;
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context, [for (final item in _items) item.id]);
                    },
                    child: const Text('Готово'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: _items.length,
                onReorderItem: (oldIndex, newIndex) {
                  setState(() {
                    final moved = _items.removeAt(oldIndex);
                    _items.insert(newIndex, moved);
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    key: ValueKey(item.id),
                    title: Text(item.label),
                    trailing: const Icon(Icons.drag_handle),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> editRowCapacityFlow(
  BuildContext context,
  WidgetRef ref, {
  required int rowId,
  required int? capacity,
}) async {
  final control = await ref
      .read(libraryRepositoryProvider)
      .rowOverflowControlEnabled();
  if (!context.mounted) {
    return;
  }
  final text = await showDialog<String>(
    context: context,
    builder: (context) => _CapacityDialog(
      initial: capacity?.toString() ?? '',
      control: control,
    ),
  );
  if (text == null || !context.mounted) {
    return;
  }
  int? next;
  if (text.isNotEmpty) {
    next = int.tryParse(text);
    if (next == null || next < 1) {
      showMessage(
        context,
        'Введите целое число больше нуля или оставьте поле пустым.',
      );
      return;
    }
  }
  await _run(context, () {
    return ref.read(libraryRepositoryProvider).setRowCapacity(
      rowId: rowId,
      capacity: next,
    );
  });
}

class _CapacityDialog extends StatefulWidget {
  const _CapacityDialog({required this.initial, required this.control});

  final String initial;
  final bool control;

  @override
  State<_CapacityDialog> createState() => _CapacityDialogState();
}

class _CapacityDialogState extends State<_CapacityDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Вместимость ряда'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Максимум книг',
              helperText: 'Пустое поле — без ограничения',
            ),
            autofocus: true,
          ),
          if (!widget.control) ...[
            const SizedBox(height: 12),
            const Text(
              'Контроль переполнения выключен в настройках. Число сохранится, подсветка появится после включения.',
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
