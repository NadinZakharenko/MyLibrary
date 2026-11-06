enum ShelfModelChoice { off, kimi, yandex }

ShelfModelChoice? shelfModelFromStorage(String? value) {
  return switch (value) {
    'off' => ShelfModelChoice.off,
    'kimi' => ShelfModelChoice.kimi,
    'yandex' => ShelfModelChoice.yandex,
    _ => null,
  };
}

String shelfModelStorage(ShelfModelChoice choice) {
  return switch (choice) {
    ShelfModelChoice.off => 'off',
    ShelfModelChoice.kimi => 'kimi',
    ShelfModelChoice.yandex => 'yandex',
  };
}

bool shelfModelReadsPhotos(ShelfModelChoice choice) {
  return switch (choice) {
    ShelfModelChoice.off => false,
    ShelfModelChoice.kimi => true,
    ShelfModelChoice.yandex => true,
  };
}

String shelfModelLabel(ShelfModelChoice choice) {
  return switch (choice) {
    ShelfModelChoice.off => 'Не использовать',
    ShelfModelChoice.kimi => 'Kimi',
    ShelfModelChoice.yandex => 'Яндекс',
  };
}

class ShelfModelConnection {
  const ShelfModelConnection({
    required this.choice,
    required this.consent,
    required this.kimiKey,
    required this.yandexKey,
    required this.folderId,
  });

  final ShelfModelChoice choice;
  final bool consent;
  final String kimiKey;
  final String yandexKey;
  final String folderId;

  bool get canAskText {
    return switch (choice) {
      ShelfModelChoice.off => false,
      ShelfModelChoice.kimi => kimiKey.isNotEmpty,
      ShelfModelChoice.yandex => yandexKey.isNotEmpty && folderId.isNotEmpty,
    };
  }

  bool get canReadPhoto => consent && canAskText;
}
