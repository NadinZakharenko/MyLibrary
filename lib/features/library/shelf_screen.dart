import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_library/core/format/russian_plural.dart';
import 'package:my_library/core/models/library_view.dart';
import 'package:my_library/features/books/book_bulk.dart';
import 'package:my_library/features/library/structure_actions.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/common_widgets.dart';
import 'package:my_library/ui/spine_plank.dart';
import 'package:my_library/ui/user_message.dart';

class ShelfScreen extends ConsumerWidget {
  const ShelfScreen({super.key, required this.shelfId});

  final int shelfId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelf = ref.watch(shelfProvider(shelfId));
    return AsyncBody(
      value: shelf,
      onRetry: () => ref.invalidate(shelfProvider(shelfId)),
      data: (data) {
        if (data == null) {
          return const Scaffold(
            body: EmptyState(
              icon: Icons.shelves,
              title: 'Полка не найдена',
            ),
          );
        }
        return BookSelectionHost(
          builder: (context, selection) => Scaffold(
          appBar: AppBar(
            title: Text(data.title),
            actions: [
              BookSelectionButton(selection: selection),
              IconButton(
                tooltip: 'Изменить полку',
                onPressed: () => editShelfFlow(
                  context,
                  ref,
                  shelfId: data.id,
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Добавить ряд',
                onPressed: () => ref.read(libraryRepositoryProvider).addRow(data.id),
                icon: const Icon(Icons.add),
              ),
              IconButton(
                tooltip: 'Удалить полку',
                onPressed: () async {
                  await deleteShelfFlow(
                    context,
                    ref,
                    shelfId: data.id,
                    title: data.title,
                  );
                  if (context.mounted) {
                    context.pop();
                  }
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          bottomNavigationBar: BookBulkBar(selection: selection),
          body: data.rows.isEmpty
              ? EmptyState(
                  icon: Icons.view_agenda_outlined,
                  title: 'На полке нет рядов',
                  message: data.filled ? 'Полка заполнена.' : null,
                  actionLabel: 'Добавить ряд',
                  onAction: () =>
                      ref.read(libraryRepositoryProvider).addRow(data.id),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  buildDefaultDragHandles: false,
                  itemCount: data.rows.length,
                  header: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      data.filled
                          ? 'Полка заполнена. Снимите отметку в меню шкафа, чтобы поставить сюда ещё книгу.\n\nЕсли ряд один, список книг открывается сразу. Здесь можно добавить ещё ряды.'
                          : 'Если ряд один, список книг открывается сразу. Здесь можно добавить ещё ряды.',
                    ),
                  ),
                  onReorderItem: (oldIndex, newIndex) async {
                    final ids = [for (final row in data.rows) row.id];
                    final moved = ids.removeAt(oldIndex);
                    ids.insert(newIndex, moved);
                    await ref.read(libraryRepositoryProvider).reorderRows(
                      shelfId: data.id,
                      orderedIds: ids,
                    );
                  },
                  itemBuilder: (context, index) {
                    final row = data.rows[index];
                    return _ShelfRowBlock(
                      key: ValueKey(row.id),
                      row: row,
                      index: index,
                      canReorder: data.rows.length > 1,
                      selection: selection,
                    );
                  },
                ),
          ),
        );
      },
    );
  }
}

class _ShelfRowBlock extends ConsumerWidget {
  const _ShelfRowBlock({
    super.key,
    required this.row,
    required this.index,
    required this.canReorder,
    required this.selection,
  });

  final RowInfo row;
  final int index;
  final bool canReorder;
  final BookSelectionController selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final limit = row.capacity == null
        ? 'без лимита'
        : '${row.bookCount} из ${row.capacity}';
    final page = ref.watch(rowProvider(row.id));
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ReorderableDelayedDragStartListener(
                  index: index,
                  enabled: canReorder,
                  child: InkWell(
                    onTap: () => context.push('/home/row/${row.id}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        row.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: row.overfull ? scheme.error : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Вместимость',
                onPressed: () => editRowCapacityFlow(
                  context,
                  ref,
                  rowId: row.id,
                  capacity: row.capacity,
                ),
                icon: const Icon(Icons.pin_outlined),
              ),
              IconButton(
                tooltip: 'Изменить ряд',
                onPressed: () => editRowFlow(
                  context,
                  ref,
                  rowId: row.id,
                  number: row.index + 1,
                  label: row.label ?? '',
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Удалить ряд',
                onPressed: () => deleteRowFlow(
                  context,
                  ref,
                  rowId: row.id,
                  title: row.title,
                ),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          Text(
            row.overfull
                ? '${booksCountLabel(row.bookCount)} · переполнен · $limit'
                : '${booksCountLabel(row.bookCount)} · $limit',
            style: row.overfull ? TextStyle(color: scheme.error) : null,
          ),
          const SizedBox(height: 8),
          page.when(
            data: (data) => SpinePlank(
              books: data?.books ?? const [],
              selecting: selection.active,
              isSelected: selection.isSelected,
              onSelected: selection.toggle,
              onReorder: (orderedIds) {
                return ref.read(libraryRepositoryProvider).reorderBooks(
                  rowId: row.id,
                  orderedIds: orderedIds,
                );
              },
            ),
            loading: () => const SizedBox(
              height: SpinePlank.bandHeight,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SizedBox(
              height: SpinePlank.bandHeight,
              child: Center(child: Text(userFacingError(error))),
            ),
          ),
        ],
      ),
    );
  }
}
