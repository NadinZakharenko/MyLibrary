import 'package:my_library/core/models/shelf_model.dart';

const voiceFormatSwitchOffMessage =
    'В настройках выключен переключатель «Разрешить приводить текст заметки в порядок».';

const voiceRecordingSwitchOffMessage =
    'В настройках выключен переключатель «Разрешить отправку записи, если телефон не распознал речь».';

const voiceModelOffMessage =
    'Модель для заметок выключена. Её можно выбрать в настройках.';

const voiceCredentialsMessage =
    'Добавьте ключ выбранной модели в настройках.';

const phoneDidNotRecognizeMessage = 'Телефон не распознал речь.';

const voiceFormatPromptLead =
    'Перепиши текст в аккуратную русскую заметку. Расставь знаки препинания и раздели абзацы. Убери слова-паразиты. Не добавляй фактов и не меняй смысл. Верни только текст заметки.';

const voiceTranscribePrompt =
    'Расшифруй русскую речь из записи. Верни только распознанный текст, без пояснений и без новых фактов.';

/// Keeps an empty note empty. A new note is appended after a blank line.
String appendBookNote(String existing, String addition) {
  final next = addition.trim();
  if (next.isEmpty) {
    return existing;
  }
  if (existing.trim().isEmpty) {
    return next;
  }
  return '${existing.trimRight()}\n\n$next';
}

String voiceFormatPrompt(String transcript) {
  return '$voiceFormatPromptLead\n\n${transcript.trim()}';
}

class VoiceNoteSettings {
  const VoiceNoteSettings({
    required this.model,
    required this.recordingConsent,
    required this.formatConsent,
    required this.kimiKey,
    required this.yandexKey,
    required this.folderId,
  });

  final ShelfModelChoice model;
  final bool recordingConsent;
  final bool formatConsent;
  final String kimiKey;
  final String yandexKey;
  final String folderId;

  bool get modelSelected => model != ShelfModelChoice.off;

  bool get credentialsReady {
    return switch (model) {
      ShelfModelChoice.off => false,
      ShelfModelChoice.kimi => kimiKey.trim().isNotEmpty,
      ShelfModelChoice.yandex =>
        yandexKey.trim().isNotEmpty && folderId.trim().isNotEmpty,
    };
  }
}

class NoteModelResult {
  const NoteModelResult({
    required this.text,
    required this.sent,
    this.message,
    this.transcript,
  });

  final String text;
  final bool sent;
  final String? message;
  final String? transcript;
}

class NoteFormatParts {
  const NoteFormatParts({required this.existing, required this.transcript});

  final String existing;
  final String transcript;
}

/// Formats only the latest dictated piece when the field still ends with it.
NoteFormatParts notePartsForFormat({
  required String fieldText,
  required String? dictated,
  required String textBeforeDictation,
}) {
  final spoken = dictated?.trim() ?? '';
  if (spoken.isEmpty) {
    return NoteFormatParts(existing: '', transcript: fieldText);
  }
  final composed = appendBookNote(textBeforeDictation, spoken);
  if (fieldText == composed) {
    return NoteFormatParts(existing: textBeforeDictation, transcript: spoken);
  }
  return NoteFormatParts(existing: '', transcript: fieldText);
}

Future<NoteModelResult> formatDictatedNote({
  required String existing,
  required String transcript,
  required bool userAsked,
  required bool consent,
  required bool modelSelected,
  required bool credentialsReady,
  required Future<String> Function(String text) format,
}) async {
  final gate = _sendGate(
    userAsked: userAsked,
    consent: consent,
    consentOffMessage: voiceFormatSwitchOffMessage,
    modelSelected: modelSelected,
    credentialsReady: credentialsReady,
  );
  if (!gate.allowed) {
    return NoteModelResult(text: existing, sent: false, message: gate.message);
  }
  final source = transcript.trim();
  if (source.isEmpty) {
    return NoteModelResult(text: existing, sent: false);
  }
  final formatted = (await format(source)).trim();
  if (formatted.isEmpty) {
    return NoteModelResult(
      text: existing,
      sent: true,
      message: 'Модель вернула пустой текст.',
    );
  }
  return NoteModelResult(
    text: appendBookNote(existing, formatted),
    sent: true,
    transcript: formatted,
  );
}

Future<NoteModelResult> transcribeRecordingIfAllowed({
  required String existing,
  required bool userAsked,
  required bool consent,
  required bool modelSelected,
  required bool credentialsReady,
  required Future<String> Function() transcribe,
}) async {
  final gate = _sendGate(
    userAsked: userAsked,
    consent: consent,
    consentOffMessage: voiceRecordingSwitchOffMessage,
    modelSelected: modelSelected,
    credentialsReady: credentialsReady,
  );
  if (!gate.allowed) {
    return NoteModelResult(text: existing, sent: false, message: gate.message);
  }
  final transcript = (await transcribe()).trim();
  if (transcript.isEmpty) {
    return NoteModelResult(
      text: existing,
      sent: true,
      message: 'Модель не распознала запись.',
    );
  }
  return NoteModelResult(
    text: appendBookNote(existing, transcript),
    sent: true,
    transcript: transcript,
  );
}

class _SendGate {
  const _SendGate({required this.allowed, this.message});

  final bool allowed;
  final String? message;
}

_SendGate _sendGate({
  required bool userAsked,
  required bool consent,
  required String consentOffMessage,
  required bool modelSelected,
  required bool credentialsReady,
}) {
  if (!userAsked) {
    return const _SendGate(allowed: false);
  }
  if (!consent) {
    return _SendGate(allowed: false, message: consentOffMessage);
  }
  if (!modelSelected) {
    return const _SendGate(allowed: false, message: voiceModelOffMessage);
  }
  if (!credentialsReady) {
    return const _SendGate(allowed: false, message: voiceCredentialsMessage);
  }
  return const _SendGate(allowed: true);
}

class PhoneRecognition {
  const PhoneRecognition({required this.transcript, this.failed = false});

  final String transcript;
  final bool failed;
}

abstract class PhoneRecognizer {
  Future<void> start();

  Future<PhoneRecognition> result();

  Future<void> stop();
}

abstract class NoteRecorder {
  Future<void> start();

  Future<String?> stop();

  Future<void> discard();
}

class CapturedNote {
  const CapturedNote({
    required this.transcript,
    this.recordingPath,
    this.error,
  });

  final String transcript;
  final String? recordingPath;
  final Object? error;
}

/// The phone recognizer runs without a model and without the consent switches.
/// The microphone stays with the recognizer. A second recorder would take it
/// and the phone would hear silence until [pauseFor] reports a speech timeout.
Future<CapturedNote> capturePhoneNote({
  required PhoneRecognizer recognizer,
  void Function(String detail)? log,
}) async {
  try {
    await recognizer.start();
  } catch (error) {
    return CapturedNote(transcript: '', error: error);
  }
  Object? error;
  PhoneRecognition recognition = const PhoneRecognition(
    transcript: '',
    failed: true,
  );
  try {
    recognition = await recognizer.result();
  } catch (caught) {
    error = caught;
    log?.call('сбой результата: $caught');
  } finally {
    try {
      await recognizer.stop();
    } catch (stopError) {
      log?.call('остановка распознавателя: $stopError');
    }
  }
  final transcript = recognition.transcript.trim();
  if (error == null && !recognition.failed && transcript.isNotEmpty) {
    return CapturedNote(transcript: transcript);
  }
  return CapturedNote(transcript: '', error: error);
}

/// Records only after the recognizer has released the microphone.
Future<void> startNoteClip({
  required NoteRecorder recorder,
  void Function(String detail)? log,
}) async {
  try {
    await recorder.start();
    log?.call('запись файла начата');
  } catch (error) {
    log?.call('запись файла: $error');
    rethrow;
  }
}

Future<String?> stopNoteClip({
  required NoteRecorder recorder,
  void Function(String detail)? log,
}) async {
  try {
    return await recorder.stop();
  } catch (error) {
    log?.call('остановка записи: $error');
    return null;
  }
}

String? russianSpeechLocale(Iterable<String> localeIds) {
  String? fallback;
  for (final id in localeIds) {
    final normalized = id.trim().toLowerCase().replaceAll('-', '_');
    if (normalized == 'ru_ru') {
      return id;
    }
    if (fallback == null &&
        (normalized == 'ru' || normalized.startsWith('ru_'))) {
      fallback = id;
    }
  }
  return fallback;
}
