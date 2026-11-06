import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_library/data/yandex_books_client.dart';

http.Response _json(Object body) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

void main() {
  test('profile request sends the Bookmate token header', () async {
    late Map<String, String> headers;
    final client = MockClient((request) async {
      headers = request.headers;
      return http.Response('{"user":{"login":"reader"}}', 200);
    });

    final id = await YandexBooksClient(httpClient: client).profileId(
      token: 'y0_secret',
      publicId: '',
    );

    expect(id, 'reader');
    expect(headers['auth-token'], 'y0_secret');
    expect(headers.containsKey('authorization'), isFalse);
  });

  test('a rejected token names the status', () async {
    final client = MockClient(
      (request) async => http.Response('no', 401),
    );

    expect(
      () => YandexBooksClient(httpClient: client).profileId(
        token: 'cloud-key',
        publicId: '',
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'Яндекс Книги ответили 401. Токен не принят. Нужен OAuth-токен Яндекс Книг.',
        ),
      ),
    );
  });

  test('listened audiobooks come from audio cards and library cards', () async {
    final requested = <String>[];
    final client = MockClient((request) async {
      requested.add('${request.url.path}?${request.url.query}');
      final page = request.url.queryParameters['page'];
      if (request.url.path.endsWith('/audiobooks')) {
        if (page == '1') {
          return _json({
            'audiobooks': [
              {'uuid': 'shelf', 'title': 'На полке', 'audio_card': null},
            ],
          });
        }
        if (page == '2') {
          return _json({
            'audiobooks': [
              {
                'uuid': 'heard-2',
                'title': 'Вторая страница',
                'audio_card': {'state': 'finished'},
              },
            ],
          });
        }
        return _json({'audiobooks': <Object>[]});
      }
      if (page == '1') {
        return _json({
          'library_cards': [
            {'state': 'finished', 'book': {'uuid': 'print', 'title': 'Бумага'}},
            {
              'state': 'reading',
              'audiobook': {'uuid': 'current', 'title': 'Слушаю'},
            },
            {
              'state': 'finished',
              'audiobook': {'uuid': 'card-audio', 'title': 'С карточки'},
            },
          ],
        });
      }
      return _json({'library_cards': <Object>[]});
    });

    final books = await YandexBooksClient(httpClient: client, pageSize: 1)
        .finishedAudiobooks(profileId: 'NZaharenko', token: 'y0_token');

    expect(books.map((book) => book.id), ['heard-2', 'card-audio']);
    expect(requested.any((url) => url.contains('page=2&per_page=1')), isTrue);
    expect(requested.any((url) => url.contains('limit=')), isFalse);
  });

  test('search reads a text book and an audiobook and skips a person', () async {
    late Uri uri;
    late Map<String, String> headers;
    late String body;
    final client = MockClient((request) async {
      uri = request.url;
      headers = request.headers;
      body = utf8.decode(request.bodyBytes);
      return _json({
        'data': {
          'search': {
            'page': [
              {'__typename': 'Person', 'name': 'Кто-то'},
              {
                '__typename': 'TextBook',
                'book': {
                  'uuid': 'txt',
                  'name': 'Война и мир',
                  'authors': [
                    {'name': 'Лев Толстой'},
                  ],
                  'publisher': {'name': 'АСТ'},
                  'cover': {'url': 'https://example.test/war.jpg'},
                },
              },
              {
                '__typename': 'AudioBook',
                'narrators': [
                  {'name': 'Чтец'},
                ],
                'book': {
                  'uuid': 'aud',
                  'name': 'Мастер и Маргарита',
                  'annotation': '<p>Роман</p>',
                  'authors': [
                    {'name': 'Михаил Булгаков'},
                  ],
                },
              },
            ],
          },
        },
      });
    });

    final hits = await YandexBooksClient(httpClient: client).searchBooks(
      token: 'y0_secret',
      query: 'Мастер и Маргарита',
    );

    expect(uri.host, 'api-gateway.bookmate.yandex.net');
    expect(uri.path, '/graphql');
    expect(headers['auth-token'], 'y0_secret');
    expect(body, contains('Мастер и Маргарита'));
    expect(body, contains('"types":[]'));
    expect(hits.map((hit) => hit.id), ['txt', 'aud']);
    expect(hits.first.audio, isFalse);
    expect(hits.first.authors, ['Лев Толстой']);
    expect(hits.first.publisher, 'АСТ');
    expect(hits.first.coverUrl, 'https://example.test/war.jpg');
    expect(hits.last.audio, isTrue);
    expect(hits.last.annotation, 'Роман');
    expect(hits.last.narrator, 'Чтец');
  });

  test('search does nothing when the token is empty', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls += 1;
      return http.Response('{}', 200);
    });

    final hits = await YandexBooksClient(httpClient: client).searchBooks(
      token: '  ',
      query: 'Война и мир',
    );

    expect(hits, isEmpty);
    expect(calls, 0);
  });
}
