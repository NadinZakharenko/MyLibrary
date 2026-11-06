import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class LiveLibResult {
  const LiveLibResult({required this.ok, required this.message});

  final bool ok;
  final String message;
}

/// Signs in with the site form and repeats the status form when the page exposes one.
class LiveLibAccount {
  LiveLibAccount({http.Client? client}) : _client = client ?? IOClient(HttpClient());

  final http.Client _client;

  Future<LiveLibResult> check({
    required String login,
    required String password,
  }) async {
    try {
      final home = await _client.get(_uri('/login'));
      if (home.statusCode >= 400) {
        return LiveLibResult(
          ok: false,
          message: 'LiveLib ответил ${home.statusCode}',
        );
      }
      final signedIn = await _submitLogin(home, login, password);
      if (!signedIn) {
        return const LiveLibResult(
          ok: false,
          message: 'LiveLib не пустил в профиль. Проверьте логин и пароль.',
        );
      }
      return const LiveLibResult(ok: true, message: 'Вход в LiveLib выполнен.');
    } catch (_) {
      return const LiveLibResult(ok: false, message: 'Нет связи с LiveLib.');
    }
  }

  Future<LiveLibResult> send({
    required String login,
    required String password,
    required String bookUrl,
    required String statusLabel,
    String reviewTitle = '',
    String review = '',
    int? rating,
  }) async {
    final gate = await check(login: login, password: password);
    if (!gate.ok) {
      return gate;
    }
    try {
      final page = await _client.get(Uri.parse(bookUrl));
      if (page.statusCode >= 400) {
        return LiveLibResult(
          ok: false,
          message: 'Страница книги ответила ${page.statusCode}',
        );
      }
      final form = _form(page.body, page.request?.url ?? Uri.parse(bookUrl));
      if (form == null) {
        return const LiveLibResult(
          ok: false,
          message: 'Форма отметки на странице не найдена.',
        );
      }
      form.fields[_statusField(form.fields.keys) ?? 'status'] = _statusValue(statusLabel);
      if (rating != null) {
        form.fields[_ratingField(form.fields.keys) ?? 'rating'] = '$rating';
      }
      if (review.trim().isNotEmpty) {
        form.fields[_textField(form.fields.keys) ?? 'text'] = review.trim();
        form.fields[_titleField(form.fields.keys) ?? 'title'] = reviewTitle.trim();
      }
      final sent = await _client.post(form.action, body: form.fields);
      if (sent.statusCode >= 400) {
        return LiveLibResult(
          ok: false,
          message: 'LiveLib ответил ${sent.statusCode}',
        );
      }
      return const LiveLibResult(ok: true, message: 'Отметка отправлена на LiveLib.');
    } catch (_) {
      return const LiveLibResult(ok: false, message: 'Нет связи с LiveLib.');
    }
  }

  Future<bool> _submitLogin(http.Response page, String login, String password) async {
    final action = _form(page.body, page.request?.url ?? _uri('/login'));
    final fields = action?.fields ?? _hidden(page.body);
    fields['login'] = login.trim();
    fields['password'] = password;
    fields.putIfAbsent('user[login]', () => login.trim());
    fields.putIfAbsent('user[password]', () => password);
    final target = action?.action ?? _uri('/login');
    final response = await _client.post(target, body: fields);
    final body = response.body.toLowerCase();
    return body.contains('выйти') || body.contains('/reader/');
  }

  _HtmlForm? _form(String html, Uri page) {
    final form = RegExp(
      '<form[^>]*action=["\']([^"\']*)["\'][^>]*>(.*?)</form>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    if (form == null) {
      return null;
    }
    final actionRaw = form.group(1) ?? '';
    final action = actionRaw.isEmpty
        ? page
        : page.resolve(actionRaw);
    return _HtmlForm(action, _hidden(form.group(2) ?? ''));
  }

  Map<String, String> _hidden(String html) {
    final fields = <String, String>{};
    final input = RegExp(
      r'<input[^>]*name=["' "'" r']([^"' "'" r']+)["' "'" r'][^>]*>',
      caseSensitive: false,
    );
    for (final match in input.allMatches(html)) {
      final tag = match.group(0) ?? '';
      final name = match.group(1);
      if (name == null || name.isEmpty) {
        continue;
      }
      final value = RegExp(
        'value=["\']([^"\']*)["\']',
        caseSensitive: false,
      ).firstMatch(tag)?.group(1);
      fields[name] = value ?? '';
    }
    return fields;
  }

  String? _statusField(Iterable<String> names) => _named(names, const ['status', 'state', 'read_status']);

  String? _ratingField(Iterable<String> names) => _named(names, const ['rating', 'mark', 'score']);

  String? _textField(Iterable<String> names) => _named(names, const ['text', 'body', 'review', 'content']);

  String? _titleField(Iterable<String> names) => _named(names, const ['title', 'header', 'subject']);

  String? _named(Iterable<String> names, List<String> hints) {
    for (final name in names) {
      final lower = name.toLowerCase();
      for (final hint in hints) {
        if (lower.contains(hint)) {
          return name;
        }
      }
    }
    return null;
  }

  String _statusValue(String label) {
    final text = label.toLowerCase();
    if (text.contains('читаю')) {
      return 'reading';
    }
    if (text.contains('хочу')) {
      return 'to-read';
    }
    return 'read';
  }

  Uri _uri(String path) => Uri.https('www.livelib.ru', path);

  void close() => _client.close();
}

class _HtmlForm {
  _HtmlForm(this.action, this.fields);

  final Uri action;
  final Map<String, String> fields;
}
