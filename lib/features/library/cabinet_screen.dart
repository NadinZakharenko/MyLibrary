import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_library/core/format/russian_plural.dart';
import 'package:my_library/features/library/cabinet_composition.dart';
import 'package:my_library/features/library/structure_actions.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/common_widgets.dart';

class CabinetScreen extends ConsumerWidget {
  const CabinetScreen({
    super.key,
    required this.cabinetId,
    this.highlightedShelfId,
  });

  final int cabinetId;
  final int? highlightedShelfId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinet = ref.watch(cabinetProvider(cabinetId));
    return AsyncBody(
      value: cabinet,
      onRetry: () => ref.invalidate(cabinetProvider(cabinetId)),
      data: (data) {
        if (data == null) {
          return const Scaffold(
            body: EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Шкаф не найден',
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(data.name),
            actions: [
              IconButton(
                tooltip: 'Состав',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => CabinetCompositionPage(cabinetId: data.id),
                    ),
                  );
                },
                icon: const Icon(Icons.tune),
              ),
              IconButton(
                tooltip: 'Новая полка',
                onPressed: () => addShelfFlow(context, ref, cabinetId: data.id),
                icon: const Icon(Icons.add),
              ),
              PopupMenuButton<_CabinetAction>(
                onSelected: (action) async {
                  switch (action) {
                    case _CabinetAction.rename:
                      await renameCabinetFlow(
                        context,
                        ref,
                        id: data.id,
                        name: data.name,
                      );
                    case _CabinetAction.delete:
                      await deleteCabinetFlow(
                        context,
                        ref,
                        id: data.id,
                        name: data.name,
                      );
                      if (context.mounted) {
                        context.pop();
                      }
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _CabinetAction.rename,
                    child: Text('Переименовать'),
                  ),
                  PopupMenuItem(
                    value: _CabinetAction.delete,
                    child: Text('Удалить'),
                  ),
                ],
              ),
            ],
          ),
          body: data.shelves.isEmpty
              ? EmptyState(
                  icon: Icons.shelves,
                  title: 'В шкафу нет полок',
                  actionLabel: 'Добавить полку',
                  onAction: () => addShelfFlow(context, ref, cabinetId: data.id),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: data.shelves.length,
                  onReorderItem: (oldIndex, newIndex) async {
                    final ids = [for (final shelf in data.shelves) shelf.id];
                    final moved = ids.removeAt(oldIndex);
                    ids.insert(newIndex, moved);
                    await ref.read(libraryRepositoryProvider).reorderShelves(
                      cabinetId: data.id,
                      orderedIdsTopToBottom: ids,
                    );
                  },
                  header: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${data.roomName}. Верх списка — верх шкафа. Нажмите полку, чтобы открыть книги.',
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final shelf = data.shelves[index];
                    final highlighted = shelf.id == highlightedShelfId;
                    final scheme = Theme.of(context).colorScheme;
                    return _EnsureVisible(
                      key: ValueKey(shelf.id),
                      active: highlighted,
                      child: Card(
                        color: shelf.overfull ? scheme.errorContainer : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: highlighted
                                ? scheme.primary
                                : Colors.transparent,
                            width: highlighted ? 3 : 0,
                          ),
                        ),
                        child: ListTile(
                          title: Text(shelf.title),
                          subtitle: Text(
                            [
                              booksCountLabel(shelf.bookCount),
                              shelf.rowCount == 1
                                  ? 'один ряд'
                                  : 'рядов: ${shelf.rowCount}',
                              if (shelf.filled) 'заполнена',
                              if (shelf.overfull) 'переполнена',
                              if (highlighted) 'книга здесь',
                            ].join(' · '),
                          ),
                          trailing: PopupMenuButton<_ShelfAction>(
                            onSelected: (action) async {
                              switch (action) {
                                case _ShelfAction.edit:
                                  await editShelfFlow(
                                    context,
                                    ref,
                                    shelfId: shelf.id,
                                  );
                                case _ShelfAction.filled:
                                  await ref
                                      .read(libraryRepositoryProvider)
                                      .setShelfFilled(
                                        shelfId: shelf.id,
                                        filled: !shelf.filled,
                                      );
                                case _ShelfAction.delete:
                                  await deleteShelfFlow(
                                    context,
                                    ref,
                                    shelfId: shelf.id,
                                    title: shelf.title,
                                  );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: _ShelfAction.edit,
                                child: Text('Изменить полку'),
                              ),
                              PopupMenuItem(
                                value: _ShelfAction.filled,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Полка заполнена'),
                                    if (shelf.filled) const Icon(Icons.check),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: _ShelfAction.delete,
                                child: Text('Удалить полку'),
                              ),
                            ],
                          ),
                          onTap: () {
                            if (shelf.rowCount == 1) {
                              context.push('/home/row/${shelf.rows.single.id}');
                            } else {
                              context.push('/home/shelf/${shelf.id}');
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

enum _CabinetAction { rename, delete }

enum _ShelfAction { edit, filled, delete }

class _EnsureVisible extends StatefulWidget {
  const _EnsureVisible({super.key, required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_EnsureVisible> createState() => _EnsureVisibleState();
}

class _EnsureVisibleState extends State<_EnsureVisible> {
  @override
  void initState() {
    super.initState();
    _reveal();
  }

  @override
  void didUpdateWidget(_EnsureVisible oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _reveal();
    }
  }

  void _reveal() {
    if (!widget.active) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Scrollable.ensureVisible(
        context,
        alignment: 0.3,
        duration: const Duration(milliseconds: 250),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
