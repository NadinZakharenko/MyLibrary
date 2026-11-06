import 'dart:io';

/// Journal line without the exception class and without secrets.
String journalDetail(Object error) {
  final raw = switch (error) {
    StateError(:final message) => message,
    FormatException(:final message) =>
      message.trim().isEmpty ? 'некорректный ответ' : message,
    _ => '$error',
  };
  var text = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  const prefixes = [
    'Bad state: ',
    'Exception: ',
    'FormatException: ',
    'ClientException: ',
    'SocketException: ',
    'HandshakeException: ',
    'HttpException: ',
  ];
  var stripped = true;
  while (stripped) {
    stripped = false;
    for (final prefix in prefixes) {
      if (text.startsWith(prefix)) {
        text = text.substring(prefix.length).trim();
        stripped = true;
      }
    }
  }
  text = text.replaceAll(RegExp('bot\\d+:[A-Za-z0-9_-]+'), 'bot…');
  text = text.replaceAll(RegExp('y0_[A-Za-z0-9_-]+'), 'y0_…');
  text = text.replaceAll(
    RegExp('Bearer\\s+\\S+', caseSensitive: false),
    'Bearer …',
  );
  text = text.replaceAll(
    RegExp('Auth-Token:\\s*\\S+', caseSensitive: false),
    'Auth-Token: …',
  );
  return text;
}

/// Local action log. Writes nothing until [enabled] is true.
class AppLog {
  AppLog(this.file);

  final File file;
  var enabled = false;
  Future<void> _queue = Future<void>.value();

  Future<void> write(String action, [String? detail]) {
    if (!enabled) {
      return Future<void>.value();
    }
    return writeAlways(action, detail);
  }

  /// Speech and note-model failures stay visible when the journal switch is off.
  Future<void> writeAlways(String action, [String? detail]) {
    final line = _line(action, detail);
    _queue = _queue.then((_) => _append(line)).catchError((Object _) {});
    return _queue;
  }

  Future<String> readText() async {
    if (!await file.exists()) {
      return '';
    }
    return file.readAsString();
  }

  Future<void> clear() async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  static String _line(String action, String? detail) {
    final stamp = DateTime.now().toIso8601String();
    final extra = detail == null || detail.trim().isEmpty
        ? ''
        : ' | ${_clip(detail)}';
    return '$stamp | $action$extra';
  }

  static String _clip(String value) {
    final text = journalDetail(value);
    if (text.length <= 240) {
      return text;
    }
    return '${text.substring(0, 240)}…';
  }

  Future<void> _append(String line) async {
    await file.parent.create(recursive: true);
    final existing = await file.exists() ? await file.readAsString() : '';
    var next = existing.isEmpty ? '$line\n' : '$existing$line\n';
    const maxLength = 200000;
    if (next.length > maxLength) {
      next = next.substring(next.length - 150000);
      final cut = next.indexOf('\n');
      if (cut >= 0) {
        next = next.substring(cut + 1);
      }
    }
    await file.writeAsString(next, flush: true);
  }
}
