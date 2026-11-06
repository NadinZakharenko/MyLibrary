import 'package:my_library/core/models/reading_status.dart';

/// A paper book or an audiobook. Existing rows stay printed.
enum BookFormat { print, audio }

/// Where a printed book sits. An empty shelf is still [shelf].
enum BookPlacement { shelf, library }

BookFormat bookFormatFromStorage(String? raw) {
  return switch (raw) {
    'audio' => BookFormat.audio,
    _ => BookFormat.print,
  };
}

String bookFormatStorage(BookFormat format) {
  return switch (format) {
    BookFormat.print => 'print',
    BookFormat.audio => 'audio',
  };
}

BookPlacement bookPlacementFromStorage(String? raw) {
  return switch (raw) {
    'library' => BookPlacement.library,
    _ => BookPlacement.shelf,
  };
}

String bookPlacementStorage(BookPlacement placement) {
  return switch (placement) {
    BookPlacement.shelf => 'shelf',
    BookPlacement.library => 'library',
  };
}

String bookFormatLabel(BookFormat format) {
  return switch (format) {
    BookFormat.print => 'Печатная',
    BookFormat.audio => 'Аудио',
  };
}

String bookPlacementLabel(BookPlacement placement) {
  return switch (placement) {
    BookPlacement.shelf => 'На полке',
    BookPlacement.library => 'Библиотека',
  };
}

/// Own printed books that have not been given a shelf.
bool countsAsUnplaced({
  required BookFormat format,
  required BookPlacement placement,
  required int? shelfId,
}) {
  return format == BookFormat.print &&
      placement == BookPlacement.shelf &&
      shelfId == null;
}

/// Home row for a library copy that is due tomorrow or already late.
bool libraryReturnNeedsAttention(DateTime? due, DateTime now) {
  if (due == null) {
    return false;
  }
  final dueDay = calendarDay(due.toLocal());
  final tomorrow = calendarDay(now).add(const Duration(days: 1));
  return !dueDay.isAfter(tomorrow);
}

/// 10:00 local time on the calendar day before [due].
DateTime? libraryReminderAt(DateTime? due) {
  if (due == null) {
    return null;
  }
  final day = calendarDay(due.toLocal());
  return day.subtract(const Duration(days: 1)).add(const Duration(hours: 10));
}

/// Messenger retry stays on the reminder day. The due day is already late.
bool shouldSendLibraryReminder({
  required DateTime due,
  required DateTime now,
  required DateTime? sentForDue,
}) {
  if (sentForDue != null && calendarDay(sentForDue.toLocal()) == calendarDay(due.toLocal())) {
    return false;
  }
  final reminder = libraryReminderAt(due);
  if (reminder == null || now.isBefore(reminder)) {
    return false;
  }
  return calendarDay(now) == calendarDay(reminder);
}

DateTime calendarDay(DateTime value) {
  final local = value.toLocal();
  return DateTime(local.year, local.month, local.day);
}

String yandexAudiobookUrl(String id) {
  return 'https://books.yandex.ru/audiobooks/${id.trim()}';
}

String? yandexAudiobookIdFromUrl(String? url) {
  if (url == null) {
    return null;
  }
  final match = RegExp(r'books\.yandex\.ru/audiobooks/([^/?#]+)').firstMatch(url);
  final id = match?.group(1)?.trim();
  if (id == null || id.isEmpty) {
    return null;
  }
  return id;
}

String durationLabel(int? seconds) {
  if (seconds == null || seconds <= 0) {
    return '';
  }
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  if (hours == 0) {
    return '$minutes мин';
  }
  if (minutes == 0) {
    return '$hours ч';
  }
  return '$hours ч $minutes мин';
}

String readingStatusLabelFor(ReadingStatus status, BookFormat format) {
  if (format == BookFormat.audio) {
    return switch (status) {
      ReadingStatus.wantToRead => 'хочу послушать',
      ReadingStatus.reading => 'слушаю',
      ReadingStatus.finished => 'прослушано',
    };
  }
  return readingStatusLabel(status);
}

String readingStatusDateLabelFor(ReadingStatus status, BookFormat format) {
  if (format == BookFormat.audio && status == ReadingStatus.finished) {
    return 'Дата прослушивания';
  }
  return readingStatusDateLabel(status);
}

String libraryReminderText({
  required String title,
  required DateTime due,
}) {
  final name = title.trim().isEmpty ? 'Книга' : title.trim();
  final day = due.toLocal();
  final label =
      '${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}.${day.year}';
  return 'Вернуть в библиотеку завтра: $name. Срок $label.';
}

String maxLibraryReminderText({
  required String title,
  required DateTime due,
}) {
  return 'Библиотека на связи. ${libraryReminderText(title: title, due: due)}';
}
