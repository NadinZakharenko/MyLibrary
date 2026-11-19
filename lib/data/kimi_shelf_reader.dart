import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:my_library/core/logging/catalog_request.dart';
import 'package:my_library/core/logging/model_error.dart';
import 'package:my_library/core/metadata/shelf_image.dart';
import 'package:my_library/core/metadata/shelf_reading.dart';
import 'package:my_library/data/metadata_service.dart';

const kimiVisionModel = 'kimi-k2.6';

class KimiShelfReader {
  KimiShelfReader({http.Client? client, this.log, this.model = kimiVisionModel})
    : _client = client ?? http.Client();

  final http.Client _client;
  final ModelCallLog? log;
  final String model;

  static const _timeout = Duration(seconds: 90);

  Future<List<RecognizedShelf>> read({
    required Uint8List jpeg,
    required String apiKey,
  }) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw MetadataLookupException('Добавьте ключ Kimi в настройках.');
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
            Uri.https('api.moonshot.ai', '/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $key',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'thinking': {'type': 'disabled'},
              'response_format': {'type': 'json_object'},
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
          secrets: [key],
        );
        await _record(
          statusCode: response.statusCode,
          error: detail.isEmpty ? 'код ${response.statusCode}' : detail,
        );
        throw MetadataLookupException(
          detail.isEmpty
              ? 'Kimi ответил кодом ${response.statusCode}.'
              : 'Kimi ответил кодом ${response.statusCode}. $detail',
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
      throw MetadataLookupException('Не удалось связаться с Kimi.');
    }
  }

  Future<String> ask({required String apiKey, required String prompt}) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw MetadataLookupException('Добавьте ключ Kimi в настройках.');
    }
    try {
      final response = await _client
          .post(
            Uri.https('api.moonshot.ai', '/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $key',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'thinking': {'type': 'disabled'},
              'response_format': {'type': 'json_object'},
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
            }),
          )
          .timeout(_timeout);
      if (response.statusCode != 200) {
        final detail = modelErrorDetail(
          utf8.decode(response.bodyBytes, allowMalformed: true),
          secrets: [key],
        );
        await _record(
          statusCode: response.statusCode,
          error: detail.isEmpty ? 'код ${response.statusCode}' : detail,
        );
        throw MetadataLookupException(
          detail.isEmpty
              ? 'Kimi ответил кодом ${response.statusCode}.'
              : 'Kimi ответил кодом ${response.statusCode}. $detail',
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
      throw MetadataLookupException('Не удалось связаться с Kimi.');
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
        model: model,
        statusCode: statusCode,
        shelfCount: shelfCount,
        bookCount: bookCount,
        error: error,
      ),
    );
  }

  String _messageText(Object? json) {
    if (json is! Map) {
      throw const ShelfReadingException('Kimi вернул непонятный ответ.');
    }
    final choices = json['choices'];
    if (choices is! List || choices.isEmpty || choices.first is! Map) {
      throw const ShelfReadingException('Kimi вернул непонятный ответ.');
    }
    final message = (choices.first as Map)['message'];
    if (message is! Map) {
      throw const ShelfReadingException('Kimi вернул непонятный ответ.');
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
    throw const ShelfReadingException('Kimi вернул непонятный ответ.');
  }
}
