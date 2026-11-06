import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_library/core/models/library_view.dart';

const _spineColors = <Color>[
  Color(0xFF4E342E),
  Color(0xFF1B5E20),
  Color(0xFF0D47A1),
  Color(0xFF4A148C),
  Color(0xFFB71C1C),
  Color(0xFF004D40),
  Color(0xFF263238),
  Color(0xFFE65100),
  Color(0xFF01579B),
  Color(0xFF880E4F),
];

/// One row of book spines standing on a plank, left to right.
///
/// A short tap opens the book. A long press drags it to a new place in this
/// row only.
class SpinePlank extends StatelessWidget {
  const SpinePlank({
    super.key,
    required this.books,
    required this.onReorder,
    this.selecting = false,
    this.isSelected,
    this.onSelected,
  });

  static const double bandHeight = 188;
  static const double _spineWidth = 48;
  static const double _spineHeight = 152;
  static const double _itemExtent = 56;

  final List<BookSummary> books;
  final Future<void> Function(List<int> orderedIds) onReorder;

  /// While selecting, a tap toggles the book and the long-press drag is off.
  final bool selecting;
  final bool Function(int id)? isSelected;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: bandHeight,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFBCAAA4),
          border: Border(
            bottom: BorderSide(color: Color(0xFF4E342E), width: 12),
          ),
        ),
        child: books.isEmpty
            ? const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'На этом ряду пока нет книг',
                    style: TextStyle(color: Color(0xFF3E2723)),
                  ),
                ),
              )
            : ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                primary: false,
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                itemCount: books.length,
                itemExtent: _itemExtent,
                onReorderItem: (oldIndex, newIndex) async {
                  final ids = [for (final book in books) book.id];
                  final moved = ids.removeAt(oldIndex);
                  ids.insert(newIndex, moved);
                  await onReorder(ids);
                },
                itemBuilder: (context, index) {
                  final book = books[index];
                  final selected = selecting && (isSelected?.call(book.id) ?? false);
                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(book.id),
                    index: index,
                    enabled: !selecting,
                    child: _Spine(
                      title: book.title,
                      color: _spineColors[book.id.abs() % _spineColors.length],
                      selecting: selecting,
                      selected: selected,
                      onTap: () {
                        if (selecting) {
                          onSelected?.call(book.id);
                          return;
                        }
                        context.push('/book/${book.id}');
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _Spine extends StatelessWidget {
  const _Spine({
    required this.title,
    required this.color,
    required this.selecting,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final Color color;
  final bool selecting;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        width: SpinePlank._spineWidth,
        height: SpinePlank._spineHeight,
        child: Material(
          color: color,
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                RotatedBox(
                  quarterTurns: 3,
                  child: SizedBox(
                    width: SpinePlank._spineHeight,
                    height: SpinePlank._spineWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (selecting)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
