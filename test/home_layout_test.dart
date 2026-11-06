import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/core/models/home_layout.dart';

void main() {
  test('keeps a saved order and ignores an unknown group', () {
    final layout = homeLayoutFromStorage(
      '{"style":"bars","blocks":["rooms","nope","stats"],"stats":["lent","overdue","lent"]}',
    );

    expect(layout.style, HomeCountStyle.bars);
    expect(layout.blocks, [HomeBlock.rooms, HomeBlock.stats]);
    expect(layout.stats, [HomeStat.lent, HomeStat.overdue]);
  });

  test('uses the current groups when nothing is saved', () {
    final layout = homeLayoutFromStorage(null);

    expect(layout.style, HomeCountStyle.cards);
    expect(layout.blocks, HomeLayout.fallback.blocks);
    expect(layout.stats, isNot(contains(HomeStat.overdue)));
    expect(homeLayoutFromStorage(homeLayoutStorage(layout)).stats, layout.stats);
  });
}
