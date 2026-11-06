import 'package:http/http.dart' as http;
import 'package:my_library/core/models/book_copy.dart';
import 'package:my_library/core/models/book_draft.dart';
import 'package:my_library/core/models/reading_status.dart';
import 'package:my_library/core/storage/image_store.dart';
import 'package:my_library/data/library_repository.dart';
import 'package:my_library/data/yandex_books_client.dart';

Future<String> importYandexAudiobooks({
  required LibraryRepository repository,
  required ImageStore images,
  YandexBooksClient? client,
}) async {
  final books = client ?? const YandexBooksClient();
  final token = (await repository.yandexBooksToken())?.trim() ?? '';
  final stored = await repository.yandexBooksProfile();
  final profile = await books.profileId(token: token, publicId: stored);
  await repository.setYandexBooksProfile(profile);
  final remote = await books.finishedAudiobooks(profileId: profile, token: token);
  if (remote.isEmpty) {
    return token.isEmpty
        ? 'Публичных аудиокниг не найдено.'
        : 'Среди прослушанных карточек нет аудиокниг.';
  }
  var created = 0;
  var updated = 0;
  for (final item in remote) {
    final coverPath = await _cover(images, item.coverUrl);
    final existing = await repository.bookByYandexId(item.id);
    if (existing == null) {
      await repository.createBook(
        BookDraft(
          format: BookFormat.audio,
          title: item.title,
          authors: item.authors,
          narrator: item.narrators.join(', '),
          durationSeconds: item.durationSeconds,
          description: item.annotation,
          yandexId: item.id,
          sourceUrl: yandexAudiobookUrl(item.id),
          coverPath: coverPath,
          readingStatus: ReadingStatus.finished,
        ),
      );
      created += 1;
      continue;
    }
    final details = await repository.bookDetails(existing.id);
    await repository.updateBook(
      existing.id,
      BookDraft(
        format: BookFormat.audio,
        title: item.title,
        authors: item.authors,
        genres: details?.genres ?? const [],
        hashtags: details?.hashtags ?? const [],
        personalNote: details?.personalNote ?? '',
        narrator: item.narrators.join(', '),
        durationSeconds: item.durationSeconds,
        description: item.annotation,
        yandexId: item.id,
        sourceUrl: yandexAudiobookUrl(item.id),
        coverPath: coverPath ?? details?.coverPath,
        readingStatus: ReadingStatus.finished,
        statusChangedAt: details?.statusChangedAt,
      ),
    );
    updated += 1;
  }
  return 'Аудиокниги Яндекса: новых $created, обновлено $updated.';
}

Future<String?> _cover(ImageStore images, String? url) async {
  if (url == null || url.isEmpty) {
    return null;
  }
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
      return null;
    }
    return await images.saveBytes(response.bodyBytes, cover: true);
  } catch (_) {
    return null;
  }
}
