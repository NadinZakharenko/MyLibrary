import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_library/core/logging/catalog_request.dart';
import 'package:my_library/core/logging/redact.dart';
import 'package:my_library/core/metadata/livelib.dart';
import 'package:my_library/core/metadata/model_book.dart';
import 'package:my_library/core/metadata/rsl.dart';
import 'package:my_library/core/models/book_copy.dart';
import 'package:my_library/core/models/metadata_candidate.dart';
import 'package:my_library/data/metadata_service.dart';

void main() {
  test('redacts a secret and a key query parameter', () {
    const secret = 'super-secret-key';
    final text = redactSecrets('q=isbn:1&key=$secret note $secret', const [
      secret,
    ]);
    expect(text.contains(secret), isFalse);
    expect(text, contains('key=•••'));
  });

  test('logs an ISBN search only in RSL and LiveLib', () async {
    final hosts = <String>[];
    final records = <CatalogRequestRecord>[];
    final client = MockClient((request) async {
      hosts.add(request.url.host);
      if (request.url.host == 'lbc.rsl.ru') {
        return http.Response(
          '<set><hits>0</hits><records></records></set>',
          200,
        );
      }
      if (request.url.host == 'www.livelib.ru') {
        return http.Response(
          '<html></html>',
          200,
          headers: const {'content-type': 'text/html; charset=utf-8'},
        );
      }
      return http.Response('unexpected', 500);
    });
    final service = MetadataService(
      client: client,
      log: (record) async => records.add(record),
    );
    addTearDown(service.close);

    final results = await service.search(isbn: '9780140328721');

    expect(results, isEmpty);
    expect(records.map((record) => record.catalog), ['РГБ', 'LiveLib']);
    expect(hosts, ['lbc.rsl.ru', 'www.livelib.ru']);
  });

  test('searches RSL and LiveLib by title and author', () async {
    final hosts = <String>[];
    Uri? rslUri;
    Uri? liveLibUri;
    final client = MockClient((request) async {
      hosts.add(request.url.host);
      if (request.url.host == 'lbc.rsl.ru') {
        rslUri = request.url;
        return http.Response(
          '<set><hits>0</hits><records></records></set>',
          200,
        );
      }
      if (request.url.host == 'www.livelib.ru') {
        liveLibUri = request.url;
        return http.Response(
          '<html></html>',
          200,
          headers: const {'content-type': 'text/html; charset=utf-8'},
        );
      }
      return http.Response('unexpected', 500);
    });
    final service = MetadataService(client: client);
    addTearDown(service.close);

    await service.search(title: 'Мастер и Маргарита', author: 'Булгаков');

    expect(rslUri!.queryParameters['Title'], 'Мастер и Маргарита');
    expect(rslUri!.queryParameters['Autor'], 'Булгаков');
    expect(liveLibUri!.pathSegments, ['find', 'Мастер и Маргарита Булгаков']);
    expect(hosts, ['lbc.rsl.ru', 'www.livelib.ru']);
  });

  test(
    'asks LiveLib after an empty ISBN and then searches the title',
    () async {
      final hosts = <String>[];
      final client = MockClient((request) async {
        hosts.add(request.url.host);
        if (request.url.host == 'www.livelib.ru') {
          return http.Response(
            '<html>ничего</html>',
            200,
            headers: const {'content-type': 'text/html; charset=utf-8'},
          );
        }
        return http.Response(
          '<set><hits>0</hits><records></records></set>',
          200,
        );
      });
      final records = <CatalogRequestRecord>[];
      final service = MetadataService(
        client: client,
        log: (record) async => records.add(record),
      );
      addTearDown(service.close);

      final results = await service.search(
        isbn: '9785002149377',
        title: 'Собор Парижской Богоматери',
      );

      expect(results, isEmpty);
      expect(
        records
            .where((record) => record.catalog == 'LiveLib')
            .map((record) => record.resultCount),
        [0, 0],
      );
      expect(records.map((record) => record.catalog), [
        'РГБ',
        'LiveLib',
        'РГБ',
        'LiveLib',
      ]);
      expect(hosts, [
        'lbc.rsl.ru',
        'www.livelib.ru',
        'lbc.rsl.ru',
        'www.livelib.ru',
      ]);
    },
  );

  test(
    'a print search keeps the Yandex text book and hides the token',
    () async {
      const secret = 'y0_secret_token';
      final records = <CatalogRequestRecord>[];
      final service = MetadataService(
        client: _catalogThenYandex(),
        yandexToken: () async => secret,
        log: (record) async => records.add(record),
      );
      addTearDown(service.close);

      final results = await service.search(title: 'Мастер и Маргарита');

      expect(results.single.source, MetadataSource.yandexBooks);
      expect(results.single.title, 'Мастер и Маргарита');
      expect(results.single.workKey, 'txt');
      expect(results.single.sourceUrl, 'https://books.yandex.ru/books/txt');
      expect(results.single.narrator, isEmpty);
      expect(records.last.resultCount, 1);
      final dumped = records
          .map((record) => '${record.detail} ${record.error}')
          .join('\n');
      expect(dumped.contains(secret), isFalse);
    },
  );

  test('an audio search keeps the Yandex audiobook', () async {
    final service = MetadataService(
      client: _catalogThenYandex(),
      yandexToken: () async => 'y0_secret_token',
    );
    addTearDown(service.close);

    final results = await service.search(
      title: 'Мастер и Маргарита',
      format: BookFormat.audio,
    );

    expect(results.single.workKey, 'aud');
    expect(results.single.narrator, 'Чтец');
    expect(results.single.sourceUrl, 'https://books.yandex.ru/audiobooks/aud');
  });

  test('stops at the first RSL record', () async {
    final hosts = <String>[];
    final client = MockClient((request) async {
      hosts.add(request.url.host);
      return http.Response(
        _rslRecord,
        200,
        headers: const {'content-type': 'application/xml; charset=utf-8'},
      );
    });
    final service = MetadataService(client: client);
    addTearDown(service.close);

    final results = await service.search(isbn: '9785171156046');

    expect(hosts, ['lbc.rsl.ru']);
    expect(results.single.source, MetadataSource.rsl);
    expect(results.single.title, 'Война и мир');
    expect(results.single.isbn, '9785171156046');
  });

  test('reads an RSL card and ignores the storage code', () {
    final found = candidatesFromRsl(_rslRecord);

    expect(found.single.title, 'Война и мир');
    expect(found.single.subtitle, 'роман');
    expect(found.single.authors, ['Толстой, Лев Николаевич']);
    expect(found.single.publisher, 'АСТ, 2014');
    expect(found.single.year, '2014');
    expect(found.single.seriesName, 'Русская классика');
    expect(found.single.seriesVolume, 1);
    expect(
      found.single.sourceUrl,
      'https://search.rsl.ru/ru/record/01008123497',
    );
    expect(found.single.publisher.contains('10 19-7/282'), isFalse);
    expect(found.single.title.contains('10 19-7/282'), isFalse);
  });

  test('hyphenates a Russian ISBN and drops the forbidden title word', () {
    expect(rslIsbn('9785171156046'), '978-5-17-115604-6');
    expect(rslTextQuery('The end of the world'), 'The of the world');
  });

  test('reads one book from a model answer and drops an invented isbn', () {
    final found = candidatesFromModel(
      '{"title":"Война и мир","author":"Толстой","publisher":"АСТ","year":"2014","series":"Классика","isbn":"000"}',
    );

    expect(found.single.source, MetadataSource.model);
    expect(found.single.title, 'Война и мир');
    expect(found.single.publisher, 'АСТ, 2014');
    expect(found.single.year, '2014');
    expect(found.single.seriesName, 'Классика');
    expect(found.single.isbn, isEmpty);
  });

  test('asks the connected model only after empty catalogs', () async {
    var calls = 0;
    final client = MockClient((request) async {
      if (request.url.host == 'lbc.rsl.ru') {
        return http.Response(
          '<set><hits>0</hits><records></records></set>',
          200,
        );
      }
      if (request.url.host == 'www.livelib.ru') {
        return http.Response(
          '<html></html>',
          200,
          headers: const {'content-type': 'text/html; charset=utf-8'},
        );
      }
      return http.Response('no', 500);
    });
    final service = MetadataService(
      client: client,
      model: ({String? isbn, String? title, String? author}) async {
        calls += 1;
        return [
          MetadataCandidate(
            source: MetadataSource.model,
            title: 'Из модели',
            isbn: isbn ?? '',
          ),
        ];
      },
    );
    addTearDown(service.close);

    final results = await service.search(isbn: '9780140328721');

    expect(calls, 1);
    expect(results.single.title, 'Из модели');
    expect(results.single.isbn, '9780140328721');
  });

  test('reads a LiveLib book link and skips a repeated card', () {
    final found = candidatesFromLiveLib(
      '<a href="/book/1001-sobor">Собор Парижской Богоматери</a>'
      '<a href="/author/7-gyugo">Виктор Гюго</a>'
      '<a href="/book/1001-sobor">Собор Парижской Богоматери</a>',
      isbn: '9785002149377',
    );

    expect(found.single.source, MetadataSource.liveLib);
    expect(found.single.title, 'Собор Парижской Богоматери');
    expect(found.single.authors, ['Виктор Гюго']);
    expect(found.single.sourceUrl, 'https://www.livelib.ru/book/1001-sobor');
  });

  test('searches LiveLib by the query path, not the word books', () {
    expect(
      liveLibSearchUri('9785002149377').toString(),
      'https://www.livelib.ru/find/9785002149377',
    );
    expect(liveLibSearchUri('Мифы Африки').pathSegments, [
      'find',
      'Мифы Африки',
    ]);
  });

  test('keeps the book title and ignores the edition counter', () {
    final found = candidatesFromLiveLib(
      '<a href="/book/1010760422-mify">'
      '<span style="background:url(https://s1.livelib.ru/boocover/1010760422/120x180/4722/boocover.jpg)"></span>'
      '</a>'
      '<a href="/book/7827611/editions">2 издания</a>'
      '<a href="/book/1010760422-mify" class="title">Мифы тропической и южной Африки</a>'
      '<a href="/author/2784821-tatarovskaya-irina">Татаровская Ирина</a>'
      '<span>АСТ, 2019</span>'
      '<a class="label-genre" href="/genre/x">Научно-популярная литература</a>'
      '<a href="/book/2388641/editions">127 изданий</a>'
      '<a href="/book/1005584599-vlastelin" class="title">Властелин Колец: Возвращение короля</a>'
      '<a href="/author/166382-dzhon">Джон Р. Р. Толкин</a>'
      '<span>1955 г.</span>',
      isbn: '9785002149377',
    );

    expect(found.map((item) => item.title), [
      'Мифы тропической и южной Африки',
      'Властелин Колец: Возвращение короля',
    ]);
    expect(found.first.authors, ['Татаровская Ирина']);
    expect(found.first.year, '2019');
    expect(found.last.year, '1955');
    expect(found.first.genres, ['Научно-популярная литература']);
    expect(
      found.first.coverUrl,
      'https://s1.livelib.ru/boocover/1010760422/120x180/4722/boocover.jpg',
    );
    expect(found.last.authors, ['Джон Р. Р. Толкин']);
  });

  test('reads the ISBN from a LiveLib book page', () {
    expect(
      liveLibPageIsbn('<div>ISBN:</div><div>978-5-00180-969-2</div>'),
      '9785001809692',
    );
  });

  test('a title search writes the LiveLib page ISBN onto the result', () async {
    final client = MockClient((request) async {
      if (request.url.host == 'lbc.rsl.ru') {
        return http.Response(
          '<set><hits>0</hits><records></records></set>',
          200,
        );
      }
      if (request.url.path.startsWith('/book/')) {
        return http.Response(
          '<div>ISBN:</div><div>978-5-17-115604-6</div>',
          200,
          headers: const {'content-type': 'text/html; charset=utf-8'},
        );
      }
      return http.Response(
        '<a href="/book/10-voina" class="title">Война и мир</a>'
        '<a href="/author/1">Толстой</a>',
        200,
        headers: const {'content-type': 'text/html; charset=utf-8'},
      );
    });
    final service = MetadataService(client: client);
    addTearDown(service.close);

    final results = await service.search(title: 'Война и мир');

    expect(results.single.isbn, '9785171156046');
    expect(results.single.source, MetadataSource.liveLib);
  });

  test('reads a labeled ISBN from a LiveLib title card', () {
    final found = candidatesFromLiveLib(
      '<a href="/book/10-voina" class="title">Война и мир</a>'
      '<a href="/author/1-tolstoy">Толстой</a>'
      '<span>ISBN 978-5-17-115604-6</span>',
      isbn: '',
    );

    expect(found.single.isbn, '9785171156046');
  });

  test(
    'does not collapse different LiveLib titles that share the query ISBN',
    () async {
      final client = MockClient((request) async {
        if (request.url.host == 'www.livelib.ru') {
          expect(request.url.path, '/find/9785002149377');
          return http.Response(
            '<a href="/book/1-one" class="title">Первая книга</a>'
            '<a href="/author/1">Автор Один</a>'
            '<a href="/book/2-two" class="title">Вторая книга</a>'
            '<a href="/author/2">Автор Два</a>',
            200,
            headers: const {'content-type': 'text/html; charset=utf-8'},
          );
        }
        return http.Response(
          '<set><hits>0</hits><records></records></set>',
          200,
        );
      });
      final service = MetadataService(client: client);
      addTearDown(service.close);

      final results = await service.search(isbn: '9785002149377');

      expect(results.map((item) => item.title), [
        'Первая книга',
        'Вторая книга',
      ]);
      expect(results.map((item) => item.authors.single), [
        'Автор Один',
        'Автор Два',
      ]);
    },
  );
}

MockClient _catalogThenYandex() {
  return MockClient((request) async {
    if (request.url.host == 'lbc.rsl.ru') {
      return http.Response('<set><hits>0</hits><records></records></set>', 200);
    }
    if (request.url.host == 'www.livelib.ru') {
      return http.Response(
        '<html></html>',
        200,
        headers: const {'content-type': 'text/html; charset=utf-8'},
      );
    }
    return http.Response.bytes(
      utf8.encode(
        jsonEncode({
          'data': {
            'search': {
              'page': [
                {
                  '__typename': 'AudioBook',
                  'narrators': [
                    {'name': 'Чтец'},
                  ],
                  'book': {
                    'uuid': 'aud',
                    'name': 'Мастер и Маргарита',
                    'authors': [
                      {'name': 'Михаил Булгаков'},
                    ],
                  },
                },
                {
                  '__typename': 'TextBook',
                  'book': {
                    'uuid': 'txt',
                    'name': 'Мастер и Маргарита',
                    'authors': [
                      {'name': 'Михаил Булгаков'},
                    ],
                    'publisher': {'name': 'Эксмо'},
                  },
                },
              ],
            },
          },
        }),
      ),
      200,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  });
}

const _rslRecord = '''
<set><hits>1</hits><records>
<record>
  <controlfield tag="001">01008123497</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">978-5-17-115604-6</subfield>
  </datafield>
  <datafield tag="100" ind1="1" ind2=" ">
    <subfield code="a">Толстой, Лев Николаевич</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="0">
    <subfield code="a">Война и мир</subfield>
    <subfield code="b">роман</subfield>
  </datafield>
  <datafield tag="260" ind1=" " ind2=" ">
    <subfield code="a">Москва</subfield>
    <subfield code="b">АСТ</subfield>
    <subfield code="c">2014</subfield>
  </datafield>
  <datafield tag="490" ind1=" " ind2=" ">
    <subfield code="a">Русская классика</subfield>
    <subfield code="v">1</subfield>
  </datafield>
  <datafield tag="852" ind1=" " ind2=" ">
    <subfield code="j">10 19-7/282</subfield>
  </datafield>
</record>
</records></set>
''';
