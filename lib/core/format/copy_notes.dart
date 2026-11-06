import 'package:my_library/core/format/loan.dart';
import 'package:my_library/core/format/russian_plural.dart';
import 'package:my_library/core/format/series_label.dart';
import 'package:my_library/core/models/reading_status.dart';

List<String> copyNotes({
  required ReadingStatus readingStatus,
  String seriesName = '',
  int? seriesVolume,
  String loanPerson = '',
  DateTime? loanDueAt,
  DateTime? now,
  bool includeLoan = true,
}) {
  final notes = <String>[readingStatusLabel(readingStatus)];
  final series = seriesLabel(seriesName, seriesVolume);
  if (series != null) {
    notes.add(series);
  }
  if (includeLoan && loanIsActive(loanPerson)) {
    final due = loanDueAt;
    if (due == null) {
      notes.add('На руках у ${loanPerson.trim()}');
    } else {
      final day = formatDay(due);
      final overdue = loanIsOverdue(due, now ?? DateTime.now());
      notes.add(
        overdue
            ? 'На руках у ${loanPerson.trim()}, просрочено $day'
            : 'На руках у ${loanPerson.trim()}, до $day',
      );
    }
  }
  return notes;
}
