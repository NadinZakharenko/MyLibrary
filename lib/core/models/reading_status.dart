enum ReadingStatus { wantToRead, reading, finished }

ReadingStatus readingStatusFromStorage(String? raw) {
  return switch (raw) {
    'reading' => ReadingStatus.reading,
    'finished' => ReadingStatus.finished,
    'wantToRead' => ReadingStatus.wantToRead,
    _ => ReadingStatus.wantToRead,
  };
}

String readingStatusStorage(ReadingStatus status) {
  return switch (status) {
    ReadingStatus.wantToRead => 'wantToRead',
    ReadingStatus.reading => 'reading',
    ReadingStatus.finished => 'finished',
  };
}

String readingStatusLabel(ReadingStatus status) {
  return switch (status) {
    ReadingStatus.wantToRead => 'хочу прочитать',
    ReadingStatus.reading => 'читаю',
    ReadingStatus.finished => 'прочитано',
  };
}

String readingStatusDateLabel(ReadingStatus status) {
  return switch (status) {
    ReadingStatus.finished => 'Дата прочтения',
    ReadingStatus.wantToRead || ReadingStatus.reading => 'Дата статуса',
  };
}
