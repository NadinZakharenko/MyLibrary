import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:my_library/core/logging/app_log.dart';
import 'package:my_library/core/models/book_copy.dart';
import 'package:my_library/data/library_repository.dart';
import 'package:my_library/data/messenger_bots.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

const libraryReminderChannel = 'library_return';

class LibraryReminders {
  LibraryReminders(this.repository, this.log, {MessengerBots? bots, FlutterLocalNotificationsPlugin? notifications})
      : bots = bots ?? const MessengerBots(),
        notifications = notifications ?? FlutterLocalNotificationsPlugin();

  final LibraryRepository repository;
  final AppLog log;
  final MessengerBots bots;
  final FlutterLocalNotificationsPlugin notifications;

  /// Opens the book when the user taps its reminder.
  void Function(int bookId)? onOpenBook;

  var _ready = false;
  Future<void> _syncing = Future.value();

  Future<void> ensureReady() async {
    if (_ready) {
      return;
    }
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.local);
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: darwin);
    await notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final id = libraryReminderBookId(response);
        if (id != null) {
          onOpenBook?.call(id);
        }
      },
    );
    _ready = true;
  }

  /// The book whose reminder started the app, if any.
  Future<int?> launchBookId() async {
    await ensureReady();
    final details = await notifications.getNotificationAppLaunchDetails();
    final response = details?.notificationResponse;
    if (details?.didNotificationLaunchApp != true || response == null) {
      return null;
    }
    return libraryReminderBookId(response);
  }

  Future<bool> requestPermission() async {
    await ensureReady();
    final android = notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final allowed =
        await android?.requestNotificationsPermission() ??
        await ios?.requestPermissions(alert: true, badge: true, sound: true);
    await android?.requestExactAlarmsPermission();
    return allowed ?? true;
  }

  /// Runs one sync at a time; a failure goes to the log.
  Future<void> sync() {
    final next = _syncing.then((_) => _sync()).catchError((Object error) {
      return log.writeAlways('Напоминание', journalDetail(error));
    });
    _syncing = next;
    return next;
  }

  Future<void> _sync() async {
    await ensureReady();
    final enabled = await repository.libraryReminderEnabled();
    final rows = await repository.libraryReminderRows();
    final current = {for (final book in rows) book.id};
    final pending = await notifications.pendingNotificationRequests();
    for (final request in pending) {
      if (!current.contains(request.id)) {
        await notifications.cancel(request.id);
      }
    }
    for (final book in rows) {
      await notifications.cancel(book.id);
      final due = book.libraryDueAt;
      final reminder = libraryReminderAt(due);
      if (!enabled || due == null || reminder == null || !reminder.isAfter(DateTime.now())) {
        continue;
      }
      final when = tz.TZDateTime.from(reminder, tz.local);
      try {
        await notifications.zonedSchedule(
          book.id,
          'Вернуть в библиотеку',
          libraryReminderText(title: book.title, due: due),
          when,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              libraryReminderChannel,
              'Возврат в библиотеку',
              channelDescription: 'Напоминание за день до срока возврата',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: '${book.id}',
        );
      } catch (_) {
        try {
          await notifications.zonedSchedule(
            book.id,
            'Вернуть в библиотеку',
            libraryReminderText(title: book.title, due: due),
            when,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                libraryReminderChannel,
                'Возврат в библиотеку',
                channelDescription: 'Напоминание за день до срока возврата',
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: '${book.id}',
          );
        } catch (error) {
          await log.writeAlways('Напоминание', journalDetail(error));
        }
      }
    }
    await deliverDue();
  }

  Future<void> deliverDue() async {
    final now = DateTime.now();
    final rows = await repository.libraryReminderRows();
    for (final book in rows) {
      final due = book.libraryDueAt;
      if (due == null) {
        continue;
      }
      if (!shouldSendLibraryReminder(
        due: due,
        now: now,
        sentForDue: book.reminderSentForDue,
      )) {
        continue;
      }
      final text = libraryReminderText(title: book.title, due: due);
      await repository.markLibraryReminderSent(book.id, due);
      await _send(
        text,
        maxText: maxLibraryReminderText(title: book.title, due: due),
      );
    }
  }

  Future<void> _send(String text, {required String maxText}) async {
    if (await repository.telegramReminderEnabled()) {
      final token = (await repository.telegramBotToken())?.trim() ?? '';
      final chat = (await repository.telegramChatId())?.trim() ?? '';
      if (token.isNotEmpty && chat.isNotEmpty) {
        try {
          await bots.sendTelegram(token: token, chatId: chat, text: text);
          await log.writeAlways('Напоминание', 'Telegram отправлено');
        } catch (error) {
          await log.writeAlways('Напоминание', 'Telegram: ${journalDetail(error)}');
        }
      }
    }
    if (await repository.maxReminderEnabled()) {
      final token = (await repository.maxBotToken())?.trim() ?? '';
      final user = (await repository.maxUserId())?.trim() ?? '';
      if (token.isNotEmpty && user.isNotEmpty) {
        try {
          await bots.sendMax(token: token, userId: user, text: maxText);
          await log.writeAlways('Напоминание', 'Макс отправлено');
        } catch (error) {
          await log.writeAlways('Напоминание', 'Макс: ${journalDetail(error)}');
        }
      }
    }
  }
}

/// Notification tap payload is the book id.
int? libraryReminderBookId(NotificationResponse response) {
  return int.tryParse(response.payload ?? '');
}
