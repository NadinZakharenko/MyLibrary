import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:my_library/core/logging/catalog_request.dart';
import 'package:my_library/core/logging/model_error.dart';
import 'package:my_library/core/metadata/shelf_image.dart';
import 'package:my_library/core/metadata/shelf_reading.dart';
import 'package:my_library/data/metadata_service.dart';

const yandexVisionModelName = 'gemma-3-27b-it';

const yandexForbiddenHint =
    'Проверьте роль ai.languageModels.user и область ключа yc.ai.foundationModels.execute в том же каталоге.';

String yandexFailureMessage(int statusCode, String detail) {
  if (statusCode == 403) {
    return 'Яндекс ответил кодом 403. $yandexForbiddenHint';
  }
  if (detail.isEmpty) {
    return 'Яндекс ответил кодом $statusCode.';
  }
  return 'Яндекс ответил кодом $statusCode. $detail';
}

class YandexShelfReader {
  YandexShelfReader({http.Client? client, this.log})
    : _client = client ?? http.Client();

  final http.Client _client;
  final ModelCallLog? log;

  static const _timeout = Duration(seconds: 90);

  Future<List<RecognizedShelf>> read({
    required Uint8List jpeg,
    required String apiKey,
    required String folderId,
  }) async {
    final key = apiKey.trim();
    final folder = folderId.trim();
    if (key.isEmpty || folder.isEmpty) {
      throw MetadataLookupException('Добавьте ключ и каталог Яндекса в настройках.');
    }
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,80}$').hasMatch(folder)) {
      throw MetadataLookupException('Проверьте идентификатор каталога Яндекса.');
    }
    final Uint8List prepared;
    try {
      prepared = await downscaleJpegInBackground(jpeg);
    } on ShelfImageException catch (error) {
      await _record(error: error.message);
      throw MetadataLookupException(error.message);
    }
    try {
      final response = await _client
          .post(
            Uri.https('llm.api.cloud.yandex.net', '/v1/chat/completions'),
            headers: {
              'Authorization': 'Api-Key $key',
              'Content-Type': 'application/json',
              'x-folder-id': folder,
            },
            body: jsonEncode({
              'model': 'gpt://$folder/$yandexVisionModelName/latest',
              'messages': [
                {
                  'role': 'user',
                  'content': [
                    {
                      'type': 'image_url',
                      'image_url': {
                        'url': 'data:image/jpeg;base64,${base64Encode(prepared)}',
                      },
                    },
                    {'type': 'text', 'text': shelfReadingPrompt},
                  ],
                },
              ],
            }),
          )
          .timeout(_timeout);
      if (response.statusCode != 200) {
        final detail = modelErrorDetail(
          utf8.decode(response.bodyBytes, allowMalformed: true),
          secrets: [key, folder],
        );
        await _record(
          statusCode: response.statusCode,
          error: detail.isEmpty ? 'код ${response.statusCode}' : detail,
        );
        throw MetadataLookupException(
          yandexFailureMessage(response.statusCode, detail),
        );
      }
      final shelves = parseShelfReading(_messageText(jsonDecode(response.body)));
      final books = shelves.fold<int>(0, (sum, shelf) => sum + shelf.books.length);
      await _record(
        statusCode: response.statusCode,
        shelfCount: shelves.length,
        bookCount: books,
      );
      return shelves;
    } on MetadataLookupException {
      rethrow;
    } on ShelfReadingException catch (error) {
      await _record(statusCode: 200, error: error.message);
      throw MetadataLookupException(error.message);
    } catch (_) {
      await _record(error: 'нет связи');
      throw MetadataLookupException('Не удалось связаться с Яндексом.');
    }
  }

  Future<String> ask({
    required String apiKey,
    required String folderId,
    required String prompt,
  }) async {
    final key = apiKey.trim();
    final folder = folderId.trim();
    if (key.isEmpty || folder.isEmpty) {
      throw MetadataLookupException('Добавьте ключ и каталог Яндекса в настройках.');
    }
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,80}$').hasMatch(folder)) {
      throw MetadataLookupException('Проверьте идентификатор каталога Яндекса.');
    }
    try {
      final response = await _client
          .post(
            Uri.https('llm.api.cloud.yandex.net', '/v1/chat/completions'),
            headers: {
              'Authorization': 'Api-Key $key',
              'Content-Type': 'application/json',
              'x-folder-id': folder,
            },
            body: jsonEncode({
              'model': 'gpt://$folder/$yandexVisionModelName/latest',
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
            }),
          )
          .timeout(_timeout);
      if (response.statusCode != 200) {
        final detail = modelErrorDetail(
          utf8.decode(response.bodyBytes, allowMalformed: true),
          secrets: [key, folder],
        );
        await _record(
          statusCode: response.statusCode,
          error: detail.isEmpty ? 'код ${response.statusCode}' : detail,
        );
        throw MetadataLookupException(
          yandexFailureMessage(response.statusCode, detail),
        );
      }
      final text = _messageText(jsonDecode(response.body));
      await _record(statusCode: response.statusCode, bookCount: 0);
      return text;
    } on MetadataLookupException {
      rethrow;
    } on ShelfReadingException catch (error) {
      await _record(statusCode: 200, error: error.message);
      throw MetadataLookupException(error.message);
    } catch (_) {
      await _record(error: 'нет связи');
      throw MetadataLookupException('Не удалось связаться с Яндексом.');
    }
  }

  void close() => _client.close();

  Future<void> _record({
    int? statusCode,
    int? shelfCount,
    int? bookCount,
    String? error,
  }) async {
    final sink = log;
    if (sink == null) {
      return;
    }
    await sink(
      ModelCallRecord(
        model: yandexVisionModelName,
        statusCode: statusCode,
        shelfCount: shelfCount,
        bookCount: bookCount,
        error: error,
      ),
    );
  }

  String _messageText(Object? json) {
    if (json is! Map) {
      throw const ShelfReadingException('Яндекс вернул непонятный ответ.');
    }
    final choices = json['choices'];
    if (choices is! List || choices.isEmpty || choices.first is! Map) {
      throw const ShelfReadingException('Яндекс вернул непонятный ответ.');
    }
    final message = (choices.first as Map)['message'];
    if (message is! Map) {
      throw const ShelfReadingException('Яндекс вернул непонятный ответ.');
    }
    final content = message['content'];
    if (content is String) {
      return content;
    }
    if (content is List) {
      final buffer = StringBuffer();
      for (final part in content) {
        if (part is Map && part['text'] is String) {
          buffer.write(part['text'] as String);
        }
      }
      return buffer.toString();
    }
    throw const ShelfReadingException('Яндекс вернул непонятный ответ.');
  }
}
