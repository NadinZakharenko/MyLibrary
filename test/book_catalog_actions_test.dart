import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/features/books/book_catalog_actions.dart';

void main() {
  test('catalog send stays hidden without a note or permission', () {
    expect(showCatalogSend(note: '', allowed: true), isFalse);
    expect(showCatalogSend(note: '   ', allowed: true), isFalse);
    expect(showCatalogSend(note: 'Понравилось', allowed: false), isFalse);
    expect(showCatalogSend(note: 'Понравилось', allowed: true), isTrue);
  });
}
