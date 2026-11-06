import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_library/core/format/russian_plural.dart';
import 'package:my_library/core/models/home_layout.dart';
import 'package:my_library/core/models/library_view.dart';
import 'package:my_library/features/library/structure_actions.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/common_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider);
    final layout =
        ref.watch(homeLayoutProvider).asData?.value ?? HomeLayout.fallback;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Моя библиотека'),
        actions: [
          IconButton(
            tooltip: 'Сводка',
            onPressed: () => _editLayout(context, ref, layout),
            icon: const Icon(Icons.tune),
          ),
          IconButton(
            tooltip: 'Порядок комнат',
            onPressed: () async {
              final rooms = home.asData?.value.rooms ?? const [];
              await reorderFlow(
                context,
                title: 'Порядок комнат',
                items: [
                  for (final room in rooms) (id: room.id, label: room.name),
                ],
                onSubmit: (ids) =>
                    ref.read(libraryRepositoryProvider).reorderRooms(ids),
              );
            },
            icon: const Icon(Icons.swap_vert),
          ),
          IconButton(
            tooltip: 'Новая комната',
            onPressed: () => createRoomFlow(context, ref),
            icon: const Icon(Icons.add_home_outlined),
          ),
        ],
      ),
      body: AsyncBody(
        value: home,
        onRetry: () => ref.invalidate(homeProvider),
        data: (data) => ReorderableListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          buildDefaultDragHandles: false,
          onReorderItem: (oldIndex, newIndex) async {
            final blocks = [...layout.blocks];
            final moved = blocks.removeAt(oldIndex);
            blocks.insert(newIndex, moved);
            await ref.read(libraryRepositoryProvider).setHomeLayout(
              layout.copyWith(blocks: blocks),
            );
          },
          children: [
            for (var index = 0; index < layout.blocks.length; index++)
              _HomeBlock(
                key: ValueKey(layout.blocks[index]),
                index: index,
                block: layout.blocks[index],
                data: data,
                layout: layout,
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeBlock extends ConsumerWidget {
  const _HomeBlock({
    super.key,
    required this.index,
    required this.block,
    required this.data,
    required this.layout,
  });

  final int index;
  final HomeBlock block;
  final HomeSnapshot data;
  final HomeLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: switch (block) {
        HomeBlock.stats => _StatsBlock(index: index, data: data, layout: layout),
        HomeBlock.recent => _RecentBlock(index: index, data: data),
        HomeBlock.overdue => _OverdueBlock(index: index, data: data),
        HomeBlock.rooms => _RoomsBlock(index: index, data: data),
      },
    );
  }
}

class _BlockTitle extends StatelessWidget {
  const _BlockTitle({required this.index, required this.title});

  final int index;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ReorderableDragStartListener(
          index: index,
          child: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.drag_handle),
          ),
        ),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
      ],
    );
  }
}

class _StatsBlock extends ConsumerWidget {
  const _StatsBlock({
    required this.index,
    required this.data,
    required this.layout,
  });

  final int index;
  final HomeSnapshot data;
  final HomeLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxCount = layout.stats.fold<int>(
      0,
      (max, stat) {
        final count = homeStatCount(data, stat);
        return count > max ? count : max;
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BlockTitle(index: index, title: 'Сводка'),
        const SizedBox(height: 8),
        if (layout.stats.isEmpty)
          const Text('Все группы скрыты. Их можно вернуть кнопкой «Сводка».')
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorderItem: (oldIndex, newIndex) async {
              final stats = [...layout.stats];
              final moved = stats.removeAt(oldIndex);
              stats.insert(newIndex, moved);
              await ref.read(libraryRepositoryProvider).setHomeLayout(
                layout.copyWith(stats: stats),
              );
            },
            children: [
              for (var statIndex = 0; statIndex < layout.stats.length; statIndex++)
                _StatLine(
                  key: ValueKey(layout.stats[statIndex]),
                  stat: layout.stats[statIndex],
                  count: homeStatCount(data, layout.stats[statIndex]),
                  maxCount: maxCount,
                  style: layout.style,
                  index: statIndex,
                ),
            ],
          ),
      ],
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({
    super.key,
    required this.stat,
    required this.count,
    required this.maxCount,
    required this.style,
    required this.index,
  });

  final HomeStat stat;
  final int count;
  final int maxCount;
  final HomeCountStyle style;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = maxCount == 0 ? 0.0 : count / maxCount;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: InkWell(
          onTap: () => _open(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.drag_handle),
                  ),
                ),
                Expanded(
                  child: switch (style) {
                    HomeCountStyle.cards => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$count', style: theme.textTheme.headlineSmall),
                        Text(homeStatLabel(stat)),
                      ],
                    ),
                    HomeCountStyle.bars => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${homeStatLabel(stat)} · $count'),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(value: fraction),
                      ],
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    if (stat == HomeStat.unplaced) {
      context.push('/home/unplaced');
      return;
    }
    context.push('/home/group/${homeStatKey(stat)}');
  }
}

class _RecentBlock extends StatelessWidget {
  const _RecentBlock({required this.index, required this.data});

  final int index;
  final HomeSnapshot data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BlockTitle(index: index, title: 'Недавно'),
        const SizedBox(height: 8),
        if (data.recent.isEmpty)
          const Text('Пока нет книг. Добавьте первую с вкладки «Добавить».')
        else
          SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: data.recent.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final book = data.recent[index];
                return InkWell(
                  onTap: () => context.push('/book/${book.id}'),
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 108,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CoverImage(
                          relativePath: book.coverPath,
                          width: 108,
                          height: 120,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _OverdueBlock extends StatelessWidget {
  const _OverdueBlock({required this.index, required this.data});

  final int index;
  final HomeSnapshot data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BlockTitle(index: index, title: 'Просрочено'),
        const SizedBox(height: 8),
        if (data.overdueLoans.isEmpty)
          const Text('Просроченных выдач нет.')
        else
          for (final book in data.overdueLoans)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(book.title),
              subtitle: Text(
                [
                  if (book.loanPerson.trim().isNotEmpty) 'У ${book.loanPerson}',
                  if (book.loanDueAt != null) formatDay(book.loanDueAt!),
                  book.locationPath,
                ].join(' · '),
              ),
              onTap: () => context.push('/book/${book.id}'),
            ),
      ],
    );
  }
}

class _RoomsBlock extends ConsumerWidget {
  const _RoomsBlock({required this.index, required this.data});

  final int index;
  final HomeSnapshot data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BlockTitle(index: index, title: 'Комнаты'),
        const SizedBox(height: 8),
        if (data.rooms.isEmpty)
          EmptyState(
            icon: Icons.meeting_room_outlined,
            title: 'Комнат пока нет',
            message: 'Комната собирает шкафы. Полки в шкафу идут сверху вниз.',
            actionLabel: 'Добавить комнату',
            onAction: () => createRoomFlow(context, ref),
          )
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorderItem: (oldIndex, newIndex) async {
              final ids = [for (final room in data.rooms) room.id];
              final moved = ids.removeAt(oldIndex);
              ids.insert(newIndex, moved);
              await ref.read(libraryRepositoryProvider).reorderRooms(ids);
            },
            children: [
              for (var roomIndex = 0; roomIndex < data.rooms.length; roomIndex++)
                _RoomBlock(
                  key: ValueKey(data.rooms[roomIndex].id),
                  room: data.rooms[roomIndex],
                  index: roomIndex,
                ),
            ],
          ),
      ],
    );
  }
}

class _RoomBlock extends ConsumerWidget {
  const _RoomBlock({super.key, required this.room, required this.index});

  final RoomOverview room;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columnHeight = room.cabinets.fold<double>(140, (height, cabinet) {
      final next = 120.0 + cabinet.shelves.length * 46;
      return next > height ? next : height;
    });
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    room.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                PopupMenuButton<_RoomAction>(
                  onSelected: (action) => _onAction(context, ref, action),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _RoomAction.rename,
                      child: Text('Переименовать'),
                    ),
                    PopupMenuItem(
                      value: _RoomAction.addCabinet,
                      child: Text('Добавить шкаф'),
                    ),
                    PopupMenuItem(
                      value: _RoomAction.reorder,
                      child: Text('Порядок шкафов'),
                    ),
                    PopupMenuItem(
                      value: _RoomAction.delete,
                      child: Text('Удалить'),
                    ),
                  ],
                ),
              ],
            ),
            if (room.note.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(room.note),
              ),
            if (room.cabinets.isEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => createCabinetFlow(context, ref, roomId: room.id),
                  child: const Text('Добавить шкаф'),
                ),
              )
            else
              SizedBox(
                height: columnHeight,
                child: ReorderableListView(
                  scrollDirection: Axis.horizontal,
                  buildDefaultDragHandles: false,
                  onReorderItem: (oldIndex, newIndex) async {
                    final ids = [for (final cabinet in room.cabinets) cabinet.id];
                    final moved = ids.removeAt(oldIndex);
                    ids.insert(newIndex, moved);
                    await ref.read(libraryRepositoryProvider).reorderCabinets(
                      roomId: room.id,
                      orderedIds: ids,
                    );
                  },
                  children: [
                    for (var cabinetIndex = 0;
                        cabinetIndex < room.cabinets.length;
                        cabinetIndex++)
                      _CabinetColumn(
                        key: ValueKey(room.cabinets[cabinetIndex].id),
                        cabinet: room.cabinets[cabinetIndex],
                        index: cabinetIndex,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    _RoomAction action,
  ) async {
    switch (action) {
      case _RoomAction.rename:
        await renameRoomFlow(
          context,
          ref,
          id: room.id,
          name: room.name,
          note: room.note,
        );
      case _RoomAction.addCabinet:
        await createCabinetFlow(context, ref, roomId: room.id);
      case _RoomAction.reorder:
        await reorderFlow(
          context,
          title: 'Порядок шкафов',
          items: [
            for (final cabinet in room.cabinets)
              (id: cabinet.id, label: cabinet.name),
          ],
          onSubmit: (ids) => ref.read(libraryRepositoryProvider).reorderCabinets(
            roomId: room.id,
            orderedIds: ids,
          ),
        );
      case _RoomAction.delete:
        await deleteRoomFlow(context, ref, id: room.id, name: room.name);
    }
  }
}

enum _RoomAction { rename, addCabinet, reorder, delete }

class _CabinetColumn extends StatelessWidget {
  const _CabinetColumn({super.key, required this.cabinet, required this.index});

  final CabinetOverview cabinet;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => context.push('/home/cabinet/${cabinet.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 132,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle),
              ),
              Text(
                cabinet.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (cabinet.shelves.isEmpty)
                const Text('Нет полок')
              else
                for (final shelf in cabinet.shelves)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: shelf.overfull
                          ? theme.colorScheme.errorContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (shelf.overfull) ...[
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          '${shelf.bookCount}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: shelf.overfull
                                ? theme.colorScheme.onErrorContainer
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
              Text(
                booksCountLabel(
                  cabinet.shelves.fold(0, (sum, shelf) => sum + shelf.bookCount),
                ),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _editLayout(
  BuildContext context,
  WidgetRef ref,
  HomeLayout layout,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _LayoutSheet(initial: layout),
  );
}

class _LayoutSheet extends ConsumerStatefulWidget {
  const _LayoutSheet({required this.initial});

  final HomeLayout initial;

  @override
  ConsumerState<_LayoutSheet> createState() => _LayoutSheetState();
}

class _LayoutSheetState extends ConsumerState<_LayoutSheet> {
  late HomeLayout _layout = widget.initial;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shrinkWrap: true,
        children: [
          Text('Количество книг', style: Theme.of(context).textTheme.titleLarge),
          RadioGroup<HomeCountStyle>(
            groupValue: _layout.style,
            onChanged: (value) {
              if (value != null) {
                _set(_layout.copyWith(style: value));
              }
            },
            child: const Column(
              children: [
                RadioListTile<HomeCountStyle>(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Блоки'),
                  value: HomeCountStyle.cards,
                ),
                RadioListTile<HomeCountStyle>(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Гистограмма'),
                  value: HomeCountStyle.bars,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Состав записей', style: Theme.of(context).textTheme.titleMedium),
          for (final stat in HomeStat.values)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(homeStatLabel(stat)),
              value: _layout.stats.contains(stat),
              onChanged: (checked) {
                final stats = [..._layout.stats];
                if (checked ?? false) {
                  if (!stats.contains(stat)) {
                    stats.add(stat);
                  }
                } else {
                  stats.remove(stat);
                }
                _set(_layout.copyWith(stats: stats));
              },
            ),
          const SizedBox(height: 8),
          Text('Блоки страницы', style: Theme.of(context).textTheme.titleMedium),
          for (final block in HomeBlock.values)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_blockLabel(block)),
              value: _layout.blocks.contains(block),
              onChanged: (checked) {
                final blocks = [..._layout.blocks];
                if (checked ?? false) {
                  if (!blocks.contains(block)) {
                    blocks.add(block);
                  }
                } else {
                  blocks.remove(block);
                }
                _set(_layout.copyWith(blocks: blocks));
              },
            ),
        ],
      ),
    );
  }

  Future<void> _set(HomeLayout layout) async {
    setState(() => _layout = layout);
    await ref.read(libraryRepositoryProvider).setHomeLayout(layout);
  }

  String _blockLabel(HomeBlock block) {
    return switch (block) {
      HomeBlock.stats => 'Сводка',
      HomeBlock.recent => 'Недавно',
      HomeBlock.overdue => 'Просрочено',
      HomeBlock.rooms => 'Комнаты',
    };
  }
}
