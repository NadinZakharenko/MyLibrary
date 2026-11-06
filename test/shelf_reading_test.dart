import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:my_library/core/logging/catalog_request.dart';
import 'package:my_library/core/metadata/shelf_image.dart';
import 'package:my_library/core/metadata/shelf_reading.dart';
import 'package:my_library/data/kimi_shelf_reader.dart';
import 'package:my_library/data/metadata_service.dart';
import 'package:my_library/data/yandex_shelf_reader.dart';

void main() {
  test('parses shelves and drops links, extras, and empty spines', () {
    final shelves = parseShelfReading('''
Вот список:
```json
{
  "shelves": [
    {
      "books": [
        {"title": " Мастер и Маргарита https://evil.example/x ", "author": "Булгаков", "uncertain": false, "isbn": "выдумка"},
        {"title": "", "author": "", "uncertain": true},
        {"title": "Тихий Дон", "author": 12, "uncertain": "yes"}
      ]
    },
    {"books": [{"title": "Вторая", "author": "Автор", "uncertain": true}]},
    {"books": []},
    {"books": [{"title": "Лишняя полка", "author": ""}]}
  ]
}
```
''');

    expect(shelves, hasLength(3));
    expect(shelves.first.books, hasLength(2));
    expect(shelves.first.books.first.title, 'Мастер и Маргарита');
    expect(shelves.first.books.first.title.contains('http'), isFalse);
    expect(shelves.first.books.first.author, 'Булгаков');
    expect(shelves.first.books[1].author, isEmpty);
    expect(shelves.first.books[1].uncertain, isFalse);
    expect(shelves[1].books.single.uncertain, isTrue);
  });

  test('drops spines written only in characters other than letters', () {
    final shelves = parseShelfReading('''
{"shelves":[{"books":[
  {"title":"战争与和平","author":"托尔斯泰","uncertain":false},
  {"title":"Война и мир","author":"托尔斯泰","uncertain":false}
]}]}
''');

    expect(shelves.single.books.single.title, 'Война и мир');
    expect(shelves.single.books.single.author, isEmpty);
  });

  test('rejects a response without shelves', () {
    expect(
      () => parseShelfReading('{"title":"не список"}'),
      throwsA(isA<ShelfReadingException>()),
    );
  });

  test('shrinks the long side before a shelf photo is sent', () {
    final source = img.Image(width: 100, height: 40);
    final bytes = Uint8List.fromList(img.encodeJpg(source));
    final shrunk = downscaleJpeg(bytes, maxSide: 32);
    final decoded = img.decodeImage(shrunk)!;
    expect(decoded.width, lessThanOrEqualTo(32));
    expect(decoded.height, lessThanOrEqualTo(32));
    expect(decoded.width, greaterThan(decoded.height));
  });

  test('logs a model call without the key or the photo', () async {
    const secret = 'kimi-test-secret-key';
    final records = <ModelCallRecord>[];
    String? authorization;
    var bodyHasPhoto = false;
    final photo = Uint8List.fromList(
      img.encodeJpg(img.Image(width: 8, height: 8)),
    );
    final client = MockClient((request) async {
      authorization = request.headers['Authorization'];
      bodyHasPhoto = request.body.contains('data:image/jpeg;base64,');
      return http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {
                'content': jsonEncode({
                  'shelves': [
                    {
                      'books': [
                        {'title': 'Война и мир', 'author': 'Толстой', 'uncertain': false},
                      ],
                    },
                  ],
                }),
              },
            },
          ],
        }),
        200,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final reader = KimiShelfReader(
      client: client,
      log: (record) async => records.add(record),
    );
    addTearDown(reader.close);

    final shelves = await reader.read(jpeg: photo, apiKey: secret);

    expect(shelves.single.books.single.title, 'Война и мир');
    expect(authorization, 'Bearer $secret');
    expect(bodyHasPhoto, isTrue);
    expect(records.single.statusCode, 200);
    expect(records.single.shelfCount, 1);
    expect(records.single.bookCount, 1);
    final logged = '${records.single.model} ${records.single.error}';
    expect(logged.contains(secret), isFalse);
    expect(logged.contains('base64'), isFalse);
  });

  test('logs the Kimi refusal and does not send temperature 0', () async {
    const secret = 'kimi-test-secret-key';
    final records = <ModelCallRecord>[];
    String? body;
    final photo = Uint8List.fromList(
      img.encodeJpg(img.Image(width: 8, height: 8)),
    );
    final client = MockClient((request) async {
      body = request.body;
      return http.Response(
        jsonEncode({
          'error': {
            'message': 'temperature must be 0.6, leaked $secret',
          },
        }),
        400,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final reader = KimiShelfReader(
      client: client,
      log: (record) async => records.add(record),
    );
    addTearDown(reader.close);

    await expectLater(
      reader.read(jpeg: photo, apiKey: secret),
      throwsA(isA<MetadataLookupException>()),
    );

    expect(jsonDecode(body!)['temperature'], isNull);
    expect(records.single.statusCode, 400);
    expect(records.single.error, contains('temperature must be 0.6'));
    expect(records.single.error!.contains(secret), isFalse);
    expect(records.single.error!.contains('base64'), isFalse);
  });

  test('sends the Yandex folder header and explains a 403', () async {
    const secret = 'yandex-test-secret';
    const folder = 'b1gtestfolder';
    final records = <ModelCallRecord>[];
    Map<String, String>? headers;
    final photo = Uint8List.fromList(
      img.encodeJpg(img.Image(width: 8, height: 8)),
    );
    final client = MockClient((request) async {
      headers = request.headers;
      return http.Response(
        jsonEncode({'error': {'message': 'Forbidden $secret $folder'}}),
        403,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final reader = YandexShelfReader(
      client: client,
      log: (record) async => records.add(record),
    );
    addTearDown(reader.close);

    await expectLater(
      reader.read(jpeg: photo, apiKey: secret, folderId: folder),
      throwsA(
        predicate<MetadataLookupException>(
          (error) =>
              error.message.contains('ai.languageModels.user') &&
              error.message.contains('yc.ai.foundationModels.execute'),
        ),
      ),
    );

    expect(headers?['x-folder-id'], folder);
    expect(headers?['authorization'], 'Api-Key $secret');
    expect(records.single.error!.contains(secret), isFalse);
    expect(records.single.error!.contains(folder), isFalse);
  });
}
