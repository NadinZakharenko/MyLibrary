import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/core/metadata/metadata_mapper.dart';
import 'package:my_library/core/models/metadata_candidate.dart';
import 'package:my_library/ui/candidate_sheet.dart';

void main() {
  test('reads a search query from recognized text', () {
    expect(
      searchQueryFromRecognizedText('ISBN\nМастер и Маргарита\nok'),
      'Мастер и Маргарита',
    );
    expect(titleFromRecognizedText('Коротко'), 'Коротко');
  });

  test('keeps the publication year when a candidate is copied', () {
    const candidate = MetadataCandidate(
      source: MetadataSource.rsl,
      title: 'Война и мир',
      publisher: 'АСТ, 2014',
      year: '2014',
    );

    final copied = candidate.copyWith(description: 'Роман');

    expect(copied.publisher, 'АСТ, 2014');
    expect(copied.year, '2014');
    expect(copied.description, 'Роман');
  });

  test('shows a publisher year separately when it repeats the year field', () {
    const glued = MetadataCandidate(
      source: MetadataSource.rsl,
      title: 'Война и мир',
      publisher: 'АСТ, 2014',
      year: '2014',
    );
    expect(editionListText(glued), (publisher: 'АСТ', year: '2014'));

    const named = MetadataCandidate(
      source: MetadataSource.liveLib,
      title: 'Book',
      publisher: 'Penguin',
      year: '1967',
    );
    expect(editionListText(named), (publisher: 'Penguin', year: '1967'));

    const yearOnly = MetadataCandidate(
      source: MetadataSource.model,
      title: 'Book',
      publisher: '2014',
      year: '2014',
    );
    expect(editionListText(yearOnly), (publisher: '', year: '2014'));
  });
}
