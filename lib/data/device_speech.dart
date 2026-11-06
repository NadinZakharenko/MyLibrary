import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:my_library/core/notes/voice_note.dart';

class SystemPhoneRecognizer implements PhoneRecognizer {
  SystemPhoneRecognizer({SpeechToText? speech, this.log})
    : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  final void Function(String detail)? log;
  Completer<PhoneRecognition>? _pending;
  var _transcript = '';
  var _failed = false;
  var _armed = false;

  @override
  Future<void> start() async {
    final pending = _pending;
    if (pending != null && !pending.isCompleted) {
      throw StateError('Распознавание уже идёт.');
    }
    _transcript = '';
    _failed = false;
    _armed = false;
    final completer = Completer<PhoneRecognition>();
    _pending = completer;
    try {
      final ready = await _speech.initialize(
        onError: (error) {
          _note('ошибка: ${error.errorMsg}, permanent: ${error.permanent}');
          _failed = true;
          _finish();
        },
        onStatus: (status) {
          _note('статус: $status');
          if (!_armed) {
            return;
          }
          if (status == 'done' || status == 'notListening') {
            _finish();
          }
        },
      );
      if (!ready) {
        _pending = null;
        _note('распознаватель недоступен');
        throw StateError('Распознавание речи на этом телефоне недоступно.');
      }
      String? localeId;
      try {
        final locales = await _speech.locales();
        localeId = russianSpeechLocale([
          for (final locale in locales) locale.localeId,
        ]);
        _note(localeId == null ? 'язык не выбран' : 'язык: $localeId');
      } catch (error) {
        localeId = null;
        _note('список языков недоступен: $error');
      }
      await _speech.listen(
        onResult: (result) {
          final words = result.recognizedWords.trim();
          if (words.isNotEmpty) {
            _transcript = result.recognizedWords;
          }
          if (result.finalResult) {
            _finish();
          }
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          partialResults: true,
          cancelOnError: true,
          localeId: localeId,
          listenFor: const Duration(seconds: 45),
          pauseFor: const Duration(seconds: 5),
        ),
      );
      _armed = true;
      _note('прослушивание начато');
      if (!_speech.isListening) {
        _note('прослушивание не началось');
        _finish();
      }
    } catch (error) {
      _note('сбой старта: $error');
      if (identical(_pending, completer) && !completer.isCompleted) {
        _pending = null;
      }
      rethrow;
    }
  }

  @override
  Future<PhoneRecognition> result() {
    final pending = _pending;
    if (pending == null) {
      return Future.value(
        const PhoneRecognition(transcript: '', failed: true),
      );
    }
    return pending.future.timeout(
      const Duration(seconds: 50),
      onTimeout: () {
        _finish();
        return PhoneRecognition(
          transcript: _transcript,
          failed: _transcript.trim().isEmpty,
        );
      },
    );
  }

  @override
  Future<void> stop() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    _finish();
  }

  void _finish() {
    final pending = _pending;
    if (pending == null || pending.isCompleted) {
      return;
    }
    final transcript = _transcript.trim();
    _note(transcript.isEmpty ? 'итог: пусто' : 'итог: ${transcript.length} симв.');
    pending.complete(
      PhoneRecognition(
        transcript: _transcript,
        failed: _failed && transcript.isEmpty,
      ),
    );
  }

  void _note(String detail) {
    log?.call(detail);
  }
}

class SystemNoteRecorder implements NoteRecorder {
  SystemNoteRecorder({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  String? _path;
  var _started = false;

  @override
  Future<void> start() async {
    final allowed = await _recorder.hasPermission();
    if (!allowed) {
      throw StateError('Нет доступа к микрофону.');
    }
    final opus = await _recorder.isEncoderSupported(AudioEncoder.opus);
    final encoder = opus ? AudioEncoder.opus : AudioEncoder.wav;
    final extension = opus ? 'ogg' : 'wav';
    final directory = await getTemporaryDirectory();
    _path =
        '${directory.path}${Platform.pathSeparator}note-${DateTime.now().microsecondsSinceEpoch}.$extension';
    try {
      await _recorder.start(
        RecordConfig(
          encoder: encoder,
          bitRate: 32000,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _path!,
      );
      _started = true;
    } catch (_) {
      _path = null;
      rethrow;
    }
  }

  @override
  Future<String?> stop() async {
    if (!_started) {
      return null;
    }
    _started = false;
    String? path;
    try {
      path = await _recorder.stop();
    } catch (_) {
      path = _path;
    }
    final kept = path ?? _path;
    _path = null;
    if (kept == null) {
      return null;
    }
    final file = File(kept);
    if (!await file.exists()) {
      return null;
    }
    if (await file.length() < 800) {
      await file.delete();
      return null;
    }
    return kept;
  }

  @override
  Future<void> discard() async {
    final path = await stop();
    if (path == null) {
      return;
    }
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> dispose() => _recorder.dispose();
}
