import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_library/core/format/copy_notes.dart';
import 'package:my_library/core/models/book_copy.dart';
import 'package:my_library/core/models/home_layout.dart';
import 'package:my_library/core/models/library_view.dart';
import 'package:my_library/features/books/book_bulk.dart';
import 'package:my_library/features/library/structure_actions.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/common_widgets.dart';
import 'package:my_library/ui/open_book.dart';
import 'package:my_library/ui/spine_plank.dart';

class RowBooksScreen extends ConsumerWidget {
  const RowBooksScreen({super.key, required this.rowId});

  final int rowId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(rowProvider(rowId));
    return AsyncBody(
      value: page,
      onRetry: () => ref.invalidate(rowProvider(rowId)),
      data: (data) {
        if (data == null) {
          return const Scaffold(
            body: EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Ряд не найден',
            ),
          );
        }
        return BookSelectionHost(
          builder: (context, selection) => Scaffold(
          appBar: AppBar(
            title: Text('${data.shelf.title}, ${data.row.title}'),
            actions: [
              if (data.books.isNotEmpty)
                BookSelectionButton(selection: selection),
              IconButton(
                tooltip: 'Изменить ряд',
                onPressed: () => editRowFlow(
                  context,
                  ref,
                  rowId: data.row.id,
                  number: data.row.index + 1,
                  label: data.row.label ?? '',
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          bottomNavigationBar: BookBulkBar(selection: selection),
          body: data.books.isEmpty
              ? EmptyState(
                  icon: Icons.menu_book_outlined,
                  title: 'На этом ряду пока нет книг',
                  message:
                      '${data.roomName} → ${data.cabinetName}. Верх списка — левый край ряда.',
                  actionLabel: 'Добавить книгу',
                  onAction: () => context.go('/add'),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${data.roomName} → ${data.cabinetName}'),
                          if (data.row.overfull) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Ряд переполнен: ${data.row.bookCount} из ${data.row.capacity}.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                          TextButton(
                            onPressed: () => editRowCapacityFlow(
                              context,
                              ref,
                              rowId: data.row.id,
                              capacity: data.row.capacity,
                            ),
                            child: Text(
                              data.row.capacity == null
                                  ? 'Вместимость не задана'
                                  : 'Вместимость: ${data.row.capacity}',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SpinePlank(
                          books: data.books,
                          selecting: selection.active,
                          isSelected: selection.isSelected,
                          onSelected: selection.toggle,
                          onReorder: (orderedIds) {
                            return ref.read(libraryRepositoryProvider).reorderBooks(
                              rowId: rowId,
                              orderedIds: orderedIds,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
          ),
        );
      },
    );
  }
}

class UnplacedBooksScreen extends ConsumerWidget {
  const UnplacedBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(unplacedProvider);
    return BookSelectionHost(
      builder: (context, selection) => Scaffold(
      appBar: AppBar(
        title: const Text('Без места'),
        actions: [BookSelectionButton(selection: selection)],
      ),
      bottomNavigationBar: BookBulkBar(selection: selection),
      body: AsyncBody(
        value: books,
        onRetry: () => ref.invalidate(unplacedProvider),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_outlined,
              title: 'Все книги стоят на полках',
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) =>
                _BookRow(book: items[index], selection: selection),
          );
        },
      ),
      ),
    );
  }
}

class HomeGroupScreen extends ConsumerWidget {
  const HomeGroupScreen({super.key, required this.stat});

  final HomeStat stat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(homeStatProvider(stat));
    return BookSelectionHost(
      builder: (context, selection) => Scaffold(
      appBar: AppBar(
        title: Text(homeStatLabel(stat)),
        actions: [BookSelectionButton(selection: selection)],
      ),
      bottomNavigationBar: BookBulkBar(selection: selection),
      body: AsyncBody(
        value: books,
        onRetry: () => ref.invalidate(homeStatProvider(stat)),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'В этой группе нет книг',
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) =>
                _BookRow(book: items[index], selection: selection),
          );
        },
      ),
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow({required this.book, required this.selection});

  final BookSummary book;
  final BookSelectionController selection;

  @override
  Widget build(BuildContext context) {
    final selecting = selection.active;
    return BookSummaryTile(
      title: book.title,
      authors: book.authorsLabel,
      genres: book.genresLabel,
      location: book.locationPath,
      coverPath: book.coverPath,
      selecting: selecting,
      selected: selection.isSelected(book.id),
      notes: copyNotes(
        readingStatus: book.readingStatus,
        seriesName: book.seriesName,
        seriesVolume: book.seriesVolume,
        loanPerson: book.loanPerson,
        loanDueAt: book.loanDueAt,
      ),
      onTap: () {
        if (selecting) {
          selection.toggle(book.id, audio: book.format == BookFormat.audio);
          return;
        }
        openBook(context, book.id);
      },
    );
  }
}
