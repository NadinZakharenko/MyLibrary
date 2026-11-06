import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/core/logging/app_log.dart';

void main() {
  test('writes actions only while logging is enabled', () async {
    final root = await Directory.systemTemp.createTemp('mylibrary_log_');
    addTearDown(() async {
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    });
    final log = AppLog(File('${root.path}/app.log'));

    await log.write('Скрыто', 'не должно попасть в файл');
    expect(await log.file.exists(), isFalse);

    log.enabled = true;
    await log.write('Поиск в каталоге', 'ISBN 9780140328721');
    await log.write('Карточка заполнена', '«Fantastic Mr. Fox»');
    log.enabled = false;
    await log.write('После выключения');

    final text = await log.readText();
    expect(text, contains('Поиск в каталоге | ISBN 9780140328721'));
    expect(text, contains('Карточка заполнена'));
    expect(text, isNot(contains('Скрыто')));
    expect(text, isNot(contains('После выключения')));

    await log.clear();
    expect(await log.readText(), isEmpty);
  });

  test('speech and model failures are kept when the journal is off', () async {
    final root = await Directory.systemTemp.createTemp('mylibrary_log_');
    addTearDown(() async {
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    });
    final log = AppLog(File('${root.path}/app.log'));

    await log.writeAlways('Распознавание речи', 'ошибка: error_audio, permanent: true');
    await log.writeAlways('Модель · заметка', 'нет ключа');

    final text = await log.readText();
    expect(text, contains('Распознавание речи | ошибка: error_audio, permanent: true'));
    expect(text, contains('Модель · заметка | нет ключа'));
  });

  test('journal lines drop the exception prefix and secrets', () {
    expect(
      journalDetail(StateError('Яндекс Книги ответили 401')),
      'Яндекс Книги ответили 401',
    );
    expect(
      journalDetail(
        Exception('Telegram https://api.telegram.org/bot123456:ABC_def/getMe'),
      ),
      'Telegram https://api.telegram.org/bot…/getMe',
    );
    expect(journalDetail('Bearer y0_AgAAAASecret'), 'Bearer …');
  });
}
