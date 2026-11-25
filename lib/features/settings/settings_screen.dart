import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:my_library/core/models/shelf_model.dart';
import 'package:my_library/core/theme/theme_choice.dart';
import 'package:my_library/data/backup_service.dart';
import 'package:my_library/features/settings/account_settings.dart';
import 'package:my_library/features/settings/log_screen.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/common_widgets.dart';
import 'package:my_library/ui/user_message.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _kimiKey = TextEditingController();
  final _yandexKey = TextEditingController();
  final _yandexFolder = TextEditingController();
  var _busy = false;
  var _logging = false;
  var _overflow = true;
  var _kimiConsent = false;
  var _shelfModel = ShelfModelChoice.off;
  var _voiceModel = ShelfModelChoice.off;
  var _voiceRecordingConsent = false;
  var _voiceFormatConsent = false;
  var _open = <String>{};

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      final repository = ref.read(libraryRepositoryProvider);
      final logging = await repository.loggingEnabled();
      final overflow = await repository.rowOverflowControlEnabled();
      final kimiKey = await repository.kimiApiKey();
      final consent = await repository.kimiCloudConsent();
      final shelfModel = await repository.shelfModel();
      final yandexKey = await repository.yandexApiKey();
      final yandexFolder = await repository.yandexFolderId();
      final voice = await repository.voiceNoteSettings();
      final open = await repository.openSettingsSections();
      if (!mounted) {
        return;
      }
      ref.read(appLogProvider).enabled = logging;
      _kimiKey.text = kimiKey ?? '';
      _yandexKey.text = yandexKey ?? '';
      _yandexFolder.text = yandexFolder ?? '';
      setState(() {
        _logging = logging;
        _overflow = overflow;
        _kimiConsent = consent;
        _shelfModel = shelfModel;
        _voiceModel = voice.model;
        _voiceRecordingConsent = voice.recordingConsent;
        _voiceFormatConsent = voice.formatConsent;
        _open = open;
      });
    });
  }

  @override
  void dispose() {
    _kimiKey.dispose();
    _yandexKey.dispose();
    _yandexFolder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AccountSettings(),
          _section('theme', 'Тема', [
          _ThemePicker(
            choice:
                ref.watch(themeChoiceProvider).asData?.value ??
                AppThemeChoice.system,
            onChanged: (choice) {
              ref.read(libraryRepositoryProvider).setThemeChoice(choice);
            },
          ),
          ]),
          _section('backup', 'Резервная копия', [
          const Text(
            'Архив содержит базу и файлы обложек и фото, без ключей Kimi и Яндекса. Импорт сначала проверяет архив, затем заменяет текущую библиотеку на этом устройстве.',
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : _export,
            child: const Text('Экспорт'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : _import,
            child: const Text('Импорт'),
          ),
          ]),
          _section('rows', 'Ряды', [
          const Text(
            'Когда контроль включён, ряд с числом книг больше вместимости подсвечивается. Выключите, если вместимость нужна только как заметка.',
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Контролировать переполнение рядов'),
            value: _overflow,
            onChanged: _busy ? null : _setOverflow,
          ),
          ]),
          _section('shelf', 'Модель полки', [
          const Text(
            'Модель читает корешки на фото полки. Ключи хранятся только на этом устройстве и не попадают в резервную копию и журнал. Снимок уходит в выбранную модель только после согласия. «Не использовать» оставляет фото на телефоне и открывает разметку чертами.',
          ),
          const SizedBox(height: 12),
          RadioGroup<ShelfModelChoice>(
            groupValue: _shelfModel,
            onChanged: (value) {
              if (!_busy && value != null) {
                _setShelfModel(value);
              }
            },
            child: Column(
              children: [
                for (final choice in ShelfModelChoice.values)
                  RadioListTile<ShelfModelChoice>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(shelfModelLabel(choice)),
                    value: choice,
                  ),
              ],
            ),
          ),
          if (_shelfModel == ShelfModelChoice.kimi) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _kimiKey,
              decoration: const InputDecoration(labelText: 'Ключ доступа Kimi'),
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _saveKimiKey,
              child: const Text('Сохранить ключ Kimi'),
            ),
          ],
          if (_shelfModel == ShelfModelChoice.yandex) ...[
            const SizedBox(height: 12),
            const Text(
              'Нужны ключ API и идентификатор каталога Yandex Cloud. Снимок читает Qwen3.6 35B, текст заметок — ЯндексGPT.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yandexKey,
              decoration: const InputDecoration(labelText: 'Ключ доступа Яндекса'),
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yandexFolder,
              decoration: const InputDecoration(labelText: 'Идентификатор каталога'),
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _saveYandex,
              child: const Text('Сохранить Яндекс'),
            ),
          ],
          if (_shelfModel != ShelfModelChoice.off)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Разрешить отправку фото полки'),
              value: _kimiConsent,
              onChanged: _busy ? null : _setKimiConsent,
            ),
          ]),
          _section('voice', 'Голосовая заметка', [
          const Text(
            'Телефон распознаёт речь сам и не ждёт этих переключателей: звук этого пути остаётся на устройстве. Запись уходит в выбранную модель только если телефон ничего не разобрал, вы нажали «Отправить запись модели» и включили разрешение. «Привести в порядок» отправляет текст заметки, не запись, и только со вторым разрешением. Ключи те же, что у модели полки.',
          ),
          const SizedBox(height: 12),
          RadioGroup<ShelfModelChoice>(
            groupValue: _voiceModel,
            onChanged: (value) {
              if (!_busy && value != null) {
                _setVoiceModel(value);
              }
            },
            child: Column(
              children: [
                for (final choice in ShelfModelChoice.values)
                  RadioListTile<ShelfModelChoice>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(shelfModelLabel(choice)),
                    value: choice,
                  ),
              ],
            ),
          ),
          if (_voiceModel == ShelfModelChoice.kimi) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _kimiKey,
              decoration: const InputDecoration(labelText: 'Ключ доступа Kimi'),
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _saveKimiKey,
              child: const Text('Сохранить ключ Kimi'),
            ),
          ],
          if (_voiceModel == ShelfModelChoice.yandex &&
              _shelfModel != ShelfModelChoice.yandex) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _yandexKey,
              decoration: const InputDecoration(labelText: 'Ключ доступа Яндекса'),
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yandexFolder,
              decoration: const InputDecoration(labelText: 'Идентификатор каталога'),
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _saveYandex,
              child: const Text('Сохранить Яндекс'),
            ),
          ],
          if (_voiceModel != ShelfModelChoice.off) ...[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Разрешить отправку записи, если телефон не распознал речь',
              ),
              value: _voiceRecordingConsent,
              onChanged: _busy ? null : _setVoiceRecordingConsent,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Разрешить приводить текст заметки в порядок'),
              value: _voiceFormatConsent,
              onChanged: _busy ? null : _setVoiceFormatConsent,
            ),
          ],
          ]),
          _section('log', 'Журнал', [
          const Text(
            'Когда журнал включён, приложение записывает каждый запрос к каталогу и каждое обращение к модели, а также сохранение и резервные копии. Ключи и снимки в журнал не попадают.',
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Вести журнал'),
            value: _logging,
            onChanged: _busy ? null : _setLogging,
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (context) => const LogScreen()),
              );
            },
            child: const Text('Открыть журнал'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : _clearLog,
            child: const Text('Очистить журнал'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : _shareLog,
            child: const Text('Отправить журнал'),
          ),
          ]),
          const SizedBox(height: 12),
          Text(
            'Ключи, пароль LiveLib и токены ботов остаются на телефоне и не попадают в резервную копию.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _section(String id, String title, List<Widget> children) {
    final open = _open.contains(id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title, style: Theme.of(context).textTheme.titleLarge),
          trailing: Icon(open ? Icons.expand_less : Icons.expand_more),
          onTap: () {
            final next = {..._open};
            if (open) {
              next.remove(id);
            } else {
              next.add(id);
            }
            setState(() => _open = next);
            ref.read(libraryRepositoryProvider).setOpenSettingsSections(next);
          },
        ),
        if (open) ...children,
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _setLogging(bool enabled) async {
    final log = ref.read(appLogProvider);
    if (enabled) {
      log.enabled = true;
      await ref.read(libraryRepositoryProvider).setLoggingEnabled(true);
      await log.write('Журнал включён');
    } else {
      await log.write('Журнал выключен');
      log.enabled = false;
      await ref.read(libraryRepositoryProvider).setLoggingEnabled(false);
    }
    if (mounted) {
      setState(() => _logging = enabled);
    }
  }

  Future<void> _setOverflow(bool enabled) async {
    await ref.read(libraryRepositoryProvider).setRowOverflowControl(enabled);
    await ref.read(appLogProvider).write(
      enabled
          ? 'Контроль переполнения включён'
          : 'Контроль переполнения выключен',
    );
    if (mounted) {
      setState(() => _overflow = enabled);
    }
  }

  Future<void> _setShelfModel(ShelfModelChoice choice) async {
    await ref.read(libraryRepositoryProvider).setShelfModel(choice);
    ref.invalidate(shelfModelChoiceProvider);
    await ref.read(appLogProvider).write(
      'Модель полки',
      shelfModelLabel(choice),
    );
    if (mounted) {
      setState(() => _shelfModel = choice);
    }
  }

  Future<void> _setVoiceModel(ShelfModelChoice choice) async {
    await ref.read(libraryRepositoryProvider).setVoiceModel(choice);
    ref.invalidate(voiceModelChoiceProvider);
    await ref.read(appLogProvider).write(
      'Модель заметки',
      shelfModelLabel(choice),
    );
    if (mounted) {
      setState(() => _voiceModel = choice);
    }
  }

  Future<void> _setVoiceRecordingConsent(bool enabled) async {
    await ref.read(libraryRepositoryProvider).setVoiceRecordingConsent(enabled);
    await ref.read(appLogProvider).write(
      enabled
          ? 'Отправка записи заметки разрешена'
          : 'Отправка записи заметки запрещена',
    );
    if (mounted) {
      setState(() => _voiceRecordingConsent = enabled);
    }
  }

  Future<void> _setVoiceFormatConsent(bool enabled) async {
    await ref.read(libraryRepositoryProvider).setVoiceFormatConsent(enabled);
    await ref.read(appLogProvider).write(
      enabled
          ? 'Правка текста заметки разрешена'
          : 'Правка текста заметки запрещена',
    );
    if (mounted) {
      setState(() => _voiceFormatConsent = enabled);
    }
  }

  Future<void> _saveKimiKey() async {
    await ref.read(libraryRepositoryProvider).setKimiApiKey(_kimiKey.text);
    if (mounted) {
      showMessage(context, 'Ключ Kimi сохранён.');
    }
  }

  Future<void> _saveYandex() async {
    final repository = ref.read(libraryRepositoryProvider);
    await repository.setYandexApiKey(_yandexKey.text);
    await repository.setYandexFolderId(_yandexFolder.text);
    if (mounted) {
      showMessage(context, 'Настройки Яндекса сохранены.');
    }
  }

  Future<void> _setKimiConsent(bool enabled) async {
    await ref.read(libraryRepositoryProvider).setKimiCloudConsent(enabled);
    await ref.read(appLogProvider).write(
      enabled
          ? 'Отправка фото полки разрешена'
          : 'Отправка фото полки запрещена',
    );
    if (mounted) {
      setState(() => _kimiConsent = enabled);
    }
  }

  Future<void> _clearLog() async {
    final confirmed = await confirmDialog(
      context,
      title: 'Очистить журнал',
      message: 'Записи действий будут удалены с этого телефона.',
      confirmLabel: 'Очистить',
    );
    if (!confirmed || !mounted) {
      return;
    }
    await ref.read(appLogProvider).clear();
    if (mounted) {
      showMessage(context, 'Журнал очищен.');
    }
  }

  Future<void> _shareLog() async {
    final confirmed = await confirmDialog(
      context,
      title: 'Отправить журнал',
      message:
          'В журнале есть названия книг и поисковые запросы. Их увидит получатель письма или сообщения.',
      confirmLabel: 'Отправить',
    );
    if (!confirmed || !mounted) {
      return;
    }
    final text = (await ref.read(appLogProvider).readText()).trim();
    if (!mounted) {
      return;
    }
    if (text.isEmpty) {
      showMessage(context, 'Журнал пуст.');
      return;
    }
    await ref.read(appLogProvider).write('Открыта отправка журнала');
    await SharePlus.instance.share(
      ShareParams(text: text, subject: 'Журнал «Моя библиотека»'),
    );
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final bytes = await BackupService().buildArchive(
        db: ref.read(databaseProvider),
        paths: ref.read(libraryPathsProvider),
      );
      final saved = await FilePicker.saveFile(
        dialogTitle: 'Сохранить резервную копию',
        fileName:
            'mylibrary-${DateTime.now().toIso8601String().split('T').first}.zip',
        mimeType: 'application/zip',
        bytes: Uint8List.fromList(bytes),
      );
      if (!mounted) {
        return;
      }
      if (saved != null) {
        await ref.read(appLogProvider).write('Экспорт резервной копии');
        if (!mounted) {
          return;
        }
        showMessage(context, 'Копия сохранена.');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      await ref.read(appLogProvider).write(
        'Ошибка экспорта',
        userFacingError(error),
      );
      if (!mounted) {
        return;
      }
      showMessage(context, userFacingError(error));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _import() async {
    final picked = await FilePicker.pickFile(
      dialogTitle: 'Выбрать резервную копию',
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    if (picked == null || !mounted) {
      return;
    }
    final Uint8List bytes;
    try {
      bytes = await picked.readAsBytes();
    } catch (error) {
      if (mounted) {
        showMessage(context, userFacingError(error));
      }
      return;
    }
    if (!mounted) {
      return;
    }
    final confirmed = await confirmDialog(
      context,
      title: 'Заменить библиотеку',
      message:
          'Текущие книги, комнаты и фото на этом устройстве будут заменены содержимым архива.',
      confirmLabel: 'Импортировать',
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _busy = true);
    var closed = false;
    try {
      final handle = ref.read(databaseHandleProvider);
      await handle.close();
      closed = true;
      await BackupService().restore(
        paths: ref.read(libraryPathsProvider),
        bytes: bytes,
      );
      if (!mounted) {
        return;
      }
      await ref.read(appLogProvider).write('Импорт резервной копии');
      if (!mounted) {
        return;
      }
      showMessage(context, 'Библиотека восстановлена.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      await ref.read(appLogProvider).write(
        'Ошибка импорта',
        userFacingError(error),
      );
      if (!mounted) {
        return;
      }
      showMessage(context, userFacingError(error));
    } finally {
      if (closed) {
        ref.invalidate(databaseHandleProvider);
      }
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.choice, required this.onChanged});

  final AppThemeChoice choice;
  final ValueChanged<AppThemeChoice> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in AppThemeChoice.values)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(themeChoiceLabel(item)),
            trailing: choice == item ? const Icon(Icons.check) : null,
            onTap: () => onChanged(item),
          ),
      ],
    );
  }
}
