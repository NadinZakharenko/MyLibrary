import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/core/format/hashtag.dart';

void main() {
  test('normalizes hashtags for case-insensitive uniqueness', () {
    expect(normalizeHashtag('#Фантастика'), 'фантастика');
    expect(normalizeHashtag('  фантастика  '), 'фантастика');
    expect(normalizeHashtag('##Тег'), 'тег');
    expect(normalizeHashtag(' # '), isNull);
    expect(normalizeHashtag('#'), isNull);
    expect(normalizeHashtag('   '), isNull);
  });

  test('display name keeps the original case and drops hashes', () {
    expect(hashtagDisplayName('#Фантастика'), 'Фантастика');
    expect(hashtagDisplayName('##Тег'), 'Тег');
    expect(hashtagDisplayName('#'), isNull);
  });
}
