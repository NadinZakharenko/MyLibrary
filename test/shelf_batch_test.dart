import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/features/capture/shelf_batch.dart';

void main() {
  test('duplicates are skipped and counted separately', () {
    final tally = BatchTally()
      ..add(SpineOutcome.saved)
      ..add(SpineOutcome.duplicate)
      ..add(SpineOutcome.skipped)
      ..add(SpineOutcome.duplicate);

    expect(tally.saved, 1);
    expect(tally.skipped, 3);
    expect(tally.duplicates, 2);
    expect(
      tally.message,
      'Сохранено 1, пропущено 3, из них уже в библиотеке 2.',
    );
  });

  test('message omits the library tail without duplicates', () {
    final tally = BatchTally()
      ..add(SpineOutcome.saved)
      ..add(SpineOutcome.skipped);

    expect(tally.message, 'Сохранено 1, пропущено 1.');
  });

  test('only saved spines settle as kept', () {
    expect(spineSettledValue(SpineOutcome.saved), isTrue);
    expect(spineSettledValue(SpineOutcome.skipped), isFalse);
    expect(spineSettledValue(SpineOutcome.duplicate), isFalse);
  });
}
