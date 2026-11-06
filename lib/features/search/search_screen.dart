import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_library/core/format/copy_notes.dart';
import 'package:my_library/core/models/book_copy.dart';
import 'package:my_library/core/models/library_view.dart';
import 'package:my_library/core/search/book_search.dart';
import 'package:my_library/features/books/book_bulk.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/common_widgets.dart';
import 'package:my_library/ui/open_shelf.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _query = TextEditingController();
  int? _roomId;
  int? _cabinetId;
  String? _hashtag;
  BookFormat? _format;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeProvider);
    final index = ref.watch(searchIndexProvider);
    final tags = ref.watch(hashtagsProvider);
    final rooms = home.asData?.value.rooms ?? const <RoomOverview>[];
    final records = index.asData?.value;
    return BookSelectionHost(
      builder: (context, selection) => Scaffold(
      appBar: AppBar(
        title: const Text('Поиск'),
        actions: [BookSelectionButton(selection: selection)],
      ),
      bottomNavigationBar: BookBulkBar(selection: selection),
      body: records == null
          ? AsyncBody(
              value: index,
              onRetry: () => ref.invalidate(searchIndexProvider),
              data: (_) => const SizedBox.shrink(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    children: [
                      TextField(
                        controller: _query,
                        decoration: const InputDecoration(
                          labelText: 'Название, автор, серия, хештег…',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Все'),
                            selected: _format == null,
                            onSelected: (_) => setState(() => _format = null),
                          ),
                          ChoiceChip(
                            label: const Text('Печатные'),
                            selected: _format == BookFormat.print,
                            onSelected: (_) => setState(() => _format = BookFormat.print),
                          ),
                          ChoiceChip(
                            label: const Text('Аудио'),
                            selected: _format == BookFormat.audio,
                            onSelected: (_) => setState(() => _format = BookFormat.audio),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _filter<int?>(
                              label: 'Комната',
                              value: _roomId,
                              items: [
                                const _FilterItem<int?>(null, 'Все комнаты'),
                                for (final room in rooms)
                                  _FilterItem<int?>(room.id, room.name),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _roomId = value;
                                  _cabinetId = null;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _filter<int?>(
                              label: 'Шкаф',
                              value: _cabinetId,
                              items: [
                                const _FilterItem<int?>(null, 'Все шкафы'),
                                for (final room in rooms)
                                  if (_roomId == null || room.id == _roomId)
                                    for (final cabinet in room.cabinets)
                                      _FilterItem<int?>(cabinet.id, cabinet.name),
                              ],
                              onChanged: (value) =>
                                  setState(() => _cabinetId = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _filter<String?>(
                        label: 'Хештег',
                        value: _hashtag,
                        items: [
                          const _FilterItem<String?>(null, 'Все хештеги'),
                          for (final tag in tags.asData?.value ?? const <String>[])
                            _FilterItem<String?>(tag, '#$tag'),
                        ],
                        onChanged: (value) => setState(() => _hashtag = value),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _results(records, selection)),
              ],
            ),
      ),
    );
  }

  Widget _results(List<BookSearchRecord> records, BookSelectionController selection) {
    final found = filterBooks(
      records,
      SearchFilter(
        query: _query.text,
        roomId: _roomId,
        cabinetId: _cabinetId,
        hashtag: _hashtag,
        format: _format,
      ),
    );
    if (found.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'Ничего не найдено',
        message: 'Попробуйте другое слово или снимите фильтр.',
      );
    }
    return ListView.builder(
      itemCount: found.length,
      itemBuilder: (context, index) {
        final book = found[index];
        final selecting = selection.active;
        return BookSummaryTile(
          title: book.title,
          authors: book.authorsLabel,
          genres: book.genres.join(', '),
          location: book.locationPath,
          coverPath: book.coverPath,
          selecting: selecting,
          selected: selection.isSelected(book.id),
          notes: copyNotes(
            readingStatus: book.readingStatus,
            seriesName: book.seriesName,
            includeLoan: false,
          ),
          onLocationTap: selecting || book.cabinetId == null
              ? null
              : () => openCabinetAtShelf(
                  context,
                  cabinetId: book.cabinetId,
                  shelfId: book.shelfId,
                ),
          onTap: () {
            if (selecting) {
              selection.toggle(book.id);
              return;
            }
            context.push('/book/${book.id}');
          },
        );
      },
    );
  }
}

class _FilterItem<T> {
  const _FilterItem(this.value, this.label);

  final T value;
  final String label;
}

Widget _filter<T>({
  required String label,
  required T value,
  required List<_FilterItem<T>> items,
  required ValueChanged<T?> onChanged,
}) {
  final known = items.any((item) => item.value == value);
  return InputDecorator(
    decoration: InputDecoration(labelText: label),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        isExpanded: true,
        value: known ? value : null,
        items: [
          for (final item in items)
            DropdownMenuItem<T>(value: item.value, child: Text(item.label)),
        ],
        onChanged: onChanged,
      ),
    ),
  );
}
