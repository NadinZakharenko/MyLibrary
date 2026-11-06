import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/core/models/book_copy.dart';
import 'package:my_library/core/models/book_draft.dart';

void main() {
  test('library copies are not unplaced and audio stays off the shelf', () {
    expect(
      countsAsUnplaced(
        format: BookFormat.print,
        placement: BookPlacement.shelf,
        shelfId: null,
      ),
      isTrue,
    );
    expect(
      countsAsUnplaced(
        format: BookFormat.print,
        placement: BookPlacement.library,
        shelfId: null,
      ),
      isFalse,
    );
    expect(
      countsAsUnplaced(
        format: BookFormat.audio,
        placement: BookPlacement.shelf,
        shelfId: null,
      ),
      isFalse,
    );

    final audio = const BookDraft(
      title: 'Голос',
      format: BookFormat.audio,
      isbn: '123',
      publishers: ['АСТ'],
      shelfId: 4,
      libraryDueAt: null,
    ).prepared();
    expect(audio.isbn, isEmpty);
    expect(audio.publishers, isEmpty);
    expect(audio.shelfId, isNull);

    final library = const BookDraft(
      title: 'Билет',
      placement: BookPlacement.library,
      shelfId: 2,
      rowId: 3,
    ).prepared();
    expect(library.placement, BookPlacement.library);
    expect(library.shelfId, isNull);
    expect(library.format, BookFormat.print);
  });

  test('the reminder is 10:00 on the day before the due date', () {
    final due = DateTime(2026, 11, 8, 18);
    final reminder = libraryReminderAt(due)!;
    expect(reminder, DateTime(2026, 11, 7, 10));
    expect(
      libraryReturnNeedsAttention(due, DateTime(2026, 11, 7, 9)),
      isTrue,
    );
    expect(
      shouldSendLibraryReminder(
        due: due,
        now: DateTime(2026, 11, 7, 10, 1),
        sentForDue: null,
      ),
      isTrue,
    );
    expect(
      shouldSendLibraryReminder(
        due: due,
        now: DateTime(2026, 11, 8, 10),
        sentForDue: null,
      ),
      isFalse,
    );
    expect(
      libraryReminderText(title: 'Тихий Дон', due: due),
      'Вернуть в библиотеку завтра: Тихий Дон. Срок 08.11.2026.',
    );
    expect(
      maxLibraryReminderText(title: 'Тихий Дон', due: due),
      'Библиотека на связи. Вернуть в библиотеку завтра: Тихий Дон. Срок 08.11.2026.',
    );
  });
}
