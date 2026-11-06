enum MetadataSource { rsl, liveLib, model }

class MetadataCandidate {
  const MetadataCandidate({
    required this.source,
    required this.title,
    this.subtitle = '',
    this.authors = const [],
    this.genres = const [],
    this.publisher = '',
    this.year = '',
    this.description = '',
    this.isbn = '',
    this.seriesName = '',
    this.seriesVolume,
    this.coverUrl,
    this.sourceUrl,
    this.workKey,
  });

  final MetadataSource source;
  final String title;
  final String subtitle;
  final List<String> authors;
  final List<String> genres;
  final String publisher;
  final String year;
  final String description;
  final String isbn;
  final String seriesName;
  final int? seriesVolume;
  final String? coverUrl;
  final String? sourceUrl;
  final String? workKey;

  String get sourceLabel => switch (source) {
    MetadataSource.rsl => 'РГБ',
    MetadataSource.liveLib => 'LiveLib',
    MetadataSource.model => 'Модель',
  };

  MetadataCandidate copyWith({
    String? description,
    String? coverUrl,
    String? isbn,
    String? year,
  }) {
    return MetadataCandidate(
      source: source,
      title: title,
      subtitle: subtitle,
      authors: authors,
      genres: genres,
      publisher: publisher,
      year: year ?? this.year,
      description: description ?? this.description,
      isbn: isbn ?? this.isbn,
      seriesName: seriesName,
      seriesVolume: seriesVolume,
      coverUrl: coverUrl ?? this.coverUrl,
      sourceUrl: sourceUrl,
      workKey: workKey,
    );
  }
}
