enum SpineOutcome { saved, skipped, duplicate }

bool spineSettledValue(SpineOutcome outcome) {
  return switch (outcome) {
    SpineOutcome.saved => true,
    SpineOutcome.skipped => false,
    SpineOutcome.duplicate => false,
  };
}

class BatchTally {
  var saved = 0;
  var skipped = 0;
  var duplicates = 0;

  void add(SpineOutcome outcome) {
    switch (outcome) {
      case SpineOutcome.saved:
        saved += 1;
      case SpineOutcome.skipped:
        skipped += 1;
      case SpineOutcome.duplicate:
        skipped += 1;
        duplicates += 1;
    }
  }

  String get message {
    final tail = duplicates == 0 ? '' : ', из них уже в библиотеке $duplicates';
    return 'Сохранено $saved, пропущено $skipped$tail.';
  }
}
