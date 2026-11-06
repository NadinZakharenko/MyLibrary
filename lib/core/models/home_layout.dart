import 'dart:convert';

import 'package:my_library/core/models/library_view.dart';

enum HomeBlock { stats, recent, overdue, rooms }

enum HomeStat {
  total,
  week,
  unplaced,
  want,
  reading,
  finished,
  lent,
  overdue,
  library,
  libraryDue,
}

enum HomeCountStyle { cards, bars }

class HomeLayout {
  const HomeLayout({
    required this.blocks,
    required this.stats,
    required this.style,
  });

  final List<HomeBlock> blocks;
  final List<HomeStat> stats;
  final HomeCountStyle style;

  static const fallback = HomeLayout(
    blocks: [
      HomeBlock.stats,
      HomeBlock.recent,
      HomeBlock.overdue,
      HomeBlock.rooms,
    ],
    stats: [
      HomeStat.total,
      HomeStat.week,
      HomeStat.unplaced,
      HomeStat.want,
      HomeStat.reading,
      HomeStat.finished,
      HomeStat.lent,
    ],
    style: HomeCountStyle.cards,
  );

  HomeLayout copyWith({
    List<HomeBlock>? blocks,
    List<HomeStat>? stats,
    HomeCountStyle? style,
  }) {
    return HomeLayout(
      blocks: blocks ?? this.blocks,
      stats: stats ?? this.stats,
      style: style ?? this.style,
    );
  }
}

String homeBlockKey(HomeBlock block) {
  return switch (block) {
    HomeBlock.stats => 'stats',
    HomeBlock.recent => 'recent',
    HomeBlock.overdue => 'overdue',
    HomeBlock.rooms => 'rooms',
  };
}

String homeStatKey(HomeStat stat) {
  return switch (stat) {
    HomeStat.total => 'total',
    HomeStat.week => 'week',
    HomeStat.unplaced => 'unplaced',
    HomeStat.want => 'want',
    HomeStat.reading => 'reading',
    HomeStat.finished => 'finished',
    HomeStat.lent => 'lent',
    HomeStat.overdue => 'overdue',
    HomeStat.library => 'library',
    HomeStat.libraryDue => 'libraryDue',
  };
}

String homeStatLabel(HomeStat stat) {
  return switch (stat) {
    HomeStat.total => 'Всего',
    HomeStat.week => 'За 7 дней',
    HomeStat.unplaced => 'Без места',
    HomeStat.want => 'Хочу прочитать',
    HomeStat.reading => 'Читаю',
    HomeStat.finished => 'Прочитано',
    HomeStat.lent => 'На руках',
    HomeStat.overdue => 'Просрочено',
    HomeStat.library => 'Библиотека',
    HomeStat.libraryDue => 'Вернуть в библиотеку',
  };
}

int homeStatCount(HomeSnapshot data, HomeStat stat) {
  return switch (stat) {
    HomeStat.total => data.totalBooks,
    HomeStat.week => data.addedLast7Days,
    HomeStat.unplaced => data.unplacedBooks,
    HomeStat.want => data.wantToReadCount,
    HomeStat.reading => data.readingCount,
    HomeStat.finished => data.finishedCount,
    HomeStat.lent => data.lentCount,
    HomeStat.overdue => data.overdueLoans.length,
    HomeStat.library => data.libraryBooks,
    HomeStat.libraryDue => data.libraryReturns.length,
  };
}

HomeLayout homeLayoutFromStorage(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return HomeLayout.fallback;
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return HomeLayout.fallback;
    }
    final blocks = _blocks(decoded['blocks']);
    final stats = _stats(decoded['stats']);
    final style = decoded['style'] == 'bars'
        ? HomeCountStyle.bars
        : HomeCountStyle.cards;
    return HomeLayout(
      blocks: blocks.isEmpty ? HomeLayout.fallback.blocks : blocks,
      stats: stats.isEmpty ? HomeLayout.fallback.stats : stats,
      style: style,
    );
  } on FormatException {
    return HomeLayout.fallback;
  }
}

String homeLayoutStorage(HomeLayout layout) {
  return jsonEncode({
    'style': layout.style == HomeCountStyle.bars ? 'bars' : 'cards',
    'blocks': [for (final block in layout.blocks) homeBlockKey(block)],
    'stats': [for (final stat in layout.stats) homeStatKey(stat)],
  });
}

List<HomeBlock> _blocks(Object? value) {
  return _ordered(value, HomeBlock.values, homeBlockKey);
}

List<HomeStat> _stats(Object? value) {
  return _ordered(value, HomeStat.values, homeStatKey);
}

List<T> _ordered<T>(Object? value, List<T> all, String Function(T item) keyOf) {
  if (value is! List) {
    return const [];
  }
  final result = <T>[];
  for (final item in value) {
    if (item is! String) {
      continue;
    }
    for (final candidate in all) {
      if (keyOf(candidate) == item && !result.contains(candidate)) {
        result.add(candidate);
      }
    }
  }
  return result;
}
