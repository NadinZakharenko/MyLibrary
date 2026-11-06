import 'package:flutter/material.dart';
import 'package:my_library/core/format/location_path.dart';
import 'package:my_library/core/models/library_view.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({
    super.key,
    required this.options,
    required this.shelfId,
    required this.rowId,
    required this.onChanged,
  });

  final List<LocationOption> options;
  final int? shelfId;
  final int? rowId;
  final void Function({required int? shelfId, required int? rowId}) onChanged;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  int? _roomId;
  int? _cabinetId;

  @override
  void initState() {
    super.initState();
    _syncFromShelf();
  }

  @override
  void didUpdateWidget(LocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shelfId != oldWidget.shelfId && widget.shelfId != null) {
      _syncFromShelf();
    }
  }

  void _syncFromShelf() {
    final selected = widget.options
        .where((option) => option.shelfId == widget.shelfId)
        .firstOrNull;
    _roomId = selected?.roomId;
    _cabinetId = selected?.cabinetId;
  }

  @override
  Widget build(BuildContext context) {
    final rooms = <int, String>{
      for (final option in widget.options) option.roomId: option.roomName,
    };
    final cabinets = <int, String>{
      for (final option in widget.options.where((item) => item.roomId == _roomId))
        option.cabinetId: option.cabinetName,
    };
    final shelves = widget.options
        .where((option) => option.cabinetId == _cabinetId)
        .toList();
    final selectedShelf = shelves
        .where((option) => option.shelfId == widget.shelfId)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Место', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _menu<int?>(
          label: 'Комната',
          value: _roomId,
            entries: [
              const _Entry<int?>(null, 'Без места'),
              for (final entry in rooms.entries)
                _Entry<int?>(entry.key, entry.value),
            ],
          onChanged: (roomId) {
            setState(() {
              _roomId = roomId;
              _cabinetId = null;
            });
            widget.onChanged(shelfId: null, rowId: null);
          },
        ),
        if (_roomId != null) ...[
          const SizedBox(height: 12),
          _menu<int?>(
            label: 'Шкаф',
            value: cabinets.containsKey(_cabinetId) ? _cabinetId : null,
            entries: [
              for (final entry in cabinets.entries)
                _Entry(entry.key, entry.value),
            ],
            onChanged: (cabinetId) {
              setState(() => _cabinetId = cabinetId);
              widget.onChanged(shelfId: null, rowId: null);
            },
          ),
        ],
        if (_cabinetId != null) ...[
          const SizedBox(height: 12),
          _menu<int?>(
            label: 'Полка',
            value: selectedShelf?.shelfId,
            entries: [
              for (final shelf in shelves)
                _Entry(shelf.shelfId, _shelfTitle(shelf)),
            ],
            onChanged: (shelfId) {
              final shelf = shelves
                  .where((option) => option.shelfId == shelfId)
                  .firstOrNull;
              if (shelf == null) {
                return;
              }
              final rowId = shelf.rows.length == 1 ? shelf.rows.single.id : null;
              widget.onChanged(shelfId: shelf.shelfId, rowId: rowId);
            },
          ),
        ],
        if (selectedShelf != null && selectedShelf.rows.length > 1) ...[
          const SizedBox(height: 12),
          _menu<int?>(
            label: 'Ряд',
            value: selectedShelf.rows.any((row) => row.id == widget.rowId)
                ? widget.rowId
                : null,
            entries: [
              for (final row in selectedShelf.rows)
                _Entry(row.id, row.title),
            ],
            onChanged: (rowId) {
              widget.onChanged(shelfId: selectedShelf.shelfId, rowId: rowId);
            },
          ),
        ],
        if (selectedShelf != null && selectedShelf.rows.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('На этой полке нет рядов. Добавьте ряд в шкафу.'),
          ),
        if (widget.options.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Сначала создайте комнату и шкаф. Книгу можно сохранить без места.'),
          ),
      ],
    );
  }

  String _shelfTitle(LocationOption option) {
    final title = shelfPlaceTitle(option.shelfIndex, option.shelfLabel);
    if (option.shelfFilled) {
      return '$title · заполнена';
    }
    return title;
  }
}

class _Entry<T> {
  const _Entry(this.value, this.label);

  final T value;
  final String label;
}

Widget _menu<T>({
  required String label,
  required T value,
  required List<_Entry<T>> entries,
  required ValueChanged<T?> onChanged,
}) {
  final known = entries.any((entry) => entry.value == value);
  return InputDecorator(
    decoration: InputDecoration(labelText: label),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        isExpanded: true,
        value: known ? value : null,
        items: [
          for (final entry in entries)
            DropdownMenuItem<T>(
              value: entry.value,
              child: Text(entry.label),
            ),
        ],
        onChanged: onChanged,
      ),
    ),
  );
}
