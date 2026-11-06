import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/core/database/app_database.dart';
import 'package:my_library/core/models/book_draft.dart';
import 'package:my_library/core/models/reading_status.dart';
import 'package:my_library/core/notes/voice_note.dart';
import 'package:my_library/core/storage/image_store.dart';
import 'package:my_library/core/storage/library_paths.dart';
import 'package:my_library/data/library_repository.dart';

void main() {
  test('appends a dictated note after a blank line', () {
    expect(appendBookNote('Уже есть', 'Новая мысль'), 'Уже есть\n\nНовая мысль');
    expect(appendBookNote('', 'Новая мысль'), 'Новая мысль');
    expect(appendBookNote('Уже есть', '   '), 'Уже есть');
    expect(appendBookNote('   ', ''), '   ');
  });

  test('formatting is skipped when consent is off', () async {
    var calls = 0;
    Future<String> format(String text) async {
      calls += 1;
      return 'Книга хорошая.';
    }

    final skipped = await formatDictatedNote(
      existing: 'Уже есть',
      transcript: 'ну это хорошая книга',
      userAsked: false,
      consent: true,
      modelSelected: true,
      credentialsReady: true,
      format: format,
    );
    expect(calls, 0);
    expect(skipped.sent, isFalse);
    expect(skipped.text, 'Уже есть');
    expect(skipped.message, isNull);

    final denied = await formatDictatedNote(
      existing: 'Уже есть',
      transcript: 'ну это хорошая книга',
      userAsked: true,
      consent: false,
      modelSelected: true,
      credentialsReady: true,
      format: format,
    );
    expect(calls, 0);
    expect(denied.sent, isFalse);
    expect(denied.text, 'Уже есть');
    expect(denied.message, voiceFormatSwitchOffMessage);

    final formatted = await formatDictatedNote(
      existing: 'Уже есть',
      transcript: 'ну это хорошая книга',
      userAsked: true,
      consent: true,
      modelSelected: true,
      credentialsReady: true,
      format: (text) async {
        calls += 1;
        expect(text, 'ну это хорошая книга');
        return 'Книга хорошая.';
      },
    );
    expect(calls, 1);
    expect(formatted.sent, isTrue);
    expect(formatted.text, 'Уже есть\n\nКнига хорошая.');
  });

  test('a failed phone recognizer does not send the recording by itself', () async {
    final recorder = _Recorder();
    final captured = await capturePhoneNote(
      recognizer: _Recognizer(
        const PhoneRecognition(transcript: 'Новая мысль'),
      ),
    );
    expect(captured.transcript, 'Новая мысль');
    expect(captured.recordingPath, isNull);
    expect(recorder.started, isFalse);
    expect(
      appendBookNote('Уже есть', captured.transcript),
      'Уже есть\n\nНовая мысль',
    );

    final failedRecorder = _Recorder();
    final failed = await capturePhoneNote(
      recognizer: _Recognizer(
        const PhoneRecognition(transcript: '   ', failed: true),
      ),
    );
    expect(failed.transcript, isEmpty);
    expect(failed.recordingPath, isNull);
    expect(failedRecorder.started, isFalse);

    var sent = 0;
    Future<String> transcribe() async {
      sent += 1;
      return 'из записи';
    }

    final unasked = await transcribeRecordingIfAllowed(
      existing: 'Уже есть',
      userAsked: false,
      consent: true,
      modelSelected: true,
      credentialsReady: true,
      transcribe: transcribe,
    );
    expect(sent, 0);
    expect(unasked.text, 'Уже есть');
    expect(unasked.message, isNull);

    final denied = await transcribeRecordingIfAllowed(
      existing: 'Уже есть',
      userAsked: true,
      consent: false,
      modelSelected: true,
      credentialsReady: true,
      transcribe: transcribe,
    );
    expect(sent, 0);
    expect(denied.sent, isFalse);
    expect(denied.text, 'Уже есть');
    expect(denied.message, voiceRecordingSwitchOffMessage);
  });

  group('stored note', () {
    late Directory temp;
    late AppDatabase db;
    late LibraryRepository repo;

    setUp(() async {
      temp = await Directory.systemTemp.createTemp('mylibrary_note_');
      db = AppDatabase(NativeDatabase.memory());
      repo = LibraryRepository(db, ImageStore(LibraryPaths(temp)));
      await repo.images.ensureDirs();
    });

    tearDown(() async {
      await db.close();
      if (await temp.exists()) {
        await temp.delete(recursive: true);
      }
    });

    test('saving a note leaves description, publishers and status', () async {
      final id = await repo.createBook(
        const BookDraft(
          title: 'Книга',
          description: 'Каталог',
          publishers: ['Азбука'],
          personalNote: '',
          readingStatus: ReadingStatus.reading,
        ),
      );
      final created = (await repo.bookDetails(id))!;
      expect(created.personalNote, isEmpty);
      expect(created.description, 'Каталог');

      await repo.updatePersonalNote(id, 'Моя мысль');
      final noted = (await repo.bookDetails(id))!;
      expect(noted.personalNote, 'Моя мысль');
      expect(noted.description, 'Каталог');
      expect(noted.publishers, ['Азбука']);
      expect(noted.readingStatus, ReadingStatus.reading);

      await repo.updatePersonalNote(id, '   ');
      expect((await repo.bookDetails(id))!.personalNote, isEmpty);
      expect((await repo.bookDetails(id))!.description, 'Каталог');
      expect((await repo.bookDetails(id))!.readingStatus, ReadingStatus.reading);
    });
  });
}

class _Recognizer implements PhoneRecognizer {
  _Recognizer(this.recognition);

  final PhoneRecognition recognition;

  @override
  Future<void> start() async {}

  @override
  Future<PhoneRecognition> result() async => recognition;

  @override
  Future<void> stop() async {}
}

class _Recorder implements NoteRecorder {
  var started = false;
  var discarded = false;
  var stopped = false;

  @override
  Future<void> start() async {
    started = true;
  }

  @override
  Future<String?> stop() async {
    stopped = true;
    return 'note.ogg';
  }

  @override
  Future<void> discard() async {
    discarded = true;
  }
}
