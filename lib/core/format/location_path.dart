/// Pieces of a physical location. Shelf and row indexes are 0-based.
class LocationParts {
  const LocationParts({
    this.roomName,
    this.cabinetName,
    this.shelfIndex,
    this.shelfLabel,
    this.rowIndex,
    this.rowLabel,
    this.positionIndex,
    this.includePosition = true,
  });

  final String? roomName;
  final String? cabinetName;
  final int? shelfIndex;
  final String? shelfLabel;
  final int? rowIndex;
  final String? rowLabel;
  final int? positionIndex;
  final bool includePosition;

  bool get isPlaced =>
      roomName != null &&
      roomName!.trim().isNotEmpty &&
      cabinetName != null &&
      cabinetName!.trim().isNotEmpty &&
      shelfIndex != null;

  static const unplacedLabel = 'без места';
}

/// Example: «Гостиная → Шкаф у окна → Полка 3 → Ряд 2 → 4-я слева».
/// A name, when there is one, sits beside the number: «Полка 2 · детективы».
String formatLocationPath(LocationParts parts) {
  if (!parts.isPlaced) {
    return LocationParts.unplacedLabel;
  }

  final segments = <String>[
    parts.roomName!.trim(),
    parts.cabinetName!.trim(),
    shelfPlaceTitle(parts.shelfIndex!, parts.shelfLabel),
  ];

  if (parts.rowIndex != null) {
    segments.add(rowPlaceTitle(parts.rowIndex!, parts.rowLabel));
  }
  if (parts.includePosition && parts.positionIndex != null) {
    segments.add(leftPositionLabel(parts.positionIndex!));
  }
  return segments.join(' → ');
}

/// «Полка 2» or «Полка 2 · детективы». [zeroBasedIndex] is the place from the top.
String shelfPlaceTitle(int zeroBasedIndex, String? label) {
  return _numberedPlace('Полка', zeroBasedIndex, label);
}

/// «Ряд 1» or «Ряд 1 · толстые». [zeroBasedIndex] is the place from the top.
String rowPlaceTitle(int zeroBasedIndex, String? label) {
  return _numberedPlace('Ряд', zeroBasedIndex, label);
}

String _numberedPlace(String kind, int zeroBasedIndex, String? label) {
  final number = zeroBasedIndex + 1;
  final name = label?.trim();
  if (name != null && name.isNotEmpty) {
    return '$kind $number · $name';
  }
  return '$kind $number';
}

/// 0-based position on a row, shown as «1-я слева», «4-я слева».
String leftPositionLabel(int zeroBasedIndex) {
  return '${zeroBasedIndex + 1}-я слева';
}
