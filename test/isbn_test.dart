import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/core/isbn.dart';

void main() {
  test('accepts checksum-valid ISBN-10 and ISBN-13', () {
    expect(normalizeIsbn('978-0-306-40615-7'), '9780306406157');
    expect(normalizeIsbn('0-306-40615-2'), '0306406152');
  });

  test('finds an ISBN hidden in a longer barcode', () {
    expect(isbnFromText('ISBN 978-0-14-032872-1 extra'), '9780140328721');
    expect(isbnFromText('prefix9780140328721'), '9780140328721');
  });

  test('rejects a broken checksum and a short code', () {
    expect(normalizeIsbn('9780306406158'), isNull);
    expect(normalizeIsbn('123'), isNull);
    expect(normalizeIsbn(''), isNull);
  });
}
