import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/core/format/book_share.dart';
import 'package:my_library/core/models/shelf_model.dart';

void main() {
  test('share text keeps title, authors and a filled link', () {
    expect(
      bookShareText(
        title: 'Тихий Дон',
        authors: ['Шолохов Михаил Александрович', '  '],
        sourceUrl: ' https://books.yandex.ru/audiobooks/abc ',
      ),
      'Тихий Дон\nШолохов Михаил Александрович\nhttps://books.yandex.ru/audiobooks/abc',
    );
    expect(
      bookShareText(title: 'Без автора', authors: const [], sourceUrl: ''),
      'Без автора',
    );
  });

  test('photo search follows the shelf model switch', () {
    expect(shelfModelReadsPhotos(ShelfModelChoice.off), isFalse);
    expect(shelfModelReadsPhotos(ShelfModelChoice.kimi), isTrue);
    expect(shelfModelReadsPhotos(ShelfModelChoice.yandex), isTrue);
  });
}
