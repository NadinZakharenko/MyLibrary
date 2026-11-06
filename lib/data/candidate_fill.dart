import 'package:my_library/core/models/book_copy.dart';
import 'package:my_library/core/models/book_draft.dart';
import 'package:my_library/core/models/metadata_candidate.dart';
import 'package:my_library/core/storage/image_store.dart';
import 'package:my_library/data/metadata_service.dart';

Future<BookDraft> fillDraftFromCandidate({
  required BookDraft seed,
  required MetadataCandidate candidate,
  required MetadataService metadata,
  required ImageStore images,
}) async {
  final enriched = candidate;
  var coverPath = seed.coverPath;
  final coverUrl = enriched.coverUrl;
  if (coverUrl != null) {
    final bytes = await metadata.download(Uri.parse(coverUrl));
    if (bytes != null) {
      coverPath = await images.saveBytes(bytes, cover: true);
    }
  }
  return seed.copyWith(
    title: enriched.title,
    subtitle: enriched.subtitle,
    description: enriched.description,
    isbn: enriched.isbn.isEmpty ? seed.isbn : enriched.isbn,
    authors: enriched.authors.isEmpty ? seed.authors : enriched.authors,
    genres: enriched.genres,
    publishers: enriched.publisher.trim().isEmpty
        ? seed.publishers
        : [enriched.publisher.trim()],
    sourceUrl: enriched.sourceUrl ?? seed.sourceUrl,
    seriesName: enriched.seriesName.trim().isEmpty
        ? seed.seriesName
        : enriched.seriesName.trim(),
    seriesVolume: enriched.seriesVolume ?? seed.seriesVolume,
    coverPath: coverPath,
    candidates: const [],
    format: catalogAudio(enriched) ? BookFormat.audio : seed.format,
    yandexId: catalogYandexId(seed, enriched),
    narrator: enriched.narrator.trim().isEmpty
        ? seed.narrator
        : enriched.narrator.trim(),
  );
}

bool catalogAudio(MetadataCandidate candidate) {
  return candidate.source == MetadataSource.yandexBooks &&
      (candidate.sourceUrl?.contains('/audiobooks/') ?? false);
}

String catalogYandexId(BookDraft seed, MetadataCandidate candidate) {
  if (!catalogAudio(candidate)) {
    return seed.yandexId;
  }
  final id = candidate.workKey?.trim() ?? '';
  if (id.isEmpty) {
    return seed.yandexId;
  }
  return id;
}
