import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:my_library/core/logging/catalog_request.dart';
import 'package:my_library/core/logging/model_error.dart';
import 'package:my_library/core/metadata/shelf_reading.dart';
import 'package:my_library/core/models/shelf_model.dart';
import 'package:my_library/core/notes/voice_note.dart';
import 'package:my_library/data/kimi_shelf_reader.dart';
import 'package:my_library/data/metadata_service.dart';
import 'package:my_library/data/yandex_shelf_reader.dart';

enum StoredAudioKind { oggOpus, wav }

StoredAudioKind storedAudioKind(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.wav')) {
    return StoredAudioKind.wav;
  }
  return StoredAudioKind.oggOpus;
}

class VoiceNoteClient {
  VoiceNoteClient({http.Client? client, this.log})
    : _client = client ?? http.Client();

  final http.Client _client;
  final ModelCallLog? log;

  static const _timeout = Duration(seconds: 60);

  Future<String> formatNote(VoiceNoteSettings settings, String transcript) {
    final prompt = voiceFormatPrompt(transcript);
    return switch (settings.model) {
      ShelfModelChoice.off => throw StateError('Модель не выбрана'),
      ShelfModelChoice.kimi => _kimiText(
        apiKey: settings.kimiKey,
        prompt: prompt,
        kind: 'текст',
      ),
      ShelfModelChoice.yandex => _yandexText(
        apiKey: settings.yandexKey,
        folderId: settings.folderId,
        prompt: prompt,
      ),
    };
  }

  Future<String> transcribeFile(VoiceNoteSettings settings, String path) async {
    final bytes = await File(path).readAsBytes();
    final kind = storedAudioKind(path);
    return switch (settings.model) {
      ShelfModelChoice.off => throw StateError('Модель не выбрана'),
      ShelfModelChoice.kimi => _kimiAudio(
        apiKey: settings.kimiKey,
        audio: bytes,
        kind: kind,
      ),
      ShelfModelChoice.yandex => _yandexAudio(
        apiKey: settings.yandexKey,
        folderId: settings.folderId,
        audio: bytes,
        kind: kind,
      ),
    };
  }

  void close() => _client.close();

  Future<String> _kimiText({
    required String apiKey,
    required String prompt,
    required String kind,
  }) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      await _record(model: '$kimiVisionModel · $kind', error: 'нет ключа');
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
              'model': kimiVisionModel,
              'thinking': {'type': 'disabled'},
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
            }),
          )
          .timeout(_timeout);
      return await _chatText(
        response: response,
        model: '$kimiVisionModel · $kind',
        secrets: [key],
        emptyMessage: 'Kimi вернул пустой ответ.',
        failure: (code, detail) => detail.isEmpty
            ? 'Kimi ответил кодом $code.'
            : 'Kimi ответил кодом $code. $detail',
        unreachable: 'Не удалось связаться с Kimi.',
      );
    } on MetadataLookupException {
      rethrow;
    } catch (_) {
      await _record(model: '$kimiVisionModel · $kind', error: 'нет связи');
      throw MetadataLookupException('Не удалось связаться с Kimi.');
    }
  }

  Future<String> _kimiAudio({
    required String apiKey,
    required Uint8List audio,
    required StoredAudioKind kind,
  }) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      await _record(model: '$kimiVisionModel · запись', error: 'нет ключа');
      throw MetadataLookupException('Добавьте ключ Kimi в настройках.');
    }
    final format = switch (kind) {
      StoredAudioKind.oggOpus => 'ogg',
      StoredAudioKind.wav => 'wav',
    };
    try {
      final response = await _client
          .post(
            Uri.https('api.moonshot.ai', '/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $key',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': kimiVisionModel,
              'thinking': {'type': 'disabled'},
              'messages': [
                {
                  'role': 'user',
                  'content': [
                    {
                      'type': 'input_audio',
                      'input_audio': {
                        'data': base64Encode(audio),
                        'format': format,
                      },
                    },
                    {'type': 'text', 'text': voiceTranscribePrompt},
                  ],
                },
              ],
            }),
          )
          .timeout(_timeout);
      return await _chatText(
        response: response,
        model: '$kimiVisionModel · запись',
        secrets: [key],
        emptyMessage: 'Kimi вернул пустой ответ.',
        failure: (code, detail) => detail.isEmpty
            ? 'Kimi ответил кодом $code.'
            : 'Kimi ответил кодом $code. $detail',
        unreachable: 'Не удалось связаться с Kimi.',
      );
    } on MetadataLookupException {
      rethrow;
    } catch (_) {
      await _record(model: '$kimiVisionModel · запись', error: 'нет связи');
      throw MetadataLookupException('Не удалось связаться с Kimi.');
    }
  }

  Future<String> _yandexText({
    required String apiKey,
    required String folderId,
    required String prompt,
  }) async {
    final key = apiKey.trim();
    final folder = folderId.trim();
    await _requireYandex(key, folder, '$yandexVisionModelName · текст');
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
      return await _chatText(
        response: response,
        model: '$yandexVisionModelName · текст',
        secrets: [key, folder],
        emptyMessage: 'Яндекс вернул пустой ответ.',
        failure: yandexFailureMessage,
        unreachable: 'Не удалось связаться с Яндексом.',
      );
    } on MetadataLookupException {
      rethrow;
    } catch (_) {
      await _record(model: '$yandexVisionModelName · текст', error: 'нет связи');
      throw MetadataLookupException('Не удалось связаться с Яндексом.');
    }
  }

  Future<String> _yandexAudio({
    required String apiKey,
    required String folderId,
    required Uint8List audio,
    required StoredAudioKind kind,
  }) async {
    final key = apiKey.trim();
    final folder = folderId.trim();
    await _requireYandex(key, folder, 'speechkit · запись');
    final prepared = switch (kind) {
      StoredAudioKind.oggOpus => audio,
      StoredAudioKind.wav => _lpcm(audio),
    };
    final query = switch (kind) {
      StoredAudioKind.oggOpus => {
        'lang': 'ru-RU',
        'format': 'oggopus',
        'folderId': folder,
      },
      StoredAudioKind.wav => {
        'lang': 'ru-RU',
        'format': 'lpcm',
        'sampleRateHertz': '${_wavSampleRate(audio)}',
        'folderId': folder,
      },
    };
    try {
      final response = await _client
          .post(
            Uri.https(
              'stt.api.cloud.yandex.net',
              '/speech/v1/stt:recognize',
              query,
            ),
            headers: {
              'Authorization': 'Api-Key $key',
              'Content-Type': 'application/octet-stream',
            },
            body: prepared,
          )
          .timeout(_timeout);
      if (response.statusCode != 200) {
        final detail = _safeDetail(response.body, [key, folder]);
        await _record(
          model: 'speechkit · запись',
          statusCode: response.statusCode,
          error: detail.isEmpty ? 'код ${response.statusCode}' : detail,
        );
        throw MetadataLookupException(
          yandexFailureMessage(response.statusCode, detail),
        );
      }
      final text = _speechResult(jsonDecode(response.body));
      if (text.isEmpty) {
        await _record(
          model: 'speechkit · запись',
          statusCode: response.statusCode,
          error: 'Яндекс вернул пустой ответ.',
        );
        throw MetadataLookupException('Яндекс вернул пустой ответ.');
      }
      await _record(model: 'speechkit · запись', statusCode: response.statusCode);
      return text;
    } on MetadataLookupException {
      rethrow;
    } on ShelfReadingException catch (error) {
      await _record(
        model: 'speechkit · запись',
        statusCode: 200,
        error: error.message,
      );
      throw MetadataLookupException(error.message);
    } catch (_) {
      await _record(model: 'speechkit · запись', error: 'нет связи');
      throw MetadataLookupException('Не удалось связаться с Яндексом.');
    }
  }

  Future<void> _requireYandex(String key, String folder, String model) async {
    if (key.isEmpty || folder.isEmpty) {
      await _record(model: model, error: 'нет ключа');
      throw MetadataLookupException(
        'Добавьте ключ и каталог Яндекса в настройках.',
      );
    }
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,80}$').hasMatch(folder)) {
      await _record(model: model, error: 'неверный каталог');
      throw MetadataLookupException('Проверьте идентификатор каталога Яндекса.');
    }
  }

  Future<String> _chatText({
    required http.Response response,
    required String model,
    required List<String> secrets,
    required String emptyMessage,
    required String Function(int code, String detail) failure,
    required String unreachable,
  }) async {
    if (response.statusCode != 200) {
      final detail = _safeDetail(response.body, secrets);
      await _record(
        model: model,
        statusCode: response.statusCode,
        error: detail.isEmpty ? 'код ${response.statusCode}' : detail,
      );
      throw MetadataLookupException(failure(response.statusCode, detail));
    }
    try {
      final text = _messageText(jsonDecode(response.body)).trim();
      if (text.isEmpty) {
        await _record(
          model: model,
          statusCode: response.statusCode,
          error: emptyMessage,
        );
        throw MetadataLookupException(emptyMessage);
      }
      await _record(model: model, statusCode: response.statusCode);
      return text;
    } on MetadataLookupException {
      rethrow;
    } on ShelfReadingException catch (error) {
      await _record(model: model, statusCode: 200, error: error.message);
      throw MetadataLookupException(error.message);
    } catch (_) {
      await _record(model: model, error: 'нет связи');
      throw MetadataLookupException(unreachable);
    }
  }

  String _speechResult(Object? json) {
    if (json is! Map) {
      throw const ShelfReadingException('Яндекс вернул непонятный ответ.');
    }
    final result = json['result'];
    if (result is! String) {
      throw const ShelfReadingException('Яндекс вернул непонятный ответ.');
    }
    return result.trim();
  }

  String _messageText(Object? json) {
    if (json is! Map) {
      throw const ShelfReadingException('Модель вернула непонятный ответ.');
    }
    final choices = json['choices'];
    if (choices is! List || choices.isEmpty || choices.first is! Map) {
      throw const ShelfReadingException('Модель вернула непонятный ответ.');
    }
    final message = (choices.first as Map)['message'];
    if (message is! Map) {
      throw const ShelfReadingException('Модель вернула непонятный ответ.');
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
    throw const ShelfReadingException('Модель вернула непонятный ответ.');
  }

  Uint8List _lpcm(Uint8List wav) {
    for (var index = 12; index + 8 < wav.length; index++) {
      if (wav[index] == 0x64 &&
          wav[index + 1] == 0x61 &&
          wav[index + 2] == 0x74 &&
          wav[index + 3] == 0x61) {
        final size = ByteData.sublistView(wav, index + 4, index + 8).getUint32(
          0,
          Endian.little,
        );
        final start = index + 8;
        final end = start + size;
        if (end <= wav.length) {
          return Uint8List.sublistView(wav, start, end);
        }
      }
    }
    if (wav.length > 44) {
      return Uint8List.sublistView(wav, 44);
    }
    return wav;
  }

  int _wavSampleRate(Uint8List wav) {
    if (wav.length < 28) {
      return 16000;
    }
    final rate = ByteData.sublistView(wav, 24, 28).getUint32(0, Endian.little);
    if (rate == 8000 || rate == 16000 || rate == 48000) {
      return rate;
    }
    return 16000;
  }

  String _safeDetail(String body, List<String> secrets) {
    final stripped = body.replaceAll(RegExp(r'[A-Za-z0-9+/]{80,}={0,2}'), '');
    return modelErrorDetail(stripped, secrets: secrets);
  }

  Future<void> _record({
    required String model,
    int? statusCode,
    String? error,
  }) async {
    final sink = log;
    if (sink == null) {
      return;
    }
    await sink(
      ModelCallRecord(model: model, statusCode: statusCode, error: error),
    );
  }
}
