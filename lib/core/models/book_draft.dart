import 'package:my_library/core/models/book_copy.dart';
import 'package:my_library/core/models/metadata_candidate.dart';
import 'package:my_library/core/models/reading_status.dart';

enum DraftStatus { recognized, needsReview, saved }

enum CaptureMethod { barcode, singlePhoto, batchPhotos, manual }

class BookDraft {
  const BookDraft({
    this.localKey = '',
    this.title = '',
    this.subtitle = '',
    this.description = '',
    this.personalNote = '',
    this.isbn = '',
    this.authors = const [],
    this.genres = const [],
    this.publishers = const [],
    this.hashtags = const [],
    this.coverPath,
    this.photoPaths = const [],
    this.sourceUrl = '',
    this.shelfId,
    this.rowId,
    this.recognizedText = '',
    this.candidates = const [],
    this.savedBookId,
    this.readingStatus = ReadingStatus.wantToRead,
    this.statusChangedAt,
    this.seriesName = '',
    this.seriesVolume,
    this.loanPerson = '',
    this.loanDueAt,
    this.format = BookFormat.print,
    this.placement = BookPlacement.shelf,
    this.yandexId = '',
    this.narrator = '',
    this.durationSeconds,
    this.libraryDueAt,
    this.readerRating,
  });

  final String localKey;
  final String title;
  final String subtitle;
  final String description;
  final String personalNote;
  final String isbn;
  final List<String> authors;
  final List<String> genres;
  final List<String> publishers;
  final List<String> hashtags;
  final String? coverPath;
  final List<String> photoPaths;
  final String sourceUrl;
  final int? shelfId;
  final int? rowId;
  final String recognizedText;
  final List<MetadataCandidate> candidates;
  final int? savedBookId;
  final ReadingStatus readingStatus;
  final DateTime? statusChangedAt;
  final String seriesName;
  final int? seriesVolume;
  final String loanPerson;
  final DateTime? loanDueAt;
  final BookFormat format;
  final BookPlacement placement;
  final String yandexId;
  final String narrator;
  final int? durationSeconds;
  final DateTime? libraryDueAt;
  final int? readerRating;

  DraftStatus get status {
    if (savedBookId != null) {
      return DraftStatus.saved;
    }
    if (candidates.isNotEmpty) {
      return DraftStatus.recognized;
    }
    return DraftStatus.needsReview;
  }

  bool get canSave => title.trim().isNotEmpty && savedBookId == null;

  BookDraft copyWith({
    String? localKey,
    String? title,
    String? subtitle,
    String? description,
    String? personalNote,
    String? isbn,
    List<String>? authors,
    List<String>? genres,
    List<String>? publishers,
    List<String>? hashtags,
    Object? coverPath = _unset,
    List<String>? photoPaths,
    String? sourceUrl,
    Object? shelfId = _unset,
    Object? rowId = _unset,
    String? recognizedText,
    List<MetadataCandidate>? candidates,
    Object? savedBookId = _unset,
    ReadingStatus? readingStatus,
    Object? statusChangedAt = _unset,
    String? seriesName,
    Object? seriesVolume = _unset,
    String? loanPerson,
    Object? loanDueAt = _unset,
    BookFormat? format,
    BookPlacement? placement,
    String? yandexId,
    String? narrator,
    Object? durationSeconds = _unset,
    Object? libraryDueAt = _unset,
    Object? readerRating = _unset,
  }) {
    return BookDraft(
      localKey: localKey ?? this.localKey,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      personalNote: personalNote ?? this.personalNote,
      isbn: isbn ?? this.isbn,
      authors: authors ?? this.authors,
      genres: genres ?? this.genres,
      publishers: publishers ?? this.publishers,
      hashtags: hashtags ?? this.hashtags,
      coverPath: coverPath == _unset ? this.coverPath : coverPath as String?,
      photoPaths: photoPaths ?? this.photoPaths,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      shelfId: shelfId == _unset ? this.shelfId : shelfId as int?,
      rowId: rowId == _unset ? this.rowId : rowId as int?,
      recognizedText: recognizedText ?? this.recognizedText,
      candidates: candidates ?? this.candidates,
      savedBookId: savedBookId == _unset ? this.savedBookId : savedBookId as int?,
      readingStatus: readingStatus ?? this.readingStatus,
      statusChangedAt: statusChangedAt == _unset
          ? this.statusChangedAt
          : statusChangedAt as DateTime?,
      seriesName: seriesName ?? this.seriesName,
      seriesVolume: seriesVolume == _unset ? this.seriesVolume : seriesVolume as int?,
      loanPerson: loanPerson ?? this.loanPerson,
      loanDueAt: loanDueAt == _unset ? this.loanDueAt : loanDueAt as DateTime?,
      format: format ?? this.format,
      placement: placement ?? this.placement,
      yandexId: yandexId ?? this.yandexId,
      narrator: narrator ?? this.narrator,
      durationSeconds: durationSeconds == _unset
          ? this.durationSeconds
          : durationSeconds as int?,
      libraryDueAt: libraryDueAt == _unset
          ? this.libraryDueAt
          : libraryDueAt as DateTime?,
      readerRating: readerRating == _unset
          ? this.readerRating
          : readerRating as int?,
    );
  }

  /// Audio stays off the shelf. A library copy clears the shelf and keeps its due date.
  BookDraft prepared() {
    if (format == BookFormat.audio) {
      return copyWith(
        placement: BookPlacement.shelf,
        shelfId: null,
        rowId: null,
        isbn: '',
        publishers: const [],
        libraryDueAt: null,
      );
    }
    if (placement == BookPlacement.library) {
      return copyWith(
        format: BookFormat.print,
        shelfId: null,
        rowId: null,
      );
    }
    return copyWith(libraryDueAt: null);
  }
}

const _unset = Object();

String captureMethodTitle(CaptureMethod method) {
  return switch (method) {
    CaptureMethod.barcode => 'Штрихкод ISBN',
    CaptureMethod.singlePhoto => 'Одно фото',
    CaptureMethod.batchPhotos => 'Несколько фото',
    CaptureMethod.manual => 'Название вручную',
  };
}

String draftStatusLabel(DraftStatus status) {
  return switch (status) {
    DraftStatus.recognized => 'распознано',
    DraftStatus.needsReview => 'нужна проверка',
    DraftStatus.saved => 'сохранено',
  };
}
