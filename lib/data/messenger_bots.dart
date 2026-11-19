import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:my_library/data/russian_trusted_cas.dart';

http.Client? _maxApiClient;

/// Max API presents a certificate from the Russian Trusted CA.
http.Client maxApiClient() {
  return _maxApiClient ??= IOClient(
    HttpClient(context: russianTrustedSecurityContext()),
  );
}

class BotCheck {
  const BotCheck({required this.ok, required this.name, this.message});

  final bool ok;
  final String name;
  final String? message;
}

class MessengerBots {
  const MessengerBots({http.Client? httpClient}) : _http = httpClient;

  final http.Client? _http;

  static const _timeout = Duration(seconds: 20);

  Future<BotCheck> checkTelegram({
    required String expectedName,
    required String token,
  }) async {
    final response = await _get(
      Uri.https('api.telegram.org', '/bot${token.trim()}/getMe'),
    );
    if (response.statusCode != 200) {
      return BotCheck(
        ok: false,
        name: '',
        message: 'Telegram ответил ${response.statusCode}',
      );
    }
    final body = _json(response.body);
    final result = body['result'];
    final username = result is Map ? '${result['username'] ?? ''}' : '';
    return _named(expectedName, username, 'Telegram');
  }

  Future<String?> bindTelegramChat(String token) async {
    final response = await _get(
      Uri.https('api.telegram.org', '/bot${token.trim()}/getUpdates'),
    );
    if (response.statusCode != 200) {
      throw StateError('Telegram ответил ${response.statusCode}');
    }
    final body = _json(response.body);
    final result = body['result'];
    if (result is! List) {
      return null;
    }
    for (final item in result.reversed) {
      if (item is! Map) {
        continue;
      }
      final message = item['message'] ?? item['edited_message'];
      if (message is! Map) {
        continue;
      }
      final chat = message['chat'];
      if (chat is Map && chat['id'] != null) {
        return '${chat['id']}';
      }
    }
    return null;
  }

  Future<void> sendTelegram({
    required String token,
    required String chatId,
    required String text,
  }) async {
    final response = await _post(
      Uri.https('api.telegram.org', '/bot${token.trim()}/sendMessage'),
      {'chat_id': chatId.trim(), 'text': text},
    );
    if (response.statusCode != 200) {
      throw StateError('Telegram ответил ${response.statusCode}');
    }
  }

  Future<BotCheck> checkMax({
    required String expectedName,
    required String token,
  }) async {
    final response = await _get(
      Uri.https('platform-api2.max.ru', '/me'),
      headers: {'Authorization': token.trim()},
    );
    if (response.statusCode != 200) {
      return BotCheck(
        ok: false,
        name: '',
        message: 'Макс ответил ${response.statusCode}',
      );
    }
    final body = _json(response.body);
    final username = '${body['username'] ?? body['name'] ?? body['title'] ?? ''}';
    return _named(expectedName, username, 'Макс');
  }

  Future<String?> bindMaxUser(String token) async {
    final response = await _get(
      Uri.https('platform-api2.max.ru', '/updates'),
      headers: {'Authorization': token.trim()},
    );
    if (response.statusCode != 200) {
      throw StateError('Макс ответил ${response.statusCode}');
    }
    final body = _json(response.body);
    final updates = body['updates'] ?? body['result'] ?? body;
    if (updates is! List) {
      return null;
    }
    for (final item in updates.reversed) {
      if (item is! Map) {
        continue;
      }
      final user = item['user'] ?? item['sender'];
      if (user is Map && user['user_id'] != null) {
        return '${user['user_id']}';
      }
      if (item['user_id'] != null) {
        return '${item['user_id']}';
      }
      final message = item['message'];
      if (message is Map) {
        final sender = message['sender'];
        if (sender is Map && sender['user_id'] != null) {
          return '${sender['user_id']}';
        }
      }
    }
    return null;
  }

  Future<void> sendMax({
    required String token,
    required String userId,
    required String text,
  }) async {
    final response = await _post(
      Uri.https('platform-api2.max.ru', '/messages', {'user_id': userId.trim()}),
      {'text': text},
      headers: {'Authorization': token.trim()},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(_maxFailure(response));
    }
  }

  String _maxFailure(http.Response response) {
    final body = _object(response.body);
    final code = '${body['code'] ?? ''}'.trim();
    final message = '${body['message'] ?? body['error'] ?? ''}'.trim();
    final detail = [
      if (code.isNotEmpty) code,
      if (message.isNotEmpty && message != code) message,
    ].join(': ');
    if (detail.isEmpty) {
      return 'Макс ответил ${response.statusCode}';
    }
    return 'Макс ответил ${response.statusCode}: $detail';
  }

  BotCheck _named(String expected, String actual, String service) {
    final wanted = expected.trim().replaceAll('@', '').toLowerCase();
    final got = actual.trim().replaceAll('@', '').toLowerCase();
    if (wanted.isEmpty || got.isEmpty || wanted != got) {
      return BotCheck(
        ok: false,
        name: actual,
        message: '$service знает бота «$actual». Имя в настройках другое.',
      );
    }
    return BotCheck(ok: true, name: actual);
  }

  Future<http.Response> _get(Uri uri, {Map<String, String>? headers}) {
    final client = _client(uri);
    if (client != null) {
      return client.get(uri, headers: headers).timeout(_timeout);
    }
    return http.get(uri, headers: headers).timeout(_timeout);
  }

  http.Client? _client(Uri uri) {
    final injected = _http;
    if (injected != null) {
      return injected;
    }
    if (uri.host == 'platform-api2.max.ru') {
      return maxApiClient();
    }
    return null;
  }

  Future<http.Response> _post(
    Uri uri,
    Map<String, Object?> body, {
    Map<String, String>? headers,
  }) {
    final payload = jsonEncode(body);
    final sent = {
      'Content-Type': 'application/json',
      ...?headers,
    };
    final client = _client(uri);
    if (client != null) {
      return client.post(uri, headers: sent, body: payload).timeout(_timeout);
    }
    return http.post(uri, headers: sent, body: payload).timeout(_timeout);
  }

  Map<String, Object?> _object(String raw) {
    try {
      return _json(raw);
    } catch (_) {
      return const {};
    }
  }

  Map<String, Object?> _json(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry('$key', value));
    }
    return const {};
  }
}
