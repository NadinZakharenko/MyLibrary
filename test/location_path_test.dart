import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/core/format/location_path.dart';

void main() {
  test('formats a placed copy as a 1-based path', () {
    final path = formatLocationPath(
      const LocationParts(
        roomName: 'Гостиная',
        cabinetName: 'Шкаф у окна',
        shelfIndex: 2,
        rowIndex: 1,
        positionIndex: 3,
      ),
    );

    expect(
      path,
      'Гостиная → Шкаф у окна → Полка 3 → Ряд 2 → 4-я слева',
    );
  });

  test('includes an optional shelf label and skips a missing row', () {
    final path = formatLocationPath(
      const LocationParts(
        roomName: ' Кабинет ',
        cabinetName: 'Шкаф',
        shelfIndex: 0,
        shelfLabel: 'нижняя',
        includePosition: false,
      ),
    );

    expect(path, 'Кабинет → Шкаф → Полка 1 · нижняя');
  });

  test('places a row name beside the number and skips a blank name', () {
    final named = formatLocationPath(
      const LocationParts(
        roomName: 'Кабинет',
        cabinetName: 'Шкаф',
        shelfIndex: 1,
        shelfLabel: 'детективы',
        rowIndex: 0,
        rowLabel: 'толстые',
        includePosition: false,
      ),
    );
    expect(named, 'Кабинет → Шкаф → Полка 2 · детективы → Ряд 1 · толстые');

    final blank = formatLocationPath(
      const LocationParts(
        roomName: 'Кабинет',
        cabinetName: 'Шкаф',
        shelfIndex: 1,
        shelfLabel: '  ',
        rowIndex: 0,
        rowLabel: '',
      ),
    );
    expect(blank, 'Кабинет → Шкаф → Полка 2 → Ряд 1');
  });

  test('uses the unplaced label when the shelf is unknown', () {
    expect(
      formatLocationPath(const LocationParts(roomName: 'Гостиная')),
      LocationParts.unplacedLabel,
    );
    expect(LocationParts.unplacedLabel, 'без места');
  });

  test('position labels stay feminine', () {
    expect(leftPositionLabel(0), '1-я слева');
    expect(leftPositionLabel(3), '4-я слева');
  });
}
