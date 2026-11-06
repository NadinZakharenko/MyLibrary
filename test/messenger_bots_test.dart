import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_library/data/messenger_bots.dart';

void main() {
  test('Max probe is sent to the entered user id', () async {
    late Uri uri;
    final client = MockClient((request) async {
      uri = request.url;
      expect(request.headers['authorization'], 'token');
      expect(jsonDecode(request.body), {'text': 'Библиотека на связи.'});
      return http.Response('{"message":{"body":{"mid":"1"}}}', 200);
    });

    await MessengerBots(httpClient: client).sendMax(
      token: 'token',
      userId: '83121927',
      text: 'Библиотека на связи.',
    );

    expect(uri.path, '/messages');
    expect(uri.queryParameters['user_id'], '83121927');
  });

  test('Max send keeps the API error text', () async {
    final client = MockClient(
      (request) async => http.Response.bytes(
        utf8.encode('{"code":"dialog.not.found","message":"Диалог не найден"}'),
        404,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );

    expect(
      () => MessengerBots(httpClient: client).sendMax(
        token: 'token',
        userId: '83121927',
        text: 'Библиотека на связи.',
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'Макс ответил 404: dialog.not.found: Диалог не найден',
        ),
      ),
    );
  });
}
