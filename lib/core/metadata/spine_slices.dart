import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:my_library/core/isbn.dart';

/// A gap thinner than this many source pixels is not a book.
const spineMinSlice = 12;

enum SpineTurn { upright, clockwise, counterClockwise }

class SpineSlice {
  const SpineSlice({required this.left, required this.right});

  final int left;
  final int right;

  int get width => right - left;
}

class SpineReading {
  const SpineReading({required this.text, required this.turn});

  final String text;
  final SpineTurn turn;
}

/// Vertical cuts are gaps between spines. The photo edges are included.
/// Slices thinner than [minSlice] are dropped. A photo narrower than that
/// stays one slice so the queue is never empty.
List<SpineSlice> spineSlices({
  required int width,
  required List<int> cuts,
  int minSlice = spineMinSlice,
}) {
  if (width < 1) {
    return const [];
  }
  final points = <int>{0, width};
  for (final cut in cuts) {
    if (cut > 0 && cut < width) {
      points.add(cut);
    }
  }
  final sorted = points.toList()..sort();
  final slices = <SpineSlice>[];
  for (var index = 0; index < sorted.length - 1; index++) {
    final left = sorted[index];
    final right = sorted[index + 1];
    if (right - left >= minSlice) {
      slices.add(SpineSlice(left: left, right: right));
    }
  }
  if (slices.isEmpty) {
    return [SpineSlice(left: 0, right: width)];
  }
  return slices;
}

int narrowSpineGaps({
  required int width,
  required List<int> cuts,
  int minSlice = spineMinSlice,
}) {
  if (width < 1) {
    return 0;
  }
  final points = <int>{0, width};
  for (final cut in cuts) {
    if (cut > 0 && cut < width) {
      points.add(cut);
    }
  }
  final sorted = points.toList()..sort();
  var narrow = 0;
  for (var index = 0; index < sorted.length - 1; index++) {
    if (sorted[index + 1] - sorted[index] < minSlice) {
      narrow += 1;
    }
  }
  return narrow;
}

int readableLetters(String text) {
  return RegExp('[A-Za-zА-Яа-яЁё]').allMatches(text).length;
}

int cyrillicLetters(String text) {
  return RegExp('[А-Яа-яЁё]').allMatches(text).length;
}

/// Drops characters a Russian spine search cannot use.
String readableSpineText(String text) {
  return text
      .replaceAll(RegExp(r'[^0-9A-Za-zА-Яа-яЁё \-–—.,:;«»"()]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// A valid ISBN outranks Russian letters, and Russian letters outrank Latin noise.
int spineReadingScore(String text) {
  final isbn = isbnFromText(text) == null ? 0 : 100000;
  return isbn + cyrillicLetters(text) * 1000 + readableLetters(text);
}

/// Keeps the rotation that reads most like a Russian spine.
SpineReading pickSpineReading(List<SpineReading> readings) {
  SpineReading? best;
  var bestScore = -1;
  for (final reading in readings) {
    final score = spineReadingScore(reading.text);
    if (score > bestScore) {
      best = reading;
      bestScore = score;
    }
  }
  return best ?? const SpineReading(text: '', turn: SpineTurn.upright);
}

/// One catalog query from a spine. Collapses whitespace and keeps it short.
String spineSearchQuery(String text) {
  final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (flat.length <= 80) {
    return flat;
  }
  return flat.substring(0, 80);
}

Uint8List encodeSpineJpeg(img.Image source, SpineSlice slice, SpineTurn turn) {
  final crop = img.copyCrop(
    source,
    x: slice.left,
    y: 0,
    width: slice.width,
    height: source.height,
  );
  final turned = switch (turn) {
    SpineTurn.upright => crop,
    SpineTurn.clockwise => img.copyRotate(crop, angle: 90),
    SpineTurn.counterClockwise => img.copyRotate(crop, angle: 270),
  };
  return Uint8List.fromList(img.encodeJpg(turned, quality: 85));
}
