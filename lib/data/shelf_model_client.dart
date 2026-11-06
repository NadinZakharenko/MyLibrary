import 'dart:typed_data';

import 'package:my_library/core/metadata/model_book.dart';
import 'package:my_library/core/metadata/shelf_reading.dart';
import 'package:my_library/core/models/metadata_candidate.dart';
import 'package:my_library/core/models/shelf_model.dart';
import 'package:my_library/data/kimi_shelf_reader.dart';
import 'package:my_library/data/library_repository.dart';
import 'package:my_library/data/yandex_shelf_reader.dart';

Future<List<MetadataCandidate>> askConnectedModel({
  required LibraryRepository repository,
  required KimiShelfReader kimi,
  required YandexShelfReader yandex,
  String? isbn,
  String? title,
  String? author,
}) async {
  final connection = await repository.shelfConnection();
  final titleText = title?.trim() ?? '';
  final authorText = author?.trim() ?? '';
  final isbnText = isbn?.trim() ?? '';
  if (!connection.canAskText) {
    return const [];
  }
  if (isbnText.isEmpty && titleText.isEmpty && authorText.isEmpty) {
    return const [];
  }
  final prompt = modelBookPrompt(
    isbn: isbnText,
    title: titleText,
    author: authorText,
  );
  final text = await switch (connection.choice) {
    ShelfModelChoice.off => throw StateError('Модель не выбрана'),
    ShelfModelChoice.kimi => kimi.ask(apiKey: connection.kimiKey, prompt: prompt),
    ShelfModelChoice.yandex => yandex.ask(
      apiKey: connection.yandexKey,
      folderId: connection.folderId,
      prompt: prompt,
    ),
  };
  return candidatesFromModel(text);
}

Future<RecognizedSpine?> readShelfSpine({
  required ShelfModelConnection connection,
  required Uint8List jpeg,
  required KimiShelfReader kimi,
  required YandexShelfReader yandex,
}) async {
  if (!connection.canReadPhoto) {
    return null;
  }
  final shelves = await switch (connection.choice) {
    ShelfModelChoice.off => throw StateError('Модель не выбрана'),
    ShelfModelChoice.kimi => kimi.read(jpeg: jpeg, apiKey: connection.kimiKey),
    ShelfModelChoice.yandex => yandex.read(
      jpeg: jpeg,
      apiKey: connection.yandexKey,
      folderId: connection.folderId,
    ),
  };
  for (final shelf in shelves) {
    for (final book in shelf.books) {
      if (book.title.isNotEmpty || book.author.isNotEmpty) {
        return book;
      }
    }
  }
  return null;
}
