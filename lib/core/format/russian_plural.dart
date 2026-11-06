/// «1 книга», «2 книги», «5 книг», «11 книг», «21 книга».
String booksCountLabel(int count) {
  final mod10 = count.abs() % 10;
  final mod100 = count.abs() % 100;
  final noun = switch ((mod10, mod100)) {
    (1, 11) => 'книг',
    (1, _) => 'книга',
    (2, 12) || (3, 13) || (4, 14) => 'книг',
    (2, _) || (3, _) || (4, _) => 'книги',
    _ => 'книг',
  };
  return '$count $noun';
}

bool isWithinLastDays(DateTime createdAt, DateTime now, {int days = 7}) {
  final start = now.toUtc().subtract(Duration(days: days));
  return !createdAt.toUtc().isBefore(start);
}

String formatDay(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day.$month.${local.year}';
}
