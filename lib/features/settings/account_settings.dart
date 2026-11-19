import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_library/core/logging/app_log.dart';
import 'package:my_library/data/livelib_account.dart';
import 'package:my_library/data/messenger_bots.dart';
import 'package:my_library/data/yandex_books_client.dart';
import 'package:my_library/data/yandex_books_import.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/common_widgets.dart';

class AccountSettings extends ConsumerStatefulWidget {
  const AccountSettings({super.key});

  @override
  ConsumerState<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends ConsumerState<AccountSettings> {
  final _profile = TextEditingController();
  final _booksToken = TextEditingController();
  final _login = TextEditingController();
  final _password = TextEditingController();
  final _telegramName = TextEditingController();
  final _telegramToken = TextEditingController();
  final _telegramChat = TextEditingController();
  final _maxName = TextEditingController();
  final _maxToken = TextEditingController();
  final _maxUser = TextEditingController();
  var _open = <String>{};
  var _reminder = false;
  var _review = false;
  var _livelib = false;
  var _telegram = false;
  var _max = false;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      final repository = ref.read(libraryRepositoryProvider);
      final open = await repository.openSettingsSections();
      _profile.text = (await repository.yandexBooksProfile()) ?? '';
      _booksToken.text = (await repository.yandexBooksToken()) ?? '';
      _login.text = (await repository.livelibLogin()) ?? '';
      _password.text = (await repository.livelibPassword()) ?? '';
      _telegramName.text = (await repository.telegramBotName()) ?? '';
      _telegramToken.text = (await repository.telegramBotToken()) ?? '';
      _telegramChat.text = (await repository.telegramChatId()) ?? '';
      _maxName.text = (await repository.maxBotName()) ?? '';
      _maxToken.text = (await repository.maxBotToken()) ?? '';
      _maxUser.text = (await repository.maxUserId()) ?? '';
      final reminder = await repository.libraryReminderEnabled();
      final review = await repository.yandexBooksReviewConsent();
      final livelib = await repository.livelibSendConsent();
      final telegram = await repository.telegramReminderEnabled();
      final max = await repository.maxReminderEnabled();
      if (!mounted) {
        return;
      }
      setState(() {
        _open = open;
        _reminder = reminder;
        _review = review;
        _livelib = livelib;
        _telegram = telegram;
        _max = max;
      });
    });
  }

  @override
  void dispose() {
    _profile.dispose();
    _booksToken.dispose();
    _login.dispose();
    _password.dispose();
    _telegramName.dispose();
    _telegramToken.dispose();
    _telegramChat.dispose();
    _maxName.dispose();
    _maxToken.dispose();
    _maxUser.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _section(
          'yandex-books',
          'Яндекс Книги',
          [
            const Text(
              'Нужен OAuth-токен Яндекс Книг, он начинается с y0_. Ключ Yandex Cloud сюда не подходит. Токен хранится только на телефоне.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _profile,
              decoration: const InputDecoration(labelText: 'Профиль'),
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _booksToken,
              decoration: const InputDecoration(labelText: 'Токен Яндекс Книг'),
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Разрешить отправку отметки и отзыва'),
              value: _review,
              onChanged: _busy
                  ? null
                  : (value) async {
                      await ref
                          .read(libraryRepositoryProvider)
                          .setYandexBooksReviewConsent(value);
                      ref.invalidate(catalogSendConsentProvider);
                      if (!mounted) {
                        return;
                      }
                      setState(() => _review = value);
                    },
            ),
            FilledButton(
              onPressed: _busy ? null : _saveBooks,
              child: const Text('Сохранить профиль'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : _checkBooks,
              child: const Text('Проверить профиль'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : _importBooks,
              child: const Text('Загрузить прослушанные'),
            ),
          ],
        ),
        _section(
          'livelib',
          'LiveLib',
          [
            const Text(
              'Логин и пароль нужны, чтобы отправить отметку и рецензию. Поиск каталога по-прежнему открытый.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _login,
              decoration: const InputDecoration(labelText: 'Логин'),
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Пароль'),
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Разрешить отправку отметки и рецензии'),
              value: _livelib,
              onChanged: _busy
                  ? null
                  : (value) async {
                      await ref
                          .read(libraryRepositoryProvider)
                          .setLivelibSendConsent(value);
                      ref.invalidate(catalogSendConsentProvider);
                      if (!mounted) {
                        return;
                      }
                      setState(() => _livelib = value);
                    },
            ),
            FilledButton(
              onPressed: _busy ? null : _saveLiveLib,
              child: const Text('Сохранить вход в LiveLib'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : _checkLiveLib,
              child: const Text('Проверить вход'),
            ),
          ],
        ),
        _section(
          'return',
          'Возврат в библиотеку',
          [
            const Text(
              'Напоминание в 10:00 за день до срока. Свои книги и книги на руках его не получают.',
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Напоминать за день до возврата в библиотеку'),
              value: _reminder,
              onChanged: _busy ? null : _setReminder,
            ),
            TextField(
              controller: _telegramName,
              decoration: const InputDecoration(labelText: 'Имя бота Telegram'),
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telegramToken,
              decoration: const InputDecoration(labelText: 'Токен бота Telegram'),
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telegramChat,
              decoration: const InputDecoration(labelText: 'Чат Telegram'),
              autocorrect: false,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Слать в Telegram'),
              value: _telegram,
              onChanged: _busy
                  ? null
                  : (value) async {
                      await ref
                          .read(libraryRepositoryProvider)
                          .setTelegramReminderEnabled(value);
                      if (!mounted) {
                        return;
                      }
                      setState(() => _telegram = value);
                    },
            ),
            OutlinedButton(
              onPressed: _busy ? null : () => _checkBot(max: false),
              child: const Text('Проверить бота Telegram'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : () => _bindBot(max: false),
              child: const Text('Привязать чат Telegram'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _maxName,
              decoration: const InputDecoration(labelText: 'Имя бота Макс'),
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _maxToken,
              decoration: const InputDecoration(labelText: 'Токен бота Макс'),
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _maxUser,
              decoration: const InputDecoration(labelText: 'Пользователь Макс'),
              autocorrect: false,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Слать в Макс'),
              value: _max,
              onChanged: _busy
                  ? null
                  : (value) async {
                      await ref
                          .read(libraryRepositoryProvider)
                          .setMaxReminderEnabled(value);
                      if (!mounted) {
                        return;
                      }
                      setState(() => _max = value);
                    },
            ),
            OutlinedButton(
              onPressed: _busy ? null : () => _checkBot(max: true),
              child: const Text('Проверить бота Макс'),
            ),
            const SizedBox(height: 8),
            const Text(
              'В поле «Пользователь Макс» — ваш user id. Кнопка ниже отправляет пробное сообщение в диалог с ботом.',
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : () => _bindBot(max: true),
              child: const Text('Отправить пробу в Макс'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _saveBots,
              child: const Text('Сохранить ботов'),
            ),
          ],
        ),
      ],
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

  Future<void> _persistBooks() async {
    final repository = ref.read(libraryRepositoryProvider);
    await repository.setYandexBooksProfile(_profile.text);
    await repository.setYandexBooksToken(_booksToken.text);
  }

  Future<void> _saveBooks() async {
    await _persistBooks();
    if (mounted) {
      showMessage(context, 'Профиль Яндекс Книг сохранён.');
    }
  }

  Future<void> _checkBooks() async {
    setState(() => _busy = true);
    try {
      await _persistBooks();
      final id = await const YandexBooksClient().profileId(
        token: _booksToken.text,
        publicId: _profile.text,
      );
      await ref.read(libraryRepositoryProvider).setYandexBooksProfile(id);
      if (mounted) {
        setState(() => _profile.text = id);
      }
      final message = _booksToken.text.trim().isEmpty
          ? 'Токена нет. Публичный профиль «$id».'
          : 'Профиль «$id» подтверждён.';
      await _note('Яндекс Книги', message);
    } catch (error) {
      await _note('Яндекс Книги', journalDetail(error));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _importBooks() async {
    setState(() => _busy = true);
    try {
      await _persistBooks();
      final message = await importYandexAudiobooks(
        repository: ref.read(libraryRepositoryProvider),
        images: ref.read(imageStoreProvider),
      );
      await _note('Яндекс Книги', message);
    } catch (error) {
      await _note('Яндекс Книги', journalDetail(error));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _saveLiveLib() async {
    final repository = ref.read(libraryRepositoryProvider);
    await repository.setLivelibLogin(_login.text);
    await repository.setLivelibPassword(_password.text);
    if (mounted) {
      showMessage(context, 'LiveLib сохранён.');
    }
  }

  Future<void> _checkLiveLib() async {
    setState(() => _busy = true);
    final account = LiveLibAccount();
    try {
      final repository = ref.read(libraryRepositoryProvider);
      await repository.setLivelibLogin(_login.text);
      await repository.setLivelibPassword(_password.text);
      final result = await account.check(
        login: _login.text,
        password: _password.text,
      );
      await _note('LiveLib', result.ok ? 'вход выполнен' : result.message);
    } catch (error) {
      await _note('LiveLib', journalDetail(error));
    } finally {
      account.close();
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _setReminder(bool value) async {
    try {
      if (value) {
        final allowed = await ref.read(libraryRemindersProvider).requestPermission();
        if (!allowed) {
          await _note('Напоминание', 'уведомления не разрешены');
          return;
        }
      }
      await ref.read(libraryRepositoryProvider).setLibraryReminderEnabled(value);
      await ref.read(libraryRemindersProvider).sync();
      if (mounted) {
        setState(() => _reminder = value);
      }
    } catch (error) {
      await _note('Напоминание', journalDetail(error));
    }
  }

  Future<void> _saveBots({bool announce = true}) async {
    final repository = ref.read(libraryRepositoryProvider);
    await repository.setTelegramBotName(_telegramName.text);
    await repository.setTelegramBotToken(_telegramToken.text);
    await repository.setTelegramChatId(_telegramChat.text);
    await repository.setMaxBotName(_maxName.text);
    await repository.setMaxBotToken(_maxToken.text);
    await repository.setMaxUserId(_maxUser.text);
    if (announce && mounted) {
      showMessage(context, 'Боты сохранены.');
    }
  }

  Future<void> _checkBot({required bool max}) async {
    setState(() => _busy = true);
    try {
      await _saveBots();
      final bots = const MessengerBots();
      final result = max
          ? await bots.checkMax(
              expectedName: _maxName.text,
              token: _maxToken.text,
            )
          : await bots.checkTelegram(
              expectedName: _telegramName.text,
              token: _telegramToken.text,
            );
      final message = result.ok ? 'Бот «${result.name}» подтверждён.' : (result.message ?? 'Бот не подтверждён.');
      await _note(max ? 'Макс' : 'Telegram', message);
    } catch (error) {
      await _note(max ? 'Макс' : 'Telegram', journalDetail(error));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _bindBot({required bool max}) async {
    setState(() => _busy = true);
    try {
      await _saveBots(announce: false);
      final bots = const MessengerBots();
      if (max) {
        final typed = _maxUser.text.trim();
        final id = typed.isNotEmpty ? typed : await bots.bindMaxUser(_maxToken.text);
        if (id == null) {
          await _note(
            'Макс',
            'Чат не найден. Откройте бота, нажмите старт и впишите user id.',
          );
          return;
        }
        await bots.sendMax(
          token: _maxToken.text,
          userId: id,
          text: 'Библиотека на связи.',
        );
        await ref.read(libraryRepositoryProvider).setMaxUserId(id);
        _maxUser.text = id;
        await _note('Макс', 'Проба отправлена пользователю $id.');
        if (mounted) {
          setState(() {});
        }
        return;
      }
      final id = await bots.bindTelegramChat(_telegramToken.text);
      if (id == null) {
        await _note(
          'Telegram',
          'Чат не найден. Откройте бота и нажмите старт.',
        );
        return;
      }
      final repository = ref.read(libraryRepositoryProvider);
      await repository.setTelegramChatId(id);
      _telegramChat.text = id;
      await _note('Telegram', 'Чат привязан.');
      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      await _note(max ? 'Макс' : 'Telegram', journalDetail(error));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _note(String action, String message) async {
    await ref.read(appLogProvider).writeAlways(action, message);
    if (mounted) {
      showMessage(context, message);
    }
  }
}
