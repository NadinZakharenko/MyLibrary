import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:my_library/core/metadata/spine_slices.dart';

void main() {
  test('drops a gap thinner than 12 pixels and keeps the books beside it', () {
    final slices = spineSlices(width: 100, cuts: const [30, 34, 70]);

    expect(slices.map((slice) => (slice.left, slice.right)), [
      (0, 30),
      (34, 70),
      (70, 100),
    ]);
    expect(narrowSpineGaps(width: 100, cuts: const [30, 34, 70]), 1);
  });

  test('a photo with no room for a slice stays one piece', () {
    final slices = spineSlices(width: 8, cuts: const [4]);

    expect(slices.single.left, 0);
    expect(slices.single.right, 8);
  });

  test('picks the rotation with more letters', () {
    const readings = [
      SpineReading(text: 'III', turn: SpineTurn.upright),
      SpineReading(text: 'Мастер и Маргарита', turn: SpineTurn.clockwise),
      SpineReading(text: 'abc', turn: SpineTurn.counterClockwise),
    ];

    expect(pickSpineReading(readings).turn, SpineTurn.clockwise);
    expect(readableLetters('Ёж'), 2);
    expect(spineSearchQuery('  Мастер \n и   Маргарита  '), 'Мастер и Маргарита');
    expect(
      pickSpineReading(const [
        SpineReading(text: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', turn: SpineTurn.upright),
        SpineReading(text: 'Мир', turn: SpineTurn.clockwise),
      ]).turn,
      SpineTurn.clockwise,
    );
    expect(readableSpineText('战争 Мир 123'), 'Мир 123');
  });

  test('crops a spine and can turn it sideways', () {
    final source = img.Image(width: 40, height: 10);
    final bytes = encodeSpineJpeg(
      source,
      const SpineSlice(left: 10, right: 25),
      SpineTurn.clockwise,
    );
    final turned = img.decodeImage(Uint8List.fromList(bytes))!;

    expect(turned.width, 10);
    expect(turned.height, 15);
  });
}
