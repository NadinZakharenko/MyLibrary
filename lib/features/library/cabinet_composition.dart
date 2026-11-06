import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_library/core/format/russian_plural.dart';
import 'package:my_library/core/models/library_view.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/common_widgets.dart';
import 'package:my_library/ui/user_message.dart';

class CabinetCompositionPage extends ConsumerStatefulWidget {
  const CabinetCompositionPage({super.key, required this.cabinetId});

  final int cabinetId;

  @override
  ConsumerState<CabinetCompositionPage> createState() =>
      _CabinetCompositionPageState();
}

class _CabinetCompositionPageState extends ConsumerState<CabinetCompositionPage> {
  var _ready = false;
  var _missing = false;
  var _shelfCount = 1;
  final _rowCounts = <int, int>{};
  List<ShelfInfo> _shelves = const [];

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      final cabinet = await ref.read(libraryRepositoryProvider).cabinet(widget.cabinetId);
      if (!mounted) {
        return;
      }
      if (cabinet == null) {
        setState(() {
          _missing = true;
          _ready = true;
        });
        return;
      }
      setState(() {
        _shelves = cabinet.shelves;
        _shelfCount = cabinet.shelves.length;
        for (final shelf in cabinet.shelves) {
          _rowCounts[shelf.id] = shelf.rowCount;
        }
        _ready = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_missing) {
      return const Scaffold(
        body: EmptyState(icon: Icons.shelves, title: 'Шкаф не найден'),
      );
    }
    final visible = _shelves.take(_shelfCount).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Состав шкафа')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Новые полки и ряды добавляются снизу пустыми. Лишние убираются снизу. Книги с убранной полки или ряда остаются в библиотеке без места.',
          ),
          const SizedBox(height: 16),
          _StepperRow(
            label: 'Полок',
            value: _shelfCount,
            min: 0,
            max: 40,
            onChanged: (value) => setState(() => _shelfCount = value),
          ),
          const SizedBox(height: 8),
          for (final shelf in visible) ...[
            _StepperRow(
              label: shelf.title,
              value: _rowCounts[shelf.id] ?? shelf.rowCount,
              min: 1,
              max: 40,
              onChanged: (value) => setState(() => _rowCounts[shelf.id] = value),
            ),
          ],
          if (_shelfCount > _shelves.length)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Снизу добавится ${_shelfCount - _shelves.length} пустых полок, на каждой один ряд.',
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final lost = _booksLosingPlace();
    if (lost > 0) {
      final confirmed = await confirmDialog(
        context,
        title: 'Изменить состав',
        message:
            '${booksCountLabel(lost)} останутся без места. Полки и ряды убираются снизу.',
        confirmLabel: 'Изменить',
      );
      if (!confirmed || !mounted) {
        return;
      }
    }
    final repository = ref.read(libraryRepositoryProvider);
    try {
      for (final shelf in _shelves.take(_shelfCount)) {
        final rows = _rowCounts[shelf.id] ?? shelf.rowCount;
        if (rows != shelf.rowCount) {
          await repository.resizeShelfRows(shelfId: shelf.id, rowCount: rows);
        }
      }
      if (_shelfCount != _shelves.length) {
        await repository.resizeCabinetShelves(
          cabinetId: widget.cabinetId,
          shelfCount: _shelfCount,
        );
      }
    } catch (error) {
      if (mounted) {
        showMessage(context, userFacingError(error));
      }
      return;
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  int _booksLosingPlace() {
    var lost = 0;
    if (_shelfCount < _shelves.length) {
      for (final shelf in _shelves.skip(_shelfCount)) {
        lost += shelf.bookCount;
      }
    }
    for (final shelf in _shelves.take(_shelfCount)) {
      final rows = _rowCounts[shelf.id] ?? shelf.rowCount;
      if (rows < shelf.rows.length) {
        for (final row in shelf.rows.skip(rows)) {
          lost += row.bookCount;
        }
      }
    }
    return lost;
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          tooltip: 'Меньше',
          onPressed: value <= min ? null : () => onChanged(value - 1),
          icon: const Icon(Icons.remove),
        ),
        Text('$value'),
        IconButton(
          tooltip: 'Больше',
          onPressed: value >= max ? null : () => onChanged(value + 1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
