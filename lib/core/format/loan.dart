bool loanIsActive(String? person) {
  return person != null && person.trim().isNotEmpty;
}

/// True when [due] falls on a calendar day before [now] in local time.
bool loanIsOverdue(DateTime? due, DateTime now) {
  if (due == null) {
    return false;
  }
  final dueDay = _calendarDay(due.toLocal());
  final today = _calendarDay(now);
  return dueDay.isBefore(today);
}

DateTime _calendarDay(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
